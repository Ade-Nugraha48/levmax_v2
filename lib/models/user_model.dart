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
