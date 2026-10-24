import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/hive_service.dart';
import '../../services/notif_service.dart';
import '../../services/supabase_service.dart';
import '../features/appearance_quest_screen.dart';
import '../features/chat_ai_screen.dart';
import '../features/quest_sensor.dart';
import '../features/study_focus_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../features/workout_hub_screen.dart';
import '../../widgets/avatar_image.dart';

class TabHome extends StatefulWidget {
  final VoidCallback? onNavigateToDungeon;

  const TabHome({super.key, this.onNavigateToDungeon});

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {
  // Gate Dungeon Target & Jarak Real-Time (UPN Veteran Yogyakarta)
  static const LatLng _dungeonGate = LatLng(-7.7613, 110.4090);
  double? _gateDistance;
  StreamSubscription<Position>? _homePositionSubscription;

  // Statis dummy data awal, akan dimutakhirkan dari HiveService
  String _hunterName = 'hunter_sung';
  String _rank = 'Rank F';
  int _currentExp = 25;
  int _currentHp = 3;
  final int _maxHp = 3;
  int _gold = 0;
  String? _avatarUrl;

  // Real-time Server Clock
  Timer? _serverClockTimer;
  String _wibTime = '14:30';
  String _witaTime = '15:30';
  String _witTime = '16:30';
  String _gmtTime = '07:30';

  // Filter Kategori
  String _selectedCategory = 'ALL';
  final TextEditingController _searchController = TextEditingController();

  // Tracking Quest yang sudah diselesaikan
  final Set<String> _completedQuests = {};

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    _startServerClock();
    _initDungeonGateDistance();
  }

