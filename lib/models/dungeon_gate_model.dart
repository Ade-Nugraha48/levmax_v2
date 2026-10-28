import 'package:latlong2/latlong.dart';

/// Model untuk lokasi Dungeon Gate harian bertema Solo Leveling.
/// Memetakan titik-titik lokasi positif di sekitar Yogyakarta (Kampus, Stadion, Taman, Perpustakaan)
/// yang berganti secara deterministik setiap hari untuk mendorong gaya hidup aktif & positif.
class DungeonGateModel {
  final String id;
  final String name;
  final String locationName;
  final double latitude;
  final double longitude;
  final String rank;
  final String gateType;
  final String positiveActivity;
  final int expReward;
  final int goldReward;
  final String iconType; // 'campus', 'stadium', 'park', 'library', 'sport'

  const DungeonGateModel({
    required this.id,
    required this.name,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.rank,
    required this.gateType,
    required this.positiveActivity,
    required this.expReward,
    required this.goldReward,
    this.iconType = 'campus',
  });

  LatLng get coordinates => LatLng(latitude, longitude);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'rank': rank,
      'gate_type': gateType,
      'positive_activity': positiveActivity,
      'exp_reward': expReward,
      'gold_reward': goldReward,
      'icon_type': iconType,
    };
  }

  factory DungeonGateModel.fromMap(Map<String, dynamic> map) {
    return DungeonGateModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      locationName: map['location_name']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      rank: map['rank']?.toString() ?? 'RANK E',
      gateType: map['gate_type']?.toString() ?? 'BLUE GATE',
      positiveActivity: map['positive_activity']?.toString() ?? '',
      expReward: (map['exp_reward'] as num?)?.toInt() ?? 50,
      goldReward: (map['gold_reward'] as num?)?.toInt() ?? 100,
      iconType: map['icon_type']?.toString() ?? 'campus',
    );
  }

  /// Daftar lokasi Dungeon Positif di area Yogyakarta
  static const List<DungeonGateModel> positiveDungeons = [
    // 1. Kampus 2 UPN Veteran Babarsari (Pusat Riset & Akademik)
    DungeonGateModel(
      id: 'upn_babarsari',
      name: 'Babarsari Academic Core Gate',
      locationName: 'Kampus 2 UPN Veteran Yogyakarta (Babarsari)',
      latitude: -7.7794,
      longitude: 110.4162,
      rank: 'RANK D',
      gateType: 'BLUE GATE',
      positiveActivity: 'Belajar kelompok, riset teknologi di lab, & penyusunan karya ilmiah',
      expReward: 65,
      goldReward: 120,
      iconType: 'campus',
    ),

    // 2. Stadion Maguwoharjo (Jogging & Kebugaran Fisik)
    DungeonGateModel(
      id: 'maguwoharjo_stadium',
      name: 'Maguwo Stadium Stamina Gate',
      locationName: 'Stadion Maguwoharjo (Sleman)',
      latitude: -7.7498,
      longitude: 110.4289,
      rank: 'RANK C',
      gateType: 'RED GATE',
      positiveActivity: 'Jogging 3 putaran lapangan, sprint interval, & peningkatan stamina fisik',
      expReward: 80,
      goldReward: 160,
      iconType: 'stadium',
    ),

    // 3. Embung Tambakboyo (Kardio Alam Terbuka & Relaksasi Mental)
    DungeonGateModel(
      id: 'tambakboyo_water',
      name: 'Tambakboyo Serenity Gate',
      locationName: 'Embung Tambakboyo (Condongcatur)',
      latitude: -7.7592,
      longitude: 110.4150,
      rank: 'RANK E',
      gateType: 'BLUE GATE',
      positiveActivity: 'Jalan santai mengelilingi danau, relaksasi pernapasan mana, & refreshing',
      expReward: 50,
      goldReward: 100,
      iconType: 'park',
    ),

    // 4. Grhatama Pustaka (Literasi & Pembacaan Buku)
    DungeonGateModel(
      id: 'grhatama_library',
      name: 'Grhatama Knowledge Citadel',
      locationName: 'Perpustakaan Daerah DIY (Grhatama Pustaka)',
      latitude: -7.7985,
      longitude: 110.4035,
      rank: 'RANK B',
      gateType: 'PURPLE GATE',
      positiveActivity: 'Membaca buku pengembangan diri 30 menit & pendalaman materi kuliah',
      expReward: 90,
      goldReward: 180,
      iconType: 'library',
    ),

    // 5. GOR UNY / Stadion Atletik Kolombo (Kebugaran Atletik)
    DungeonGateModel(
      id: 'uny_athletics',
      name: 'Kolombo Athletic Ground',
      locationName: 'Stadion Atletik & GOR UNY',
      latitude: -7.7716,
      longitude: 110.3879,
      rank: 'RANK C',
      gateType: 'BLUE GATE',
      positiveActivity: 'Latihan kalistenik push-up/pull-up & peregangan tubuh atletis',
      expReward: 75,
      goldReward: 150,
      iconType: 'sport',
    ),

    // 6. Taman Denggung / Taman Kota Sleman (Rekreasi Hijau Terbuka)
    DungeonGateModel(
      id: 'taman_denggung',
      name: 'Denggung Green Sanctuary',
      locationName: 'Taman Denggung (Pusat Kota Sleman)',
      latitude: -7.7176,
      longitude: 110.3582,
      rank: 'RANK D',
      gateType: 'BLUE GATE',
      positiveActivity: 'Jalan cepat menikmati ruang terbuka hijau bersama rekan & rekreasi bersih',
      expReward: 60,
      goldReward: 110,
      iconType: 'park',
    ),

    // 7. Kampus 1 UPN Veteran Yogyakarta (Condongcatur)
    DungeonGateModel(
      id: 'upn_condongcatur',
      name: 'Condongcatur Command HQ Gate',
      locationName: 'Kampus 1 UPN Veteran Yogyakarta (Condongcatur)',
      latitude: -7.7613,
      longitude: 110.4090,
      rank: 'RANK E',
      gateType: 'BLUE GATE',
      positiveActivity: 'Perkuliahan disiplin waktu, rapat organisasi mahasiswa, & keaktifan kelas',
      expReward: 50,
      goldReward: 100,
      iconType: 'campus',
    ),
  ];

  /// Mengambil Dungeon Gate aktif hari ini berdasarkan rotasi tanggal (1 Hari = 1 Gate Berbeda)
  static DungeonGateModel getDailyGate({DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    final startOfYear = DateTime(targetDate.year, 1, 1);
    final dayIndex = targetDate.difference(startOfYear).inDays;
    return positiveDungeons[dayIndex.abs() % positiveDungeons.length];
  }
}
