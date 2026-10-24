import 'package:hive/hive.dart';
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
    String? rank,
    int? exp,
    int? gold,
    int? hp,
    String? avatarUrl,
    List<String>? ownedTitles,
    String? equippedTitle,
  }) async {
    final box = sessionBox;
    await box.put('isLoggedIn', true);
    await box.put('userId', userId);
    await box.put('username', username);
    if (rank != null) await box.put('rank', rank);
    if (exp != null) await box.put('exp', exp);
    if (gold != null) await box.put('gold', gold);
    if (hp != null) await box.put('hp', hp);
    if (avatarUrl != null) await box.put('avatar_url', avatarUrl);
    if (ownedTitles != null) {
      await box.put('owned_titles', ownedTitles);
    } else if (box.get('owned_titles') == null) {
      await box.put('owned_titles', ['Hunter']);
    }
    if (equippedTitle != null) {
      await box.put('equipped_title', equippedTitle);
    } else if (box.get('equipped_title') == null) {
      await box.put('equipped_title', 'Hunter');
    }
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
      'owned_titles': getOwnedTitles(),
      'equipped_title': getEquippedTitle(),
    };
  }

  /// Menyimpan atau memperbarui avatarUrl ke sesi lokal
  static Future<void> saveAvatarUrl(String url) async {
    final box = sessionBox;
    await box.put('avatar_url', url);
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
    await box.put('total_quests_done', count);
  }

  /// Mengambil jumlah quest yang telah diselesaikan dari Hive
  static int? getQuestsCount() {
    final box = sessionBox;
    final val = box.get('total_quests_done') ?? box.get('quests_done_count');
    if (val is num) return val.toInt();
    return null;
  }

  /// Menyimpan tanggal aktivitas/login terakhir untuk pelacakan pergantian hari & penalti HP
  static Future<void> saveLastLoginDate(String date) async {
    final box = sessionBox;
    await box.put('last_login_date', date);
  }

  /// Mengambil tanggal login terakhir dari sessionBox
  static String? getLastLoginDate() {
    final box = sessionBox;
    return box.get('last_login_date')?.toString();
  }

  /// Menyimpan jumlah quest yang diselesaikan pada hari aktif ini
  static Future<void> saveCompletedQuestsTodayCount(int count) async {
    final box = sessionBox;
    await box.put('completed_quests_today_count', count);
  }

  /// Mengambil jumlah quest yang diselesaikan pada hari aktif ini
  static int getCompletedQuestsTodayCount() {
    final box = sessionBox;
    final val = box.get('completed_quests_today_count');
    if (val is num) return val.toInt();
    return 0;
  }

  /// Mengambil daftar title yang dimiliki oleh pengguna
  static List<String> getOwnedTitles() {
    final box = sessionBox;
    final raw = box.get('owned_titles');
    List<String> titles = [];
    if (raw is List) {
      titles = raw.map((e) => e.toString()).toList();
    }
    // Jika masih kosong (inisialisasi awal), isi dengan title default
    if (titles.isEmpty) {
      titles = ['Hunter'];
      // Masukkan juga jika ada title yang tercatat di blockchainBox
      final logs = getBlockchainLogs();
      for (final log in logs) {
        if (log['item'] != null) {
          final item = log['item'].toString();
          if (!titles.contains(item)) titles.add(item);
        }
      }
      box.put('owned_titles', titles);
    }
    return titles;
  }

  /// Menambahkan title baru ke daftar kepemilikan
  static Future<void> addOwnedTitle(String title) async {
    final titles = getOwnedTitles();
    if (!titles.contains(title)) {
      titles.add(title);
      await sessionBox.put('owned_titles', titles);
    }
  }

  /// Mengambil title yang sedang aktif/dipasang (equipped)
  static String getEquippedTitle() {
    final box = sessionBox;
    final title = box.get('equipped_title')?.toString();
    if (title != null && title.isNotEmpty) return title;
    return 'Hunter';
  }

  /// Menyimpan title yang sedang aktif/dipasang (equipped)
  static Future<void> setEquippedTitle(String title) async {
    await sessionBox.put('equipped_title', title);
  }
}
