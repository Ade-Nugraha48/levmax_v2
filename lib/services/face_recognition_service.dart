import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Model data template biometrik wajah Hunter
class FaceTemplate {
  final List<double> vector;
  final String dHash;
  final String dHashV;
  final String? thumbnailBase64;
  final String createdAt;

  FaceTemplate({
    required this.vector,
    required this.dHash,
    required this.dHashV,
    this.thumbnailBase64,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'vector': vector,
        'dHash': dHash,
        'dHashV': dHashV,
        'thumbnailBase64': thumbnailBase64,
        'createdAt': createdAt,
      };

  factory FaceTemplate.fromJson(Map<String, dynamic> json) {
    final rawVec = json['vector'] as List<dynamic>? ?? [];
    final List<double> vec = rawVec.map((e) => (e as num).toDouble()).toList();
    return FaceTemplate(
      vector: vec,
      dHash: json['dHash']?.toString() ?? '',
      dHashV: json['dHashV']?.toString() ?? '',
      thumbnailBase64: json['thumbnailBase64']?.toString(),
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  String serialize() => jsonEncode(toJson());

  static FaceTemplate? deserialize(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return FaceTemplate.fromJson(decoded);
      }
      return null;
    } catch (e) {
      debugPrint('[FaceTemplate] Error deserializing template: $e');
      return null;
    }
  }
}

/// Hasil perbandingan biometrik wajah
class FaceComparisonResult {
  final bool isMatch;
  final double score; // 0.0 - 100.0%
  final double cosineSimilarity;
  final double dHashSimilarity;
  final String message;

  FaceComparisonResult({
    required this.isMatch,
    required this.score,
    required this.cosineSimilarity,
    required this.dHashSimilarity,
    required this.message,
  });
}

/// Service untuk memproses ekstraksi fitur biometrik wajah dan mencocokkan wajah secara real-time
class FaceRecognitionService {
  /// Ambang batas kecocokan minimum biometrik wajah (70.0%)
  static const double matchThreshold = 70.0;

  /// Ukuran kanonikal grid normalisasi (32x32 = 1024 titik fitur)
  static const int canonicalSize = 32;

