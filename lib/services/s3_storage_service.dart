import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Service untuk upload dan akses Supabase Storage via S3-Compatible API.
/// Menggunakan AWS Signature Version 4 (SigV4) murni tanpa paket eksternal tambahan.
/// Melewati pembatasan RLS storage secara langsung menggunakan Access Key ID dan Secret Access Key.
class S3StorageService {
  static const String accessKey = '218e0e45dd13dfd9c9b9b2ecf2993e90';
  static const String secretKey = '47946b156a5f1150ad427b53ee3651c0b5f6cbd9d8bfc9db53e187a81607571f';
  static const String host = 'urpfytwepfgaybbautcf.supabase.co';
  static const String region = 'us-east-1';
  static const String bucket = 'Avatar';

  static List<int> _hmacSha256(List<int> key, List<int> data) {
    final hmac = Hmac(sha256, key);
    return hmac.convert(data).bytes;
  }

  static List<int> _getSignatureKey(String key, String dateStamp, String regionName, String serviceName) {
    final kDate = _hmacSha256(utf8.encode('AWS4$key'), utf8.encode(dateStamp));
    final kRegion = _hmacSha256(kDate, utf8.encode(regionName));
    final kService = _hmacSha256(kRegion, utf8.encode(serviceName));
    final kSigning = _hmacSha256(kService, utf8.encode('aws4_request'));
    return kSigning;
  }

  /// Mengunggah file byte array ke bucket 'Avatar' via protokol S3 PUT
  static Future<String?> uploadFile({
    required String path,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    try {
      final now = DateTime.now().toUtc();
      final amzDate = _formatAmzDate(now);
      final dateStamp = _formatDateStamp(now);

      final payloadHash = sha256.convert(bytes).toString();
      final canonicalUri = '/storage/v1/s3/$bucket/$path';
      const canonicalQuerystring = '';
      final canonicalHeaders = 'host:$host\nx-amz-content-sha256:$payloadHash\nx-amz-date:$amzDate\n';
      const signedHeaders = 'host;x-amz-content-sha256;x-amz-date';

      final canonicalRequest = 'PUT\n$canonicalUri\n$canonicalQuerystring\n$canonicalHeaders\n$signedHeaders\n$payloadHash';
      const algorithm = 'AWS4-HMAC-SHA256';
      final credentialScope = '$dateStamp/$region/s3/aws4_request';
      final stringToSign = '$algorithm\n$amzDate\n$credentialScope\n${sha256.convert(utf8.encode(canonicalRequest))}';

      final signingKey = _getSignatureKey(secretKey, dateStamp, region, 's3');
      final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

      final authorizationHeader = '$algorithm Credential=$accessKey/$credentialScope, SignedHeaders=$signedHeaders, Signature=$signature';

      final uri = Uri.parse('https://$host$canonicalUri');
      final httpClient = HttpClient();
      final request = await httpClient.putUrl(uri);
      request.headers.set('Host', host);
      request.headers.set('x-amz-date', amzDate);
      request.headers.set('x-amz-content-sha256', payloadHash);
      request.headers.set('Authorization', authorizationHeader);
      request.headers.set('Content-Type', contentType);

      request.add(bytes);
      final response = await request.close();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('S3 upload sukses untuk $path (HTTP ${response.statusCode})');
        return getPresignedDownloadUrl(path: path);
      } else {
        final respBody = await response.transform(utf8.decoder).join();
        debugPrint('S3 upload error ${response.statusCode}: $respBody');
        return null;
      }
    } catch (e) {
      debugPrint('S3 upload exception: $e');
      return null;
    }
  }

  /// Menghasilkan URL unduh S3 presigned yang berlaku selama 7 hari (dapat dimuat oleh Image.network)
  static String getPresignedDownloadUrl({required String path, int expiresInSeconds = 604800}) {
    final now = DateTime.now().toUtc();
    final amzDate = _formatAmzDate(now);
    final dateStamp = _formatDateStamp(now);

    final canonicalUri = '/storage/v1/s3/$bucket/$path';
    final credentialScope = '$dateStamp/$region/s3/aws4_request';
    final credentialParam = Uri.encodeComponent('$accessKey/$credentialScope');

    final canonicalQuerystring =
        'X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=$credentialParam&X-Amz-Date=$amzDate&X-Amz-Expires=$expiresInSeconds&X-Amz-SignedHeaders=host';

    final canonicalHeaders = 'host:$host\n';
    const signedHeaders = 'host';

    final canonicalRequest = 'GET\n$canonicalUri\n$canonicalQuerystring\n$canonicalHeaders\n$signedHeaders\nUNSIGNED-PAYLOAD';
    const algorithm = 'AWS4-HMAC-SHA256';
    final stringToSign = '$algorithm\n$amzDate\n$credentialScope\n${sha256.convert(utf8.encode(canonicalRequest))}';

    final signingKey = _getSignatureKey(secretKey, dateStamp, region, 's3');
    final signature = Hmac(sha256, signingKey).convert(utf8.encode(stringToSign)).toString();

    return 'https://$host$canonicalUri?$canonicalQuerystring&X-Amz-Signature=$signature';
  }

  static String _formatAmzDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}T'
        '${dt.hour.toString().padLeft(2, '0')}'
        '${dt.minute.toString().padLeft(2, '0')}'
        '${dt.second.toString().padLeft(2, '0')}Z';
  }

  static String _formatDateStamp(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}'
        '${dt.month.toString().padLeft(2, '0')}'
        '${dt.day.toString().padLeft(2, '0')}';
  }
}
