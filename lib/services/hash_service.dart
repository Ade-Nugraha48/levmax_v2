import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Service untuk algoritma hashing SHA-256.
/// Digunakan untuk enkripsi password di sisi client dan perhitungan integritas rantai blok (Blockchain Ledger).
class HashService {
  /// Menghasilkan hash SHA-256 dalam bentuk string heksadesimal dari input string
  static String hashSha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Menghitung hash transaksi blockchain: SHA-256(username + item + timestamp + prevHash)
  static String createBlockchainHash({
    required String username,
    required String item,
    required String timestamp,
    required String prevHash,
  }) {
    final rawData = '$username$item$timestamp$prevHash';
    return hashSha256(rawData);
  }
}
