/// Berkas: lib/services/hash_service.dart
/// Deskripsi: Layanan fungsi kriptografi berbasis SHA-256.
/// Mengimplementasikan 2 syarat tugas akhir: Enkripsi Password Client-Side dan Konsensus Rantai Blok (Blockchain Ledger).

import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Service untuk algoritma hashing SHA-256.
/// Digunakan untuk enkripsi password di sisi client dan perhitungan integritas rantai blok (Blockchain Ledger).
class HashService {
  // [POIN PRESENTASI]: Enkripsi password client-side menggunakan SHA-256 agar kata sandi tidak pernah dikirim dalam bentuk plain text
  static String hashSha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // [POIN PRESENTASI]: Algoritma Blockchain sederhana; merangkai blok transaksi belanja title dengan menghubungkan data saat ini dan hash blok sebelumnya (prevHash)
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
