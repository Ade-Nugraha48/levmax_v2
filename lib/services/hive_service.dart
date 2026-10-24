import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:levmax_v2/models/ai_persona_model.dart';
import 'package:levmax_v2/models/alarm_model.dart';
import 'package:levmax_v2/utils/constants.dart';

/// Service untuk manajemen penyimpanan lokal Hive (Session & Ledger Blockchain).
/// Sesuai aturan arsitektur: tidak mengandung kode UI dan mengembalikan tipe data standar / Future.
class HiveService {
  /// Box untuk menyimpan sesi Hunter
  static Box get sessionBox => Hive.box(AppConstants.sessionBox);

  /// Box untuk menyimpan riwayat rantai blok (Blockchain)
  static Box get blockchainBox => Hive.box(AppConstants.blockchainBox);

  /// Box untuk menyimpan status penyelesaian quest
  static Box get questBox => Hive.box(AppConstants.questBox);

  /// Menyimpan sesi login Hunter setelah autentikasi berhasil
  static Future<void> saveSession({
    required String userId,
    required String username,
    String? password,
    String? rank,
    int? exp,
    int? gold,
    int? hp,
    String? avatarUrl,
  }) async {
    final box = sessionBox;
    await box.put('isLoggedIn', true);
    await box.put('userId', userId);
    await box.put('username', username);
    if (password != null) await box.put('active_password', password);
    if (rank != null) await box.put('rank', rank);
    if (exp != null) await box.put('exp', exp);
    if (gold != null) await box.put('gold', gold);
    if (hp != null) await box.put('hp', hp);
    if (avatarUrl != null) await box.put('avatar_url', avatarUrl);
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
      'avatar_url': box.get('avatar_url')?.toString(),
      'active_password': box.get('active_password')?.toString(),
    };
  }

  /// Mengambil password aktif sesi saat ini
  static String? getActivePassword() {
    return sessionBox.get('active_password')?.toString();
  }

  /// Menyimpan atau memperbarui avatarUrl ke sesi lokal
  static Future<void> saveAvatarUrl(String url) async {
    final box = sessionBox;
    await box.put('avatar_url', url);
  }

  /// Menghapus sesi Hunter (Logout)
  static Future<void> clearSession({bool clearBiometrics = false}) async {
    final box = sessionBox;
    await box.put('isLoggedIn', false);
    await box.delete('userId');
    await box.delete('username');
    await box.delete('rank');
    await box.delete('exp');
    await box.delete('gold');
    await box.delete('hp');
    await box.delete('avatar_url');
    await box.delete('active_password');
    if (clearBiometrics) {
      await clearBiometricCredentials();
    }
  }

  /// Menyimpan kredensial biometrik pengguna untuk login otomatis
  static Future<void> saveBiometricCredentials({
    required String username,
    required String password,
    bool fingerprint = true,
    bool faceScan = true,
  }) async {
    final box = sessionBox;
    await box.put('isBiometricEnabled', true);
    await box.put('isFingerprintEnabled', fingerprint);
    await box.put('isFaceScanEnabled', faceScan);
    await box.put('bio_username', username);
    await box.put('bio_password', password);
  }

  /// Mengambil kredensial biometrik yang tersimpan
  static Map<String, String>? getBiometricCredentials() {
    final box = sessionBox;
    final username = box.get('bio_username')?.toString();
    final password = box.get('bio_password')?.toString();
    if (username == null || password == null || username.isEmpty || password.isEmpty) {
      return null;
    }
    return {
      'username': username,
      'password': password,
    };
  }

  /// Memeriksa apakah otentikasi biometrik aktif secara global
  static bool isBiometricEnabled() {
    final box = sessionBox;
    final enabled = box.get('isBiometricEnabled', defaultValue: false) as bool;
    return enabled && getBiometricCredentials() != null;
  }

  /// Memeriksa apakah sensor fingerprint diaktifkan
  static bool isFingerprintEnabled() {
    final box = sessionBox;
    final fp = box.get('isFingerprintEnabled', defaultValue: false) as bool;
    return fp && isBiometricEnabled();
  }

  /// Memeriksa apakah sensor face scan diaktifkan
  static bool isFaceScanEnabled() {
    final box = sessionBox;
    final fs = box.get('isFaceScanEnabled', defaultValue: false) as bool;
    return fs && isBiometricEnabled();
  }

  /// Menghapus kredensial biometrik (dipanggil saat dinonaktifkan atau logout)
  static Future<void> clearBiometricCredentials() async {
    final box = sessionBox;
    await box.put('isBiometricEnabled', false);
    await box.put('isFingerprintEnabled', false);
    await box.put('isFaceScanEnabled', false);
    await box.delete('bio_username');
    await box.delete('bio_password');
    await clearEnrolledFace();
  }

  /// Menyimpan template data biometrik wajah & thumbnail ke Hive sebagai basis pembanding
  static Future<void> saveEnrolledFace({
    required String templateJson,
    String? thumbnailBase64,
  }) async {
    final box = sessionBox;
    await box.put('enrolled_face_template', templateJson);
    if (thumbnailBase64 != null) {
      await box.put('enrolled_face_thumbnail', thumbnailBase64);
    }
  }

  /// Mengambil data template biometrik wajah yang terdaftar di Hive
  static String? getEnrolledFaceTemplate() {
    return sessionBox.get('enrolled_face_template')?.toString();
  }

  /// Mengambil thumbnail wajah terdaftar dari Hive jika ada
  static String? getEnrolledFaceThumbnail() {
    return sessionBox.get('enrolled_face_thumbnail')?.toString();
  }

  /// Memeriksa apakah user sudah mendaftarkan basis foto wajah di Hive
  static bool hasEnrolledFace() {
    final template = getEnrolledFaceTemplate();
    return template != null && template.isNotEmpty;
  }

  /// Menghapus basis data biometrik wajah dari Hive
  static Future<void> clearEnrolledFace() async {
    final box = sessionBox;
    await box.delete('enrolled_face_template');
    await box.delete('enrolled_face_thumbnail');
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
    final persona = getAIPersona();
    await box.put('ai_persona_data', jsonEncode(persona.copyWith(avatarPath: path).toJson()));
  }

  /// Mengambil path gambar avatar custom AI dari Hive jika ada
  static String? getAIAvatar() {
    final box = sessionBox;
    return box.get('ai_avatar_path') as String?;
  }

  /// Menyimpan kustomisasi personifikasi AI (Nama, Identitas, Gaya Bahasa, Sifat, Avatar)
  static Future<void> saveAIPersona(AIPersona persona) async {
    final box = sessionBox;
    await box.put('ai_persona_data', jsonEncode(persona.toJson()));
    if (persona.avatarPath != null) {
      await box.put('ai_avatar_path', persona.avatarPath);
    } else {
      await box.delete('ai_avatar_path');
    }
  }

  /// Mengambil data personifikasi AI yang tersimpan dari Hive
  static AIPersona getAIPersona() {
    final box = sessionBox;
    final raw = box.get('ai_persona_data');
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw.toString());
        if (decoded is Map<String, dynamic>) {
          return AIPersona.fromJson(decoded);
        }
      } catch (_) {}
    }
    final legacyAvatar = getAIAvatar();
    if (legacyAvatar != null) {
      return AIPersona.defaultPersona.copyWith(avatarPath: legacyAvatar);
    }
    return AIPersona.defaultPersona;
  }

  /// Menyimpan konfigurasi alarm Hunter (Jam, Menit, Status, Ringtone MP3, Volume)
  static Future<void> saveAlarm(AlarmModel alarm) async {
    final box = sessionBox;
    await box.put('hunter_alarm_data', jsonEncode(alarm.toJson()));
  }

  /// Mengambil konfigurasi alarm Hunter yang tersimpan dari Hive
  static AlarmModel getAlarm() {
    final box = sessionBox;
    final raw = box.get('hunter_alarm_data');
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw.toString());
        if (decoded is Map<String, dynamic>) {
          return AlarmModel.fromJson(decoded);
        }
      } catch (_) {}
    }
    return AlarmModel.defaultAlarm;
  }

  /// Menyimpan status penyelesaian quest ke Hive (key: ${userId}_${questId})
  static Future<void> saveQuestCompletion({
    required String userId,
    required String questId,
    DateTime? date,
  }) async {
    final box = questBox;
    final timestamp = (date ?? DateTime.now()).toIso8601String();
    await box.put('${userId}_$questId', timestamp);
  }

  /// Memeriksa apakah quest telah diselesaikan hari ini berdasarkan perbandingan tanggal
  static bool isQuestCompletedToday({
    required String userId,
    required String questId,
  }) {
    final box = questBox;
    final raw = box.get('${userId}_$questId');
    if (raw == null) return false;
    final dt = DateTime.tryParse(raw.toString());
    if (dt == null) return false;
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  /// Mengambil kumpulan questId yang telah diselesaikan hari ini oleh user
  static Set<String> getTodayCompletedQuestIds(String userId) {
    final Set<String> completed = {};
    final box = questBox;
    final prefix = '${userId}_';
    final now = DateTime.now();
    for (final key in box.keys) {
      final keyStr = key.toString();
      if (keyStr.startsWith(prefix)) {
        final qId = keyStr.substring(prefix.length);
        final raw = box.get(key);
        if (raw != null) {
          final dt = DateTime.tryParse(raw.toString());
          if (dt != null && dt.year == now.year && dt.month == now.month && dt.day == now.day) {
            completed.add(qId);
          }
        }
      }
    }
    return completed;
  }

  /// Menyimpan/menimpa data quest dari cloud Supabase ke Hive questBox
  static Future<void> syncCompletedQuestsFromCloud({
    required String userId,
    required List<Map<String, dynamic>> records,
  }) async {
    final box = questBox;
    for (final r in records) {
      final qId = r['quest_id']?.toString();
      final dateStr = r['last_completed_date']?.toString();
      if (qId != null && dateStr != null) {
        await box.put('${userId}_$qId', dateStr);
      }
    }
  }

  /// Menyimpan tanggal terakhir klaim reward mini game (Format: yyyy-MM-dd waktu server WIB)
  static Future<void> saveGameRewardDate(String serverDate) async {
    final box = sessionBox;
    await box.put('lastGameRewardDate', serverDate);
  }

  /// Menyimpan tanggal terakhir klaim reward mini game dari Hive
  static String? getGameRewardDate() {
    final box = sessionBox;
    return box.get('lastGameRewardDate')?.toString();
  }

  /// Menyimpan riwayat kesan & pesan feedback ke Hive
  static Future<void> saveFeedback({
    required String message,
    String? createdAt,
  }) async {
    final box = sessionBox;
    await box.put('latest_feedback_message', message);
    if (createdAt != null) {
      await box.put('latest_feedback_created_at', createdAt);
    }
  }

  /// Mengambil data kesan & pesan feedback yang tersimpan di Hive
  static Map<String, String>? getFeedback() {
    final box = sessionBox;
    final msg = box.get('latest_feedback_message')?.toString();
    if (msg == null || msg.isEmpty) return null;
    return {
      'message': msg,
      'created_at': box.get('latest_feedback_created_at')?.toString() ?? '',
    };
  }

  /// Menyimpan jumlah quest yang telah diselesaikan ke Hive
  static Future<void> saveQuestsCount(int count) async {
    final box = sessionBox;
    await box.put('quests_done_count', count);
  }

  /// Mengambil jumlah quest yang telah diselesaikan dari Hive
  static int? getQuestsCount() {
    final box = sessionBox;
    final val = box.get('quests_done_count');
    if (val is num) return val.toInt();
    return null;
  }
}

//
