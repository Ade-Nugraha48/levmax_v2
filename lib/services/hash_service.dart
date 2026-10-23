import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Service untuk algoritma hashing SHA-256 untuk password & rantai blockchain lokal (Boilerplate)
class HashService {
  /// Melakukan hash string menggunakan SHA-256
  static String hashSha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