  Future<void> _initDungeonGateDistance() async {
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        final d = Geolocator.distanceBetween(
          lastKnown.latitude,
          lastKnown.longitude,
          _dungeonGate.latitude,
          _dungeonGate.longitude,
        );
        setState(() {
          _gateDistance = d;
        });
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        _homePositionSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            distanceFilter: 5,
          ),
        ).listen((pos) {
          if (mounted) {
            final d = Geolocator.distanceBetween(
              pos.latitude,
              pos.longitude,
              _dungeonGate.latitude,
              _dungeonGate.longitude,
            );
            setState(() {
              _gateDistance = d;
            });
          }
        });
      }
    } catch (_) {}
  }

  String get _formattedGateDistance {
    if (_gateDistance == null) return 'Mendeteksi...';
    if (_gateDistance! >= 1000) {
      return '${(_gateDistance! / 1000).toStringAsFixed(1)} KM';
    }
    return '${_gateDistance!.toStringAsFixed(0)} M';
  }

  void _loadUserSession() {
    final session = HiveService.getSession();
    final savedUsername = session['username']?.toString();
    if (savedUsername != null && savedUsername.isNotEmpty) {
      _hunterName = savedUsername;
    }
    final savedRank = session['rank']?.toString();
    if (savedRank != null && savedRank.isNotEmpty) {
      _rank = savedRank.toUpperCase().startsWith('RANK') ? savedRank : 'Rank $savedRank';
    }
    final loadedExp = session['exp'] as int?;
    if (loadedExp != null) {
      _currentExp = loadedExp;
    }
    final loadedGold = session['gold'] as int?;
    if (loadedGold != null) {
      _gold = loadedGold;
    }
    final loadedHp = session['hp'] as int?;
    if (loadedHp != null) {
      _currentHp = loadedHp;
    }
    _avatarUrl = session['avatar_url']?.toString();
  }

  void _startServerClock() {
    _updateClock();
    _serverClockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateClock();
    });
  }

  void _updateClock() {
    final nowUtc = DateTime.now().toUtc();
    final wib = nowUtc.add(const Duration(hours: 7));
    final wita = nowUtc.add(const Duration(hours: 8));
    final wit = nowUtc.add(const Duration(hours: 9));
    final gmt = nowUtc;

    final formatter = DateFormat('HH:mm');
    if (mounted) {
      setState(() {
        _wibTime = formatter.format(wib);
        _witaTime = formatter.format(wita);
        _witTime = formatter.format(wit);
        _gmtTime = formatter.format(gmt);
      });
    }
  }

  int get _calculatedMaxExp {
    if (_currentExp >= 2500) return 5000;
    if (_currentExp >= 1500) return 2500;
    if (_currentExp >= 1000) return 1500;
    if (_currentExp >= 600) return 1000;
    if (_currentExp >= 300) return 600;
    if (_currentExp >= 100) return 300;
    return 100;
  }

  int _rankToScore(String rankStr) {
    final clean = rankStr.toUpperCase().replaceAll('RANK', '').trim();
    switch (clean) {
      case 'S':
        return 7;
      case 'A':
        return 6;
      case 'B':
        return 5;
      case 'C':
        return 4;
      case 'D':
        return 3;
      case 'E':
        return 2;
      case 'F':
      default:
        return 1;
    }
  }

  /// Menghitung rank berdasarkan akumulasi EXP: F (0-99), E (100-299), D (300-599), C (600-999), B (1000-1499), A (1500-2499), S (2500+)
  String _calculateRank(int exp) {
    if (exp >= 2500) return 'Rank S';
    if (exp >= 1500) return 'Rank A';
    if (exp >= 1000) return 'Rank B';
    if (exp >= 600) return 'Rank C';
    if (exp >= 300) return 'Rank D';
    if (exp >= 100) return 'Rank E';
    return 'Rank F';
  }

  /// Memeriksa apakah terjadi kenaikan peringkat Hunter
  void checkRankUp(int currentExp) {
    final newRank = _calculateRank(currentExp);
    if (_rankToScore(newRank) > _rankToScore(_rank)) {
      setState(() {
        _rank = newRank;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Level Up! Peringkat Hunter Anda Naik!',
              style: GoogleFonts.spaceGrotesk(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFFB026FF),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Menyelesaikan quest: menambah EXP & Gold, memeriksa rank-up, dan sinkronisasi ke DB
  void completeQuest(int expReward, int goldReward, [String? questId, String? questTitle]) {
    final qId = questId ?? '${expReward}_$goldReward';
    if (_completedQuests.contains(qId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${questTitle ?? 'Quest'} sudah diselesaikan hari ini!'),
          backgroundColor: const Color(0xFF2C1E4E),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _completedQuests.add(qId);
      _currentExp += expReward;
      _gold += goldReward;
    });

    checkRankUp(_currentExp);

    // 1. Simpan ke sesi lokal Hive
    final session = HiveService.getSession();
    final userId = session['userId']?.toString() ?? 'anonymous';
    final username = session['username']?.toString() ?? _hunterName;
    HiveService.saveSession(
      userId: userId,
      username: username,
      rank: _rank,
      exp: _currentExp,
      gold: _gold,
      hp: _currentHp,
    );

    // 2. Sinkronisasi asinkron ke Supabase (jika user telah login)
    if (userId != 'anonymous') {
      SupabaseService.updateUserStats(
        userId: userId,
        exp: _currentExp,
        gold: _gold,
        rank: _rank,
      );
      SupabaseService.recordQuestCompleted(
        userId: userId,
        questId: qId,
      );
      final currentCount = HiveService.getQuestsCount() ?? 0;
      HiveService.saveQuestsCount(currentCount + 1);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'QUEST SELESAI: ${questTitle ?? 'Daily Quest'} (+$expReward EXP, +$goldReward Gold)!',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFB026FF),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _homePositionSubscription?.cancel();
    _serverClockTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = HiveService.getSession();
    _avatarUrl = session['avatar_url']?.toString() ?? _avatarUrl;

    return Scaffold(
      backgroundColor: const Color(0xFF16111E), // Deep Abyss Surface
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 85.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header: Solo Leveling Logo & System Awakening Banner
                  _buildHeaderSection(),

                  const SizedBox(height: 12),

                  // 2. Hero Hunter Matrix Profile Card
                  _buildHunterMatrixCard(),

                  const SizedBox(height: 10),

                  // 3. Server Time Banner (WIB | WITA | WIT | GMT)
                  _buildServerTimeBanner(),

                  const SizedBox(height: 12),

                  // 4. Search Bar & Category Chips
                  _buildSearchAndFilters(),

                  const SizedBox(height: 14),

                  // 5. Today's Daily Quests
                  _buildDailyQuestsHeader(),

                  const SizedBox(height: 8),

                  _buildQuestList(),

                  const SizedBox(height: 14),

                  // 6. Nearby Gate Detected Callout
                  _buildNearbyGateCard(),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            // Floating Action Buttons (Left: Bell Notification, Right: Hunter AI Brain)
            Positioned(
              left: 16,
              bottom: 16,
              child: _buildLeftFab(),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: _buildRightFab(),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Header: System Awakening Banner
  Widget _buildHeaderSection() {
    return Container(
      margin: const EdgeInsets.only(top: 2.0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
      decoration: BoxDecoration(
        color: const Color(0xFF140D28),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 1.0,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing Cyan Dot
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF00F4FE),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00F4FE),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9.5,
                  letterSpacing: 0.8,
                ),
                children: const [
                  TextSpan(
                    text: 'SYSTEM AWAKENING: ',
                    style: TextStyle(
                      color: Color(0xFF00F4FE),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: 'COMPLETE MIN. 3 DAILY QUESTS TO AVOID PENALTY',
                    style: TextStyle(
                      color: Color(0xFFE9DEF2),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. Hero Hunter Matrix Profile Card
  Widget _buildHunterMatrixCard() {
    final int targetMaxExp = _calculatedMaxExp;
    final double expProgress = (_currentExp / targetMaxExp).clamp(0.0, 1.0);
    final int expPercent = (expProgress * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF110C19), // Midnight Abyss Inner Card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB026FF).withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row Atas: Avatar + Username + Rank Badge
          Row(
            children: [
              // Avatar Kotak Rounded dengan Glow Cyan Bolt
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1927),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF00F4FE).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F4FE).withValues(alpha: 0.25),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: HunterAvatar(
                      avatarUrl: _avatarUrl,
                      size: 50,
                      borderRadius: BorderRadius.circular(12),
                      fallback: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 28,
                          color: Color(0xFFE5B5FF),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -3,
                    right: -3,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00F4FE),
                        border: Border.all(
                          color: const Color(0xFF110C19),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF00F4FE),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bolt_rounded,
                          size: 13,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Username & Node Protocol
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _hunterName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sora(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE9DEF2),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Icon(
                          Icons.verified_rounded,
                          size: 15,
                          color: Color(0xFF00F4FE),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NODE PROTOCOL: SYSTEM AWAKENED',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: const Color(0xFF9B8BA1),
                      ),
                    ),
                  ],
                ),
              ),

              // Rank Badge di Kanan
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D164D),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFB026FF).withValues(alpha: 0.5),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB026FF).withValues(alpha: 0.25),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.military_tech_outlined,
                      size: 14,
                      color: Color(0xFFE5B5FF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _rank.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: const Color(0xFFE5B5FF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row Tengah: Vitals (HP Hearts + Gold Badge)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // HP Hearts
              Row(
                children: [
                  Text(
                    'HP  ',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF9B8BA1),
                    ),
                  ),
                  for (int i = 1; i <= _maxHp; i++) ...[
                    Icon(
                      i <= _currentHp ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 16,
                      color: i <= _currentHp ? const Color(0xFFFF5252) : const Color(0xFF5A4A63),
                    ),
                    const SizedBox(width: 3),
                  ],
                  const SizedBox(width: 4),
                  Text(
                    '$_currentHp/$_maxHp',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE9DEF2),
                    ),
                  ),
                ],
              ),

              // Gold Badge Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C242B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF00F4FE).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.hexagon_outlined,
                      size: 13,
                      color: Color(0xFF00F4FE),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_gold GOLD',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: const Color(0xFF00F4FE),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row Bawah: Experience Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EXPERIENCE PROGRESS',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: const Color(0xFF9B8BA1),
                    ),
                  ),
                  Text(
                    '$_currentExp / $targetMaxExp EXP ($expPercent%)',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE5B5FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1927),
                  borderRadius: BorderRadius.circular(3),
                ),
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: expProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB026FF), Color(0xFF00F4FE)],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 3. Server Time Banner (WIB | WITA | WIT | GMT)
  Widget _buildServerTimeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF110C19),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 1.0,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 14,
              color: Color(0xFF00F4FE),
            ),
            const SizedBox(width: 5),
            Text(
              'SYS.TIME',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: const Color(0xFF00F4FE),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'WIB ',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFCBD5E1),
              ),
            ),
            Text(
              _wibTime,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE5B5FF),
              ),
            ),
            const SizedBox(width: 8),
            Text('•', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(width: 8),
            Text(
              'WITA ',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFCBD5E1),
              ),
            ),
            Text(
              _witaTime,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE5B5FF),
              ),
            ),
            const SizedBox(width: 8),
            Text('•', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(width: 8),
            Text(
              'WIT ',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFCBD5E1),
              ),
            ),
            Text(
              _witTime,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE5B5FF),
              ),
            ),
            const SizedBox(width: 8),
            Text('•', style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(width: 8),
            Text(
              'GMT ',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFCBD5E1),
              ),
            ),
            Text(
              _gmtTime,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF00F4FE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 4. Search Bar & Category Chips
  Widget _buildSearchAndFilters() {
    final categories = ['ALL', 'WORKOUT', 'CARDIO', 'STUDY', 'APPEARANCE', 'MANA'];

    return Column(
      children: [
        // Search TextField
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF110C19),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF2C1E4E),
              width: 1.0,
            ),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() {}),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFFE9DEF2),
            ),
            cursorColor: const Color(0xFFB026FF),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Cari nama quest hunter...',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: const Color(0xFF5D5373),
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF8B829E),
                size: 18,
              ),
              suffixIcon: const Icon(
                Icons.tune_rounded,
                color: Color(0xFF8B829E),
                size: 18,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Horizontal Category Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: categories.map((cat) {
              final bool isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFB026FF) : const Color(0xFF1F1927),
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: const Color(0xFF383241),
                              width: 1.0,
                            ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFFB026FF).withValues(alpha: 0.35),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      cat,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isSelected ? Colors.white : const Color(0xFF9B8BA1),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// 5. Today's Daily Quests Header
  Widget _buildDailyQuestsHeader() {
    final completedCount = _completedQuests.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.local_fire_department_rounded,
              size: 17,
              color: Color(0xFFFF7A00),
            ),
            const SizedBox(width: 5),
            Text(
              "TODAY'S DAILY QUESTS",
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: const Color(0xFFE9DEF2),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2736),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$completedCount / 4 DONE',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: const Color(0xFFE5B5FF),
            ),
          ),
        ),
      ],
    );
  }

  /// 6. Quest Cards Stream
  Widget _buildQuestList() {
    final searchQuery = _searchController.text.trim().toLowerCase();

    // Data Daily Quests (termasuk Protokol Penampilan Hunter)
    final quests = [
      {
        'id': 'pushup',
        'title': 'Push Up Protocol',
        'category': 'WORKOUT',
        'desc': '20 Repetisi Terverifikasi Sensor Push-Up fisik',
        'exp': 10,
        'gold': 5,
        'icon': Icons.fitness_center_rounded,
        'iconColor': const Color(0xFFE5B5FF),
        'iconBg': const Color(0xFF2D164D),
        'btnText': 'EXECUTE',
        'btnColor': const Color(0xFFB026FF),
        'btnTextColor': Colors.white,
        'isActionCyan': false,
      },
      {
        'id': 'cardio',
        'title': 'Cardio Distance Run',
        'category': 'CARDIO',
        'desc': 'Target 2.0 KM via GPS Tracking radar hunter',
        'exp': 20,
        'gold': 15,
        'icon': Icons.directions_run_rounded,
        'iconColor': const Color(0xFF00F4FE),
        'iconBg': const Color(0xFF0A2730),
        'btnText': 'START RUN',
        'btnColor': const Color(0xFF00F4FE),
        'btnTextColor': Colors.black,
        'isActionCyan': true,
      },
      {
        'id': 'appearance',
        'title': 'Protokol Penampilan Hunter',
        'category': 'APPEARANCE',
        'desc': '5 Tahap Skincare & Grooming Esensial Hunter',
        'exp': 30,
        'gold': 20,
        'icon': Icons.face_retouching_natural_rounded,
        'iconColor': const Color(0xFF00F4FE),
        'iconBg': const Color(0xFF0A2730),
        'btnText': 'CHECKLIST',
        'btnColor': const Color(0xFF00F4FE),
        'btnTextColor': Colors.black,
        'isActionCyan': true,
      },
      {
        'id': 'mana_focus',
        'title': 'Mana Knowledge Focus',
        'category': 'STUDY',
        'desc': 'Fokus Belajar / Baca Materi 30 Menit tenang',
        'exp': 15,
        'gold': 10,
        'icon': Icons.menu_book_rounded,
        'iconColor': const Color(0xFFDCB8FC),
        'iconBg': const Color(0xFF231B33),
        'btnText': 'FOCUS',
        'btnColor': Colors.transparent,
        'btnTextColor': const Color(0xFFDCB8FC),
        'isActionCyan': false,
      },
    ];

    Future<void> handleQuestAction(Map<String, dynamic> q) async {
      final String qId = q['id'] as String;
      final bool isDone = _completedQuests.contains(qId);
      if (isDone) {
        completeQuest(
          q['exp'] as int,
          q['gold'] as int,
          qId,
          q['title'] as String,
        );
        return;
      }

      if (qId == 'pushup') {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => const WorkoutHubScreen(),
          ),
        );
        if (result != null) {
          completeQuest(
            result['exp'] as int? ?? (q['exp'] as int),
            result['gold'] as int? ?? (q['gold'] as int),
            qId,
            q['title'] as String,
          );
        }
      } else if (qId == 'appearance') {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const AppearanceQuestScreen(),
          ),
        );
        if (result == true) {
          completeQuest(30, 20, qId, q['title'] as String);
        }
      } else if (qId == 'cardio') {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => const QuestSensorScreen(),
          ),
        );
        if (result == true) {
          completeQuest(20, 15, qId, q['title'] as String);
        }
      } else if (qId == 'mana_focus') {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => const StudyFocusScreen(),
          ),
        );
        if (result != null) {
          completeQuest(
            result['exp'] as int? ?? (q['exp'] as int),
            result['gold'] as int? ?? (q['gold'] as int),
            qId,
            q['title'] as String,
          );
        }
      } else {
        completeQuest(
          q['exp'] as int,
          q['gold'] as int,
          qId,
          q['title'] as String,
        );
      }
    }

    // Filter berdasarkan Kategori & Pencarian
    final filteredQuests = quests.where((q) {
      final matchesCategory = _selectedCategory == 'ALL' ||
          q['category'] == _selectedCategory ||
          (_selectedCategory == 'MANA' && q['category'] == 'STUDY');
      final matchesSearch = searchQuery.isEmpty ||
          (q['title'] as String).toLowerCase().contains(searchQuery) ||
          (q['desc'] as String).toLowerCase().contains(searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return Column(
      children: filteredQuests.map((q) {
        final String qId = q['id'] as String;
        final bool isDone = _completedQuests.contains(qId);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => handleQuestAction(q),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1F1927),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDone ? const Color(0xFF00F4FE).withValues(alpha: 0.5) : const Color(0xFF383241),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Icon Kategori di Kiri
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: q['iconBg'] as Color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        q['icon'] as IconData,
                        color: q['iconColor'] as Color,
                        size: 22,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Judul & Info di Tengah
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sora(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFE9DEF2),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2D164D),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  q['category'] as String,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE5B5FF),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  q['desc'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 10,
                                    color: const Color(0xFF9B8BA1),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Reward & Tombol Eksekusi di Kanan
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+${q['exp']} EXP',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${q['gold']} Gold',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF00F4FE),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => handleQuestAction(q),
                          child: Container(
                            width: 96,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? const Color(0xFF2D2736)
                                  : (q['btnColor'] as Color == Colors.transparent
                                      ? const Color(0xFF231B33)
                                      : q['btnColor'] as Color),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDone
                                    ? const Color(0xFF00F4FE)
                                    : (q['btnColor'] as Color == Colors.transparent
                                        ? const Color(0xFFDCB8FC).withValues(alpha: 0.5)
                                        : Colors.transparent),
                              ),
                              boxShadow: isDone
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: (q['btnColor'] as Color == Colors.transparent
                                                ? const Color(0xFFB026FF)
                                                : q['btnColor'] as Color)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 8,
                                      ),
                                    ],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isDone ? Icons.check_circle_rounded : (q['isActionCyan'] == true ? Icons.navigation_rounded : Icons.bolt_rounded),
                                  size: 13,
                                  color: isDone ? const Color(0xFF00F4FE) : q['btnTextColor'] as Color,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isDone ? 'DONE' : q['btnText'] as String,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                    color: isDone ? const Color(0xFF00F4FE) : q['btnTextColor'] as Color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 7. Nearby Gate Detected Callout
  Widget _buildNearbyGateCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        widget.onNavigateToDungeon?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1927),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF383241),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.radar_rounded,
                        size: 14,
                        color: Color(0xFF00F4FE),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'NEARBY GATE DETECTED',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: const Color(0xFF00F4FE),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Rank E Blue Gate ($_formattedGateDistance)',
                    style: GoogleFonts.sora(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE9DEF2),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Area Kampus Terpadu • +50 EXP, +100 Gold',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      color: const Color(0xFF9B8BA1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 96,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF00F4FE),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F4FE).withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.navigation_rounded,
                    size: 13,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'SCOUT',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FAB Kiri: Notifikasi Lonceng
  Widget _buildLeftFab() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF00F4FE).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F4FE).withValues(alpha: 0.25),
            blurRadius: 12,
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.notifications_outlined,
          color: Color(0xFFE9DEF2),
          size: 20,
        ),
        onPressed: () async {
          await NotifService.showQuestReminder();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'SYSTEM ALERT: Notifikasi pengingat quest dikirim ke status bar HP!',
                style: GoogleFonts.spaceGrotesk(fontSize: 12),
              ),
              backgroundColor: const Color(0xFF1F1927),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  /// FAB Kanan: Hunter AI Brain (Neon Violet Glow)
  Widget _buildRightFab() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFB026FF),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB026FF).withValues(alpha: 0.6),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(
          Icons.psychology_rounded,
          color: Colors.white,
          size: 22,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatAiScreen(),
            ),
          );
        },
      ),
    );
  }
}
