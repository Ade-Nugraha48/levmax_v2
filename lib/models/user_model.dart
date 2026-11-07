/// Berkas: lib/models/user_model.dart
/// Deskripsi: Model entitas data pengguna (Hunter Profile) pada LevMax.
/// Menyimpan statistik status RPG: ID akun, username, total EXP, saldo Gold, tingkatan Rank, dan sisa HP.

/// Entitas data profil Hunter dalam sistem gamifikasi LevMax
class UserModel {
  final String id;
  final String username;
  final int exp;
  final int gold;
  final String rank;
  final int hp;

  const UserModel({
    required this.id,
    required this.username,
    required this.exp,
    required this.gold,
    required this.rank,
    this.hp = 3,
  });

  // [POIN PRESENTASI]: Serialisasi data pengguna menjadi Map key-value untuk dikirim ke backend Supabase atau disimpan di sesi lokal Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'exp': exp,
      'gold': gold,
      'rank': rank,
      'hp': hp,
    };
  }

  // [POIN PRESENTASI]: Deserialisasi data respon database menjadi objek UserModel dengan proteksi fallback nilai bawaan
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      exp: (map['exp'] as num?)?.toInt() ?? 0,
      gold: (map['gold'] as num?)?.toInt() ?? 0,
      rank: map['rank']?.toString() ?? 'F',
      hp: (map['hp'] as num?)?.toInt() ?? 3,
    );
  }
}
