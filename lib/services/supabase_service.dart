import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 's3_storage_service.dart';

/// Service penanganan koneksi remote database Supabase (Tabel users & feedbacks).
/// Sesuai aturan arsitektur: tidak mengandung kode UI dan mengembalikan tipe data standar / Future.
class SupabaseService {
  /// Mengambil instance SupabaseClient aktif
  static SupabaseClient get client => Supabase.instance.client;

  /// Mengunggah foto profil Hunter ke storage bucket 'Avatar'
  static Future<String?> uploadAvatar(File imageFile, String userId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final path = '$userId/profile.jpg';

      // 1. Prioritas Utama: Gunakan S3 Storage API langsung dengan Access Key yang telah divalidasi
      final s3Url = await S3StorageService.uploadFile(
        path: path,
        bytes: bytes,
        contentType: 'image/jpeg',
      );
      if (s3Url != null) {
        debugPrint('Upload avatar berhasil via S3 API: $s3Url');
        return s3Url;
      }

      // 2. Fallback: Coba upload REST API via client Supabase
      debugPrint('S3 upload tidak menghasilkan URL, mencoba REST API fallback...');
      String targetBucket = 'Avatar';
      try {
        await client.storage.from('Avatar').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
      } catch (e) {
        debugPrint('Upload ke bucket "Avatar" gagal: $e. Mencoba bucket lowercase "avatar"...');
        targetBucket = 'avatar';
        await client.storage.from('avatar').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
      }

      final publicUrl = client.storage.from(targetBucket).getPublicUrl(path);
      return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('Upload avatar gagal: $e');
      return null;
    }
  }

  /// Memperbarui kolom avatar_url Hunter pada tabel 'users'
  static Future<bool> updateAvatarUrl({
    required String userId,
    required String avatarUrl,
  }) async {
    try {
      await client.from('users').update({'avatar_url': avatarUrl}).eq('id', userId);
      return true;
    } catch (e) {
      debugPrint('Gagal update avatar_url ke tabel users: $e');
      return false;
    }
  }

  /// Mendaftarkan Hunter baru ke tabel 'users'
  static Future<Map<String, dynamic>?> register({
    required String username,
    required String passwordHash,
    int hp = 3,
    String? avatarUrl,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'username': username,
        'password_hash': passwordHash,
        'exp': 0,
        'gold': 0,
        'rank': 'F',
        'hp': hp,
      };
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      try {
        final response = await client.from('users').insert(data).select().single();
        return response;
      } catch (insertError) {
        debugPrint('Insert user gagal: $insertError. Menjalankan fallback...');
        // Fallback jika kolom hp atau avatar_url belum ada di skema SQL remote
        data.remove('hp');
        data.remove('avatar_url');
        final response = await client.from('users').insert(data).select().single();
        return response;
      }
    } catch (e) {
      debugPrint('Register gagal: $e');
      return null;
    }
  }

  /// Autentikasi user berdasarkan username dan password_hash di tabel 'users'
  static Future<Map<String, dynamic>?> login({
    required String username,
    required String passwordHash,
  }) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('username', username)
          .eq('password_hash', passwordHash)
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }

  /// Memperbarui statistik Hunter (EXP, Gold, Rank) pada tabel 'users'
  static Future<bool> updateUserStats({
    required String userId,
    int? exp,
    int? gold,
    String? rank,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (exp != null) updates['exp'] = exp;
      if (gold != null) updates['gold'] = gold;
      if (rank != null) updates['rank'] = rank;

      if (updates.isEmpty) return true;

      await client.from('users').update(updates).eq('id', userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mengirimkan pesan kesan dan pesan mata kuliah ke tabel 'feedbacks'
  static Future<bool> submitFeedback({
    required String userId,
    required String message,
  }) async {
    try {
      await client.from('feedbacks').insert({
        'user_id': userId,
        'message': message,
      });
      return true;
    } catch (e) {
      debugPrint('Error submitFeedback: $e');
      return false;
    }
  }

  /// Mengambil kesan dan pesan terbaru Hunter dari tabel 'feedbacks'
  static Future<Map<String, dynamic>?> getLatestFeedback(String userId) async {
    try {
      final response = await client
          .from('feedbacks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error getLatestFeedback: $e');
      return null;
    }
  }

  /// Mengambil jumlah total quest yang telah diselesaikan dari tabel 'user_quests'
  static Future<int> getCompletedQuestsCount(String userId) async {
    try {
      final response = await client
          .from('user_quests')
          .select('id')
          .eq('user_id', userId);
      return (response as List).length;
    } catch (e) {
      debugPrint('Error getCompletedQuestsCount: $e');
      return 0;
    }
  }

  /// Mencatat quest yang diselesaikan oleh user ke tabel 'user_quests'
  static Future<bool> recordQuestCompleted({
    required String userId,
    required String questId,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      await client.from('user_quests').insert({
        'user_id': userId,
        'quest_id': questId,
        'last_completed_date': today,
      });
      return true;
    } catch (e) {
      debugPrint('Error recordQuestCompleted: $e');
      return false;
    }
  }

  /// Melakukan upsert data penyelesaian quest ke tabel 'user_quests' di Supabase
  static Future<bool> backupQuestCompletion({
    required String userId,
    required String questId,
    String? completedDate,
  }) async {
    try {
      final now = DateTime.now();
      final dateStr = completedDate ??
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      try {
        await client.from('user_quests').upsert({
          'user_id': userId,
          'quest_id': questId,
          'last_completed_date': dateStr,
        }, onConflict: 'user_id,quest_id');
      } catch (_) {
        await client.from('user_quests').upsert({
          'user_id': userId,
          'quest_id': questId,
          'last_completed_date': dateStr,
        });
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Mengambil riwayat quest yang telah diselesaikan hari ini dari tabel 'user_quests' di Supabase
  static Future<List<Map<String, dynamic>>> fetchTodayCompletedQuests({
    required String userId,
    String? todayDate,
  }) async {
    try {
      final now = DateTime.now();
      final dateStr = todayDate ??
          '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final response = await client
          .from('user_quests')
          .select('quest_id, last_completed_date')
          .eq('user_id', userId)
          .eq('last_completed_date', dateStr);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