  /// Memproses gambar mentah (bytes) dan mengekstrak template fitur wajah
  static FaceTemplate? extractTemplate(Uint8List imageBytes) {
    try {
      img.Image? original = img.decodeImage(imageBytes);
      if (original == null) return null;

      // Koreksi orientasi EXIF kamera
      original = img.bakeOrientation(original);

      final int origW = original.width;
      final int origH = original.height;

      // Fokus pada area tengah tempat wajah berada di dalam retikel panduan
      final int cropW = (origW * 0.58).round().clamp(16, origW);
      final int cropH = (origH * 0.65).round().clamp(16, origH);
      final int startX = ((origW - cropW) / 2).round().clamp(0, origW - cropW);
      // Sedikit bias ke atas (posisi mata & dahi)
      final int startY = ((origH - cropH) * 0.45).round().clamp(0, origH - cropH);

      final img.Image cropped = img.copyCrop(
        original,
        x: startX,
        y: startY,
        width: cropW,
        height: cropH,
      );

      // Konversi ke grayscale untuk menghilangkan bias warna kulit / pencahayaan warna
      final img.Image gray = img.grayscale(cropped);

      // Resize ke grid kanonikal 32x32
      final img.Image canonical = img.copyResize(
        gray,
        width: canonicalSize,
        height: canonicalSize,
        interpolation: img.Interpolation.linear,
      );

      // Ekstraksi nilai luminansi
      final List<double> luminances = [];
      for (int y = 0; y < canonicalSize; y++) {
        for (int x = 0; x < canonicalSize; x++) {
          final p = canonical.getPixel(x, y);
          luminances.add(p.luminanceNormalized.toDouble());
        }
      }

      // Normalisasi Z-Score (Zero-mean, unit-variance) untuk menolak variasi pencahayaan
      double sum = 0.0;
      for (final val in luminances) {
        sum += val;
      }
      final double mean = sum / luminances.length;

      double varianceSum = 0.0;
      for (final val in luminances) {
        final diff = val - mean;
        varianceSum += diff * diff;
      }
      final double stdDev = math.sqrt(varianceSum / luminances.length);

      // Jika gambar terlalu seragam / gelap total tanpa kontur wajah
      if (stdDev < 0.005) {
        return null;
      }

      final List<double> normalizedVector = [];
      for (final val in luminances) {
        normalizedVector.add((val - mean) / stdDev);
      }

      // Perceptual Horizontal Difference Hash (dHash 8x8 = 64-bit)
      final img.Image dHashImgH = img.copyResize(gray, width: 9, height: 8);
      final StringBuffer dHashHBuf = StringBuffer();
      for (int y = 0; y < 8; y++) {
        for (int x = 0; x < 8; x++) {
          final pL = dHashImgH.getPixel(x, y).luminanceNormalized;
          final pR = dHashImgH.getPixel(x + 1, y).luminanceNormalized;
          dHashHBuf.write(pL > pR ? '1' : '0');
        }
      }

      // Perceptual Vertical Difference Hash (dHashV 8x8 = 64-bit) untuk mendeteksi garis alis, mata, bibir
      final img.Image dHashImgV = img.copyResize(gray, width: 8, height: 9);
      final StringBuffer dHashVBuf = StringBuffer();
      for (int y = 0; y < 8; y++) {
        for (int x = 0; x < 8; x++) {
          final pT = dHashImgV.getPixel(x, y).luminanceNormalized;
          final pB = dHashImgV.getPixel(x, y + 1).luminanceNormalized;
          dHashVBuf.write(pT > pB ? '1' : '0');
        }
      }

      // Thumbnail pratinjau wajah
      final img.Image thumb = img.copyResize(cropped, width: 120, height: 120);
      final Uint8List thumbBytes = Uint8List.fromList(img.encodeJpg(thumb, quality: 75));
      final String thumbBase64 = base64Encode(thumbBytes);

      return FaceTemplate(
        vector: normalizedVector,
        dHash: dHashHBuf.toString(),
        dHashV: dHashVBuf.toString(),
        thumbnailBase64: thumbBase64,
        createdAt: DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('[FaceRecognitionService] Error extracting template: $e');
      return null;
    }
  }

  /// Membandingkan template wajah terdaftar dengan template kandidat
  static FaceComparisonResult compareTemplates(
    FaceTemplate enrolled,
    FaceTemplate candidate,
  ) {
    if (enrolled.vector.length != candidate.vector.length || enrolled.vector.isEmpty) {
      return FaceComparisonResult(
        isMatch: false,
        score: 0.0,
        cosineSimilarity: 0.0,
        dHashSimilarity: 0.0,
        message: 'Dimensi vektor biometrik tidak kompatibel',
      );
    }

    // 1. Cosine Similarity (Pearson Correlation karena vektor sudah Z-score normalized)
    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < enrolled.vector.length; i++) {
      final a = enrolled.vector[i];
      final b = candidate.vector[i];
      dotProduct += a * b;
      normA += a * a;
      normB += b * b;
    }

    final double denominator = math.sqrt(normA) * math.sqrt(normB);
    final double cosineSim = denominator > 0 ? (dotProduct / denominator) : 0.0;

    // 2. Hamming Distance pada Perceptual Hashes (Horizontal & Vertical)
    int hammingH = 0;
    final int minLenH = math.min(enrolled.dHash.length, candidate.dHash.length);
    for (int i = 0; i < minLenH; i++) {
      if (enrolled.dHash[i] != candidate.dHash[i]) hammingH++;
    }

    int hammingV = 0;
    final int minLenV = math.min(enrolled.dHashV.length, candidate.dHashV.length);
    for (int i = 0; i < minLenV; i++) {
      if (enrolled.dHashV[i] != candidate.dHashV[i]) hammingV++;
    }

    final int totalBits = minLenH + minLenV;
    final double dHashSim = totalBits > 0 ? 1.0 - ((hammingH + hammingV) / totalBits) : 0.0;

    // 3. Bobot gabungan (70% korelasi fitur struktural + 30% pola kontur hash)
    final double positiveCosine = math.max(0.0, cosineSim);
    final double combined = (0.70 * positiveCosine) + (0.30 * dHashSim);
    final double percentage = (combined * 100.0).clamp(0.0, 100.0);

    final bool isMatch = percentage >= matchThreshold;

    final String message = isMatch
        ? 'Wajah cocok dengan identitas terdaftar (${percentage.toStringAsFixed(1)}%)'
        : 'Wajah tidak cocok dengan basis data Hunter (${percentage.toStringAsFixed(1)}%)';

    return FaceComparisonResult(
      isMatch: isMatch,
      score: percentage,
      cosineSimilarity: cosineSim,
      dHashSimilarity: dHashSim,
      message: message,
    );
  }

  /// Membandingkan frame kandidat mentah langsung dengan template terdaftar di Hive
  static FaceComparisonResult compareBytesWithTemplate(
    Uint8List candidateBytes,
    String enrolledTemplateJson,
  ) {
    final FaceTemplate? enrolled = FaceTemplate.deserialize(enrolledTemplateJson);
    if (enrolled == null) {
      return FaceComparisonResult(
        isMatch: false,
        score: 0.0,
        cosineSimilarity: 0.0,
        dHashSimilarity: 0.0,
        message: 'Template biometrik basis Hive rusak atau tidak ditemukan',
      );
    }

    final FaceTemplate? candidate = extractTemplate(candidateBytes);
    if (candidate == null) {
      return FaceComparisonResult(
        isMatch: false,
        score: 0.0,
        cosineSimilarity: 0.0,
        dHashSimilarity: 0.0,
        message: 'Wajah tidak terdeteksi dengan jelas pada kamera. Pastikan pencahayaan cukup.',
      );
    }

    return compareTemplates(enrolled, candidate);
  }
}
