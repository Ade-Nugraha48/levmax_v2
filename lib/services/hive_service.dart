import 'package:hive/hive.dart';
import 'package:levmax_v2/utils/constants.dart';

/// Service untuk manajemen penyimpanan lokal Hive (Session & Ledger Blockchain).
/// Sesuai aturan arsitektur: tidak mengandung kode UI dan mengembalikan tipe data standar / Future.
class HiveService {
  /// Box untuk menyimpan sesi Hunter
  static Box get sessionBox => Hive.box(AppConstants.sessionBox);

  /// Box untuk menyimpan riwayat rantai blok (Blockchain)
  static Box get blockchainBox => Hive.box(AppConstants.blockchainBox);

  /// Menyimpan sesi login Hunter setelah autentikasi berhasil
  static Future<void> saveSession({
    required String userId,
    required String username,
    String? rank,
    int? exp,
    int? gold,
    int? hp,
  }) async {
    final box = sessionBox;
    await box.put('isLoggedIn', true);
    await box.put('userId', userId);
    await box.put('username', username);
    if (rank != null) await box.put('rank', rank);
    if (exp != null) await box.put('exp', exp);
    if (gold != null) await box.put('gold', gold);
    if (hp != null) await box.put('hp', hp);
  }

  /// Mengambil data sesi pengguna yang tersimpan saat ini
  static Map<String, dynamic> getSession() {
    final box = sessionBox;
    return {
      'isLoggedIn': box.get('isLoggedIn', defaultValue: false) as bool,
      'userId': box.get('userId')?.toString(),
      'username': box.get('username')?.toString(),
      'rank': box.get('rank', defaultValue: 'F')?.toString() ?? 'F',
      'exp': (box.get('exp', defaultValue: 0) as num).toInt(),
      'gold': (box.get('gold', defaultValue: 0) as num).toInt(),
      'hp': (box.get('hp', defaultValue: 3) as num).toInt(),
    };
  }

  /// Menghapus sesi Hunter (Logout)
  static Future<void> clearSession() async {
    await sessionBox.clear();
  }

  /// Menyimpan transaksi item/title ke ledger blockchain lokal
  static Future<void> saveBlockchainLog({
    required String item,
    required String prevHash,
    required String currentHash,
    String? timestamp,
  }) async {
    final key = DateTime.now().millisecondsSinceEpoch.toString();
    await blockchainBox.put(key, {
      'item': item,
      'timestamp': timestamp ?? DateTime.now().toIso8601String(),
      'prev_hash': prevHash,
      'current_hash': currentHash,
    });
  }

  /// Mengambil seluruh riwayat transaksi blockchain yang tersimpan
  static List<Map<String, dynamic>> getBlockchainLogs() {
    final box = blockchainBox;
    final List<Map<String, dynamic>> logs = [];
    for (var key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        logs.add(Map<String, dynamic>.from(value));
      }
    }
    return logs;
  }

  /// Mengambil hash transaksi terakhir (atau Genesis Hash jika box masih kosong)
  static String getLastBlockHash() {
    final box = blockchainBox;
    if (box.isEmpty) {
      return '0000000000000000000000000000000000000000000000000000000000000000';
    }
    final lastKey = box.keys.last;
    final lastVal = box.get(lastKey);
    if (lastVal is Map && lastVal.containsKey('current_hash')) {
      return lastVal['current_hash'].toString();
    }
    return '0000000000000000000000000000000000000000000000000000000000000000';
  }

  /// Menyimpan path gambar avatar custom AI ke Hive
  static Future<void> saveAIAvatar(String path) async {
    final box = sessionBox;
    await box.put('ai_avatar_path', path);
  }

  /// Mengambil path gambar avatar custom AI dari Hive jika ada
  static String? getAIAvatar() {
    final box = sessionBox;
    return box.get('ai_avatar_path') as String?;
  }

  /// Menyimpan tanggal terakhir klaim reward mini game (Format: yyyy-MM-dd waktu server WIB)
  static Future<void> saveGameRewardDate(String serverDate) async {
    final box = sessionBox;
    await box.put('lastGameRewardDate', serverDate);
  }

  /// Mengambil tanggal terakhir klaim reward mini game dari Hive
  static String? getGameRewardDate() {
    final box = sessionBox;
    return box.get('lastGameRewardDate')?.toString();
  }
}
