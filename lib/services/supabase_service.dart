import 'package:supabase_flutter/supabase_flutter.dart';

/// Service penanganan koneksi remote database Supabase (Tabel users & feedbacks).
/// Sesuai aturan arsitektur: tidak mengandung kode UI dan mengembalikan tipe data standar / Future.
class SupabaseService {
  /// Mengambil instance SupabaseClient aktif
  static SupabaseClient get client => Supabase.instance.client;

  /// Mendaftarkan Hunter baru ke tabel 'users'
  static Future<Map<String, dynamic>?> register({
    required String username,
    required String passwordHash,
    int hp = 3,
  }) async {
    try {
      try {
        final response = await client.from('users').insert({
          'username': username,
          'password_hash': passwordHash,
          'exp': 0,
          'gold': 0,
          'rank': 'F',
          'hp': hp,
        }).select().single();
        return response;
      } catch (_) {
        // Fallback jika kolom hp belum ada di skema SQL remote
        final response = await client.from('users').insert({
          'username': username,
          'password_hash': passwordHash,
          'exp': 0,
          'gold': 0,
          'rank': 'F',
        }).select().single();
        return response;
      }
    } catch (e) {
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
      return false;
    }
  }
}
