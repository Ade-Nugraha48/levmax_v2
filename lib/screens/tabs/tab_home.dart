import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../../models/alarm_model.dart';
import '../../services/alarm_service.dart';
import '../../services/hive_service.dart';
import '../../services/notif_service.dart';
import '../../services/supabase_service.dart';
import '../../services/gemini_service.dart';
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
  String get _currentRankLetter {
    final clean = _rank.replaceAll(RegExp(r'^Rank\s*', caseSensitive: false), '').trim();
    return clean.isEmpty ? 'F' : clean;
  }
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
  DateTime _lastMidnightCheck = DateTime.now();

  bool _isAlarmDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    _checkDailyHpPenalty();
    _loadLocalQuestStatus();
    _syncQuestsFromSupabase();
    _startServerClock();
    _initDungeonGateDistance();
    _setupAlarmListener();
  }

  void _setupAlarmListener() {
    AlarmService.onAlarmStateChanged = () {
      if (mounted) {
        setState(() {});
        if (AlarmService.isRinging) {
          _showAlarmRingingDialog();
        }
      }
    };
    if (AlarmService.isRinging) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showAlarmRingingDialog();
      });
    }
  }

  /// Melakukan pengecekan pergantian hari & penalti pemotongan HP jika quest hari sebelumnya < 3
  void _checkDailyHpPenalty() {
    final now = DateTime.now();
    final todayDateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastLoginDateStr = HiveService.getLastLoginDate();

    if (lastLoginDateStr != null && lastLoginDateStr.isNotEmpty) {
      DateTime? lastDate;
      try {
        lastDate = DateTime.parse(lastLoginDateStr);
      } catch (_) {
        final parts = lastLoginDateStr.split('-');
        if (parts.length >= 3) {
          lastDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
      }

      if (lastDate != null) {
        final bool isDifferentDay = now.year != lastDate.year ||
            now.month != lastDate.month ||
            now.day != lastDate.day;

        if (isDifferentDay) {
          final previousCount = HiveService.getCompletedQuestsTodayCount();

          // Jika jumlah quest hari sebelumnya < 3, kurangi HP sebanyak 1 (minimal 0)
          if (previousCount < 3) {
            final int newHp = (_currentHp - 1).clamp(0, _maxHp);
            setState(() {
              _currentHp = newHp;
            });

            // Simpan perubahan HP ke Hive session
            final session = HiveService.getSession();
            final userId = session['userId']?.toString() ?? 'anonymous';
            final username = session['username']?.toString() ?? _hunterName;
            HiveService.saveSession(
              userId: userId,
              username: username,
              rank: _rank,
              exp: _currentExp,
              gold: _gold,
              hp: newHp,
            );

            // Update ke Supabase jika login
            if (userId != 'anonymous') {
              SupabaseService.updateUserStats(
                userId: userId,
                hp: newHp,
              );
            }

            // Notifikasi UI peringatan penalti HP
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.favorite_border_rounded, color: Color(0xFFFF5252), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'SYSTEM PENALTY: HP berkurang 1! (Menyelesaikan $previousCount/3 quest harian kemarin)',
                            style: GoogleFonts.spaceGrotesk(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF4A0E17),
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            });
          }

          // Reset jumlah quest hari aktif menjadi 0 untuk hari baru
          HiveService.saveCompletedQuestsTodayCount(0);
        }
      }
    }

    // Perbarui tanggal login terakhir menjadi hari ini
    HiveService.saveLastLoginDate(todayDateStr);
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

  /// Memuat status quest yang telah diselesaikan hari ini dari Hive questBox (Local Primary)
  void _loadLocalQuestStatus() {
    final session = HiveService.getSession();
    final userId = session['userId']?.toString() ?? 'anonymous';
    final completed = HiveService.getTodayCompletedQuestIds(userId);
    if (mounted) {
      setState(() {
        _completedQuests.clear();
        _completedQuests.addAll(completed);
      });
      HiveService.saveCompletedQuestsTodayCount(_completedQuests.length);
    }
  }

  /// Sinkronisasi data quest hari ini dari Supabase (Cloud Backup Restore)
  Future<void> _syncQuestsFromSupabase() async {
    final session = HiveService.getSession();
    final userId = session['userId']?.toString();
    if (userId == null || userId == 'anonymous') return;

    try {
      final cloudRecords = await SupabaseService.fetchTodayCompletedQuests(userId: userId);
      if (cloudRecords.isNotEmpty) {
        await HiveService.syncCompletedQuestsFromCloud(
          userId: userId,
          records: cloudRecords,
        );
        if (mounted) {
          _loadLocalQuestStatus();
        }
      }
    } catch (_) {}
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
    final now = DateTime.now();
    // Pengecekan otomatis saat pergantian hari melewati pukul 00:00 (Reset Jam 12 Malam)
    if (now.day != _lastMidnightCheck.day ||
        now.month != _lastMidnightCheck.month ||
        now.year != _lastMidnightCheck.year) {
      _lastMidnightCheck = now;
      _checkDailyHpPenalty();
      _loadLocalQuestStatus();
    }

    final nowUtc = now.toUtc();
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

    final session = HiveService.getSession();
    final latestGold = (session['gold'] as int?) ?? _gold;
    final latestExp = (session['exp'] as int?) ?? _currentExp;

    setState(() {
      _completedQuests.add(qId);
      _currentExp = latestExp + expReward;
      _gold = latestGold + goldReward;
    });

    HiveService.saveCompletedQuestsTodayCount(_completedQuests.length);

    checkRankUp(_currentExp);

    // 1. Simpan langsung ke Hive sessionBox agar real-time listener (Shop & Profile) langsung terpicu
    final sessionBox = Hive.box('sessionBox');
    sessionBox.put('gold', _gold);
    final int currentTotal = (sessionBox.get('total_quests_done', defaultValue: sessionBox.get('quests_done_count', defaultValue: 0)) as num).toInt();
    sessionBox.put('total_quests_done', currentTotal + 1);
    sessionBox.put('quests_done_count', currentTotal + 1);

    // 2. Simpan ke sesi lokal Hive
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

    // 2. Simpan status quest ke Hive questBox (Local Primary)
    HiveService.saveQuestCompletion(
      userId: userId,
      questId: qId,
    );

    // 3. Sinkronisasi asinkron ke Supabase (Cloud Backup jika user login)
    if (userId != 'anonymous') {
      SupabaseService.updateUserStats(
        userId: userId,
        exp: _currentExp,
        gold: _gold,
        rank: _rank,
        hp: _currentHp,
      );
      SupabaseService.backupQuestCompletion(
        userId: userId,
        questId: qId,
      );
      SupabaseService.recordQuestCompleted(
        userId: userId,
        questId: qId,
      );
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
    AlarmService.onAlarmStateChanged = null;
    _homePositionSubscription?.cancel();
    _serverClockTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = HiveService.getSession();
    _avatarUrl = session['avatar_url']?.toString() ?? _avatarUrl;
    _gold = (session['gold'] as int?) ?? _gold;
    _currentExp = (session['exp'] as int?) ?? _currentExp;
    final loadedHp = session['hp'] as int?;
    if (loadedHp != null) {
      _currentHp = loadedHp;
    }

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

                  const SizedBox(height: 12),

                  // 5.1 Tombol LLM Hidden Quest Generator
                  _buildScanHiddenDungeonButton(),

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
    final categories = ['ALL', 'WORKOUT', 'CARDIO', 'STUDY', 'APPEARANCE'];

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
    final safetyCount = completedCount > 3 ? 3 : completedCount;
    final bool isSafe = completedCount >= 3;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 17,
                color: Color(0xFFFF7A00),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  "TODAY'S DAILY QUESTS",
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: const Color(0xFFE9DEF2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
          decoration: BoxDecoration(
            color: isSafe
                ? const Color(0xFF0C242B)
                : const Color(0xFF26121E),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSafe
                  ? const Color(0xFF00F4FE).withValues(alpha: 0.4)
                  : const Color(0xFFFF5252).withValues(alpha: 0.4),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSafe ? Icons.shield_rounded : Icons.shield_outlined,
                size: 11,
                color: isSafe ? const Color(0xFF00F4FE) : const Color(0xFFFF5252),
              ),
              const SizedBox(width: 4),
              Text(
                'Safety: $safetyCount/3  |  Max: $completedCount/7',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: isSafe ? const Color(0xFF00F4FE) : const Color(0xFFFFB4AB),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Data Daily Quests (4 independent Workout quests + Cardio, Appearance, Study)
  static final List<Map<String, dynamic>> _dailyQuestsData = [
    {
      'id': 'pushup',
      'title': 'Push Up (20 Reps)',
      'category': 'WORKOUT',
      'desc': 'Sensor Push-Up Fisik',
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
      'id': 'situp',
      'title': 'Sit Up (20 Reps)',
      'category': 'WORKOUT',
      'desc': 'Penguatan Otot Inti',
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
      'id': 'pullup',
      'title': 'Pull Up (10 Reps)',
      'category': 'WORKOUT',
      'desc': 'Kekuatan Punggung Hunter',
      'exp': 15,
      'gold': 10,
      'icon': Icons.fitness_center_rounded,
      'iconColor': const Color(0xFFE5B5FF),
      'iconBg': const Color(0xFF2D164D),
      'btnText': 'EXECUTE',
      'btnColor': const Color(0xFFB026FF),
      'btnTextColor': Colors.white,
      'isActionCyan': false,
    },
    {
      'id': 'squat',
      'title': 'Squat (30 Reps)',
      'category': 'WORKOUT',
      'desc': 'Ketahanan Otot Kaki',
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
      'desc': 'Target 2.0 KM Radar GPS',
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
      'title': 'Protokol Penampilan',
      'category': 'APPEARANCE',
      'desc': '5 Tahap Grooming Hunter',
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
      'id': 'study_focus',
      'title': 'Fokus Belajar (30 M)',
      'category': 'STUDY',
      'desc': 'Fokus 30 Menit Tenang',
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

  /// 6. Quest Cards Stream
  Widget _buildQuestList() {
    final searchQuery = _searchController.text.trim().toLowerCase();
    final quests = _dailyQuestsData;

    Future<void> handleQuestAction(Map<String, dynamic> q) async {
      final String qId = q['id'] as String;
      final bool isDone = _completedQuests.contains(qId);
      if (isDone) {
        return;
      }

      if (q['category'] == 'WORKOUT') {
        final result = await showModalBottomSheet<Map<String, dynamic>>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: const Color(0xFF08050E),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          clipBehavior: Clip.antiAlias,
          builder: (context) => FractionallySizedBox(
            heightFactor: 0.95,
            child: WorkoutHubScreen(
              initialExercise: qId,
              currentRank: _currentRankLetter,
            ),
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
        return;
      } else if (qId == 'appearance') {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => AppearanceQuestScreen(
              currentRank: _currentRankLetter,
            ),
          ),
        );
        if (result == true) {
          completeQuest(30, 20, qId, q['title'] as String);
        }
      } else if (qId == 'cardio') {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => QuestSensorScreen(
              currentRank: _currentRankLetter,
            ),
          ),
        );
        if (result == true) {
          completeQuest(20, 15, qId, q['title'] as String);
        }
      } else if (qId == 'study_focus' || qId == 'mana_focus') {
        final result = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (context) => StudyFocusScreen(
              currentRank: _currentRankLetter,
            ),
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
          q['category'] == _selectedCategory;
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
              onTap: isDone ? null : () => handleQuestAction(q),
              child: Container(
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF16121D) : const Color(0xFF1F1927),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDone ? const Color(0xFF2C2436) : const Color(0xFF383241),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Kategori di Kiri (40x40)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDone ? const Color(0xFF1A1524) : (q['iconBg'] as Color),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        q['icon'] as IconData,
                        color: isDone ? const Color(0xFF6B6178) : (q['iconColor'] as Color),
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 9),

                    // Judul & Info di Tengah (2 Baris Seragam)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            q['title'] as String,
                            softWrap: true,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.sora(
                              fontSize: 12.8,
                              fontWeight: FontWeight.w700,
                              color: isDone ? const Color(0xFF7E728C) : const Color(0xFFE9DEF2),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 1),
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isDone ? const Color(0xFF1F1A28) : const Color(0xFF2D164D),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  q['category'] as String,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDone ? const Color(0xFF6E637D) : const Color(0xFFE5B5FF),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  q['desc'] as String,
                                  softWrap: true,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.8,
                                    fontWeight: FontWeight.w500,
                                    color: isDone ? const Color(0xFF635870) : const Color(0xFF9B8BA1),
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '+${q['exp']} EXP',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isDone ? const Color(0xFF6E637D) : Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '+${q['gold']} Gold',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: isDone ? const Color(0xFF4A6870) : const Color(0xFF00F4FE),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: isDone ? null : () => handleQuestAction(q),
                          child: Container(
                            width: 82,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? const Color(0xFF201B28)
                                  : (q['btnColor'] as Color == Colors.transparent
                                      ? const Color(0xFF231B33)
                                      : q['btnColor'] as Color),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDone
                                    ? const Color(0xFF352D40)
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
                                  isDone
                                      ? Icons.check_circle_rounded
                                      : (q['isActionCyan'] == true
                                          ? Icons.navigation_rounded
                                          : Icons.bolt_rounded),
                                  size: 12,
                                  color: isDone ? const Color(0xFF8B8097) : q['btnTextColor'] as Color,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  isDone ? 'COMPLETED' : q['btnText'] as String,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 9.0,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                    color: isDone ? const Color(0xFF8B8097) : q['btnTextColor'] as Color,
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

  /// Tombol Scan Hidden Dungeon berbasis Gemini LLM
  Widget _buildScanHiddenDungeonButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF28071E),
            Color(0xFF1E0A2D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFFF0055).withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF0055).withValues(alpha: 0.28),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFFB026FF).withValues(alpha: 0.2),
            blurRadius: 22,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _handleScanHiddenDungeon,
          splashColor: const Color(0xFFFF0055).withValues(alpha: 0.25),
          highlightColor: const Color(0xFFB026FF).withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Neon Red / Purple Orbital Radar Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFF0055),
                        Color(0xFFB026FF),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF0055).withValues(alpha: 0.55),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.radar_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                // Text Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'SCAN HIDDEN DUNGEON',
                              style: GoogleFonts.orbitron(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                                color: const Color(0xFFFF2A6D),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB026FF).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFB026FF).withValues(alpha: 0.6),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              'LLM',
                              style: GoogleFonts.orbitron(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFE5B5FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Pindai fluktuasi Mana rahasia menggunakan Gemini AI Engine',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFC0B4CE),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFFFF2A6D),
                  size: 15,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handler pemindaian hidden dungeon menggunakan Gemini LLM
  Future<void> _handleScanHiddenDungeon() async {
    // 1. Tampilkan dialog loading "Mendeteksi gelombang mana..."
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (loadingCtx) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: const Color(0xFF140D22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF0055),
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF0055).withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF0055)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'MENDETEKSI GELOMBANG MANA...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: const Color(0xFFFF0055),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Menghubungkan ke Gemini LLM Gateway untuk mengurai koordinat dungeon rahasia...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFFB5A9C2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // 2. Panggil GeminiService.generateHiddenQuest dengan data rank & exp hunter
      final questText = await GeminiService.generateHiddenQuest(_rank, _currentExp);

      // 3. Tutup dialog loading
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      // 4. Tampilkan AlertDialog hasil generate LLM bergaya Solo Leveling
      _showHiddenQuestResultDialog(questText);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      _showHiddenQuestResultDialog('Gagal memindai gelombang mana: $e');
    }
  }

  /// Menampilkan dialog hasil generate Hidden Quest dari Gemini LLM
  void _showHiddenQuestResultDialog(String questText) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF140D22),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFFF0055),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF0055).withValues(alpha: 0.4),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: const Color(0xFFB026FF).withValues(alpha: 0.25),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Bar Icon & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF0055).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFF0055).withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Icon(
                        Icons.crisis_alert_rounded,
                        color: Color(0xFFFF0055),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HIDDEN QUEST DETECTED',
                            style: GoogleFonts.orbitron(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: const Color(0xFFFF0055),
                            ),
                          ),
                          Text(
                            'Sistem Peringatan Gerbang Darurat (LLM)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE5B5FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(color: Color(0xFF2C1E4E), height: 1),
                const SizedBox(height: 14),

                // Quest Content Container
                Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B112B),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFB026FF).withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      questText,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF3EFF5),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Tombol TUTUP
                SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0055),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: const Color(0xFFFF0055).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'TUTUP',
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  /// FAB Kiri: Hunter System Awakening Alarm
  Widget _buildLeftFab() {
    final alarm = HiveService.getAlarm();
    final bool isAlarmOn = alarm.isEnabled;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        shape: BoxShape.circle,
        border: Border.all(
          color: isAlarmOn
              ? const Color(0xFF00F4FE)
              : const Color(0xFF00F4FE).withValues(alpha: 0.3),
          width: isAlarmOn ? 1.6 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isAlarmOn
                ? const Color(0xFF00F4FE).withValues(alpha: 0.45)
                : const Color(0xFF00F4FE).withValues(alpha: 0.15),
            blurRadius: isAlarmOn ? 14 : 8,
            spreadRadius: isAlarmOn ? 1 : 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            tooltip: 'Hunter System Awakening Alarm',
            icon: Icon(
              isAlarmOn ? Icons.alarm_on_rounded : Icons.alarm_rounded,
              color: isAlarmOn ? const Color(0xFF00F4FE) : const Color(0xFF9B8BA1),
              size: 20,
            ),
            onPressed: () => _openAlarmSettingModal(context),
          ),
          if (isAlarmOn)
            Positioned(
              top: 7,
              right: 7,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF00F4FE),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF00F4FE),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Helper untuk menghitung estimasi waktu berdering
  String _getRemainingAlarmText(int hour, int minute) {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, hour, minute);
    if (target.isBefore(now)) {
      target = target.add(const Duration(days: 1));
    }
    final diff = target.difference(now);
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (h == 0 && m == 0) return 'Berdering kurang dari 1 menit lagi';
    if (h == 0) return 'Berdering dalam $m menit ke depan';
    return 'Berdering dalam $h jam $m menit ke depan';
  }

  /// Membuka Hub Pengaturan Hunter System Alarm
  void _openAlarmSettingModal(BuildContext context) {
    final initialAlarm = HiveService.getAlarm();
    int selectedHour = initialAlarm.hour;
    int selectedMinute = initialAlarm.minute;
    bool isEnabled = initialAlarm.isEnabled;
    double volume = initialAlarm.volume;
    String ringtoneName = initialAlarm.ringtoneName;
    String? ringtonePath = initialAlarm.ringtonePath;
    bool vibrate = initialAlarm.vibrate;
    final labelCtrl = TextEditingController(text: initialAlarm.label);
    bool isPreviewing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      elevation: 0,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            final screenHeight = MediaQuery.of(dialogCtx).size.height;
            final isKeyboardOpen = MediaQuery.of(dialogCtx).viewInsets.bottom > 0;

            return Material(
              color: Colors.transparent,
              child: Container(
                height: isKeyboardOpen ? screenHeight * 0.95 : screenHeight * 0.88,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF110C19),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: const Color(0xFF00F4FE).withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F4FE).withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF383241),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF00F4FE).withValues(alpha: 0.4),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.alarm_rounded,
                                  color: Color(0xFF00F4FE),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HUNTER AWAKENING ALARM',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: const Color(0xFF00F4FE),
                                    ),
                                  ),
                                  Text(
                                    'Standar Alarm & Protokol Bangkit Harian',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF9B8BA1),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF9B8BA1), size: 20),
                            onPressed: () {
                              AlarmService.stopPreview();
                              Navigator.pop(sheetContext);
                            },
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Color(0xFF2C1E4E), height: 1),

                    // Content Scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Status Toggle & Countdown Banner
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F1927),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isEnabled
                                      ? const Color(0xFF00F4FE).withValues(alpha: 0.5)
                                      : const Color(0xFF2C1E4E),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isEnabled ? const Color(0xFF00F4FE) : const Color(0xFF70657B),
                                      boxShadow: isEnabled
                                          ? [
                                              const BoxShadow(
                                                color: Color(0xFF00F4FE),
                                                blurRadius: 6,
                                                spreadRadius: 1,
                                              ),
                                            ]
                                          : [],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isEnabled ? 'ALARM AKTIF' : 'ALARM NONAKTIF',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                            color: isEnabled ? const Color(0xFF00F4FE) : const Color(0xFF9B8BA1),
                                          ),
                                        ),
                                        Text(
                                          isEnabled
                                              ? _getRemainingAlarmText(selectedHour, selectedMinute)
                                              : 'Nyalakan switch untuk mengaktifkan jadwal alarm.',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10.5,
                                            color: isEnabled ? const Color(0xFFD4C7E3) : const Color(0xFF70657B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isEnabled,
                                    activeThumbColor: const Color(0xFF00F4FE),
                                    activeTrackColor: const Color(0xFF00F4FE).withValues(alpha: 0.3),
                                    inactiveThumbColor: const Color(0xFF70657B),
                                    inactiveTrackColor: const Color(0xFF2C1E4E),
                                    onChanged: (val) {
                                      setModalState(() => isEnabled = val);
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 2. Large Digital Time Display & Picker
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF171022),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF2C1E4E),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'WAKTU ALARM (FORMAT 24 JAM)',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.6,
                                          color: const Color(0xFFE5B5FF),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final picked = await showTimePicker(
                                            context: dialogCtx,
                                            initialTime: TimeOfDay(hour: selectedHour, minute: selectedMinute),
                                            builder: (ctx, child) {
                                              return Theme(
                                                data: ThemeData.dark().copyWith(
                                                  colorScheme: const ColorScheme.dark(
                                                    primary: Color(0xFF00F4FE),
                                                    onPrimary: Color(0xFF0D0814),
                                                    surface: Color(0xFF1A1325),
                                                    onSurface: Color(0xFFE9DEF2),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          if (picked != null) {
                                            setModalState(() {
                                              selectedHour = picked.hour;
                                              selectedMinute = picked.minute;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: const Color(0xFF00F4FE).withValues(alpha: 0.4),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF00F4FE)),
                                              const SizedBox(width: 4),
                                              Text(
                                                'DIAL PICKER',
                                                style: GoogleFonts.spaceGrotesk(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF00F4FE),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Clock Display & Steppers
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Hour Block
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF00F4FE)),
                                            onPressed: () {
                                              setModalState(() {
                                                selectedHour = (selectedHour + 1) % 24;
                                              });
                                            },
                                          ),
                                          Container(
                                            width: 82,
                                            height: 72,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1F1927),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFF00F4FE).withValues(alpha: 0.6),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              selectedHour.toString().padLeft(2, '0'),
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 42,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00F4FE)),
                                            onPressed: () {
                                              setModalState(() {
                                                selectedHour = (selectedHour - 1 + 24) % 24;
                                              });
                                            },
                                          ),
                                          Text(
                                            'JAM',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF9B8BA1),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Colon Separator
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                                        child: Text(
                                          ':',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 42,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF00F4FE),
                                          ),
                                        ),
                                      ),

                                      // Minute Block
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.keyboard_arrow_up_rounded, color: Color(0xFF00F4FE)),
                                            onPressed: () {
                                              setModalState(() {
                                                selectedMinute = (selectedMinute + 1) % 60;
                                              });
                                            },
                                          ),
                                          Container(
                                            width: 82,
                                            height: 72,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1F1927),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: const Color(0xFF00F4FE).withValues(alpha: 0.6),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              selectedMinute.toString().padLeft(2, '0'),
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 42,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00F4FE)),
                                            onPressed: () {
                                              setModalState(() {
                                                selectedMinute = (selectedMinute - 1 + 60) % 60;
                                              });
                                            },
                                          ),
                                          Text(
                                            'MENIT',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF9B8BA1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 10),

                                  // Quick Presets
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 6,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      for (final preset in [
                                        const TimeOfDay(hour: 5, minute: 0),
                                        const TimeOfDay(hour: 6, minute: 0),
                                        const TimeOfDay(hour: 7, minute: 0),
                                        const TimeOfDay(hour: 21, minute: 0),
                                        const TimeOfDay(hour: 22, minute: 0),
                                        const TimeOfDay(hour: 23, minute: 0),
                                      ])
                                        GestureDetector(
                                          onTap: () {
                                            setModalState(() {
                                              selectedHour = preset.hour;
                                              selectedMinute = preset.minute;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: (selectedHour == preset.hour && selectedMinute == preset.minute)
                                                  ? const Color(0xFF00F4FE).withValues(alpha: 0.2)
                                                  : const Color(0xFF1F1927),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: (selectedHour == preset.hour && selectedMinute == preset.minute)
                                                  ? const Color(0xFF00F4FE)
                                                  : const Color(0xFF2C1E4E),
                                              ),
                                            ),
                                            child: Text(
                                              '${preset.hour.toString().padLeft(2, '0')}:${preset.minute.toString().padLeft(2, '0')}',
                                              style: GoogleFonts.spaceGrotesk(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: (selectedHour == preset.hour && selectedMinute == preset.minute)
                                                    ? const Color(0xFF00F4FE)
                                                    : const Color(0xFFB5A9C2),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 3. Custom Ringtone Selector (MP3 Lokal & Default Solo Leveling Siren)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF171022),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF2C1E4E),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'RINGTONE / NADA ALARM',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.6,
                                          color: const Color(0xFFE5B5FF),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (ringtonePath != null && ringtonePath!.isNotEmpty)
                                              ? const Color(0xFFB026FF).withValues(alpha: 0.2)
                                              : const Color(0xFF00F4FE).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          (ringtonePath != null && ringtonePath!.isNotEmpty)
                                              ? 'MP3 LOKAL'
                                              : 'SYSTEM DEFAULT',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: (ringtonePath != null && ringtonePath!.isNotEmpty)
                                                ? const Color(0xFFB026FF)
                                                : const Color(0xFF00F4FE),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Ringtone Name Display
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1F1927),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xFF2C1E4E)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          (ringtonePath != null && ringtonePath!.isNotEmpty)
                                              ? Icons.audio_file_rounded
                                              : Icons.graphic_eq_rounded,
                                          size: 18,
                                          color: const Color(0xFF00F4FE),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            ringtoneName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFFE9DEF2),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Buttons Row: Pick MP3, Reset Default, Preview
                                  Row(
                                    children: [
                                      // Pick MP3 File
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFB026FF),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            elevation: 0,
                                          ),
                                          icon: const Icon(Icons.file_upload_outlined, size: 16),
                                          label: Text(
                                            'PILIH MP3',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          onPressed: () async {
                                            try {
                                              final res = await FilePicker.pickFiles(
                                                type: FileType.custom,
                                                allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg'],
                                              );
                                              if (res.isNotEmpty && res.first.path != null) {
                                                final f = res.first;
                                                setModalState(() {
                                                  ringtoneName = f.name;
                                                  ringtonePath = f.path;
                                                });
                                                if (isPreviewing) {
                                                  await AlarmService.stopPreview();
                                                  setModalState(() => isPreviewing = false);
                                                }
                                              }
                                            } catch (e) {
                                              debugPrint('Pick file error: $e');
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Reset to Default
                                      if (ringtonePath != null && ringtonePath!.isNotEmpty) ...[
                                        IconButton(
                                          tooltip: 'Kembali ke Default Siren',
                                          style: IconButton.styleFrom(
                                            backgroundColor: const Color(0xFF1F1927),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              side: const BorderSide(color: Color(0xFF2C1E4E)),
                                            ),
                                          ),
                                          icon: const Icon(Icons.restart_alt_rounded, color: Color(0xFF9B8BA1), size: 18),
                                          onPressed: () async {
                                            setModalState(() {
                                              ringtoneName = 'Solo Leveling Siren System (Default WAV)';
                                              ringtonePath = null;
                                            });
                                            if (isPreviewing) {
                                              await AlarmService.stopPreview();
                                              setModalState(() => isPreviewing = false);
                                            }
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                      ],

                                      // Preview Button
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isPreviewing
                                              ? const Color(0xFFFF2A6D)
                                              : const Color(0xFF00F4FE).withValues(alpha: 0.15),
                                          foregroundColor: isPreviewing ? Colors.white : const Color(0xFF00F4FE),
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            side: BorderSide(
                                              color: isPreviewing
                                                  ? const Color(0xFFFF2A6D)
                                                  : const Color(0xFF00F4FE).withValues(alpha: 0.5),
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        icon: Icon(
                                          isPreviewing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                                          size: 18,
                                        ),
                                        label: Text(
                                          isPreviewing ? 'STOP' : 'TEST',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (isPreviewing) {
                                            await AlarmService.stopPreview();
                                            setModalState(() => isPreviewing = false);
                                          } else {
                                            setModalState(() => isPreviewing = true);
                                            await AlarmService.previewRingtone(
                                              ringtonePath: ringtonePath,
                                              volume: volume,
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 4. Custom Volume Control (0% - 100%)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF171022),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF2C1E4E),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            volume == 0
                                                ? Icons.volume_off_rounded
                                                : volume < 0.5
                                                    ? Icons.volume_down_rounded
                                                    : Icons.volume_up_rounded,
                                            size: 18,
                                            color: const Color(0xFF00F4FE),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'INTENSITAS VOLUME',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.6,
                                              color: const Color(0xFFE5B5FF),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        '${(volume * 100).toInt()}%',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF00F4FE),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  SliderTheme(
                                    data: SliderTheme.of(dialogCtx).copyWith(
                                      activeTrackColor: const Color(0xFF00F4FE),
                                      inactiveTrackColor: const Color(0xFF2C1E4E),
                                      thumbColor: const Color(0xFF00F4FE),
                                      overlayColor: const Color(0xFF00F4FE).withValues(alpha: 0.2),
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                      trackHeight: 4,
                                    ),
                                    child: Slider(
                                      value: volume,
                                      min: 0.0,
                                      max: 1.0,
                                      divisions: 100,
                                      onChanged: (val) {
                                        setModalState(() => volume = val);
                                        if (isPreviewing) {
                                          AlarmService.previewRingtone(ringtonePath: ringtonePath, volume: val);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 5. Vibrate & Alarm Label
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF171022),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF2C1E4E),
                                  width: 1.2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.vibration_rounded, size: 18, color: Color(0xFF00F4FE)),
                                          const SizedBox(width: 8),
                                          Text(
                                            'GETAR SAAT ALARM BERBUNYI',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.6,
                                              color: const Color(0xFFE5B5FF),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Switch(
                                        value: vibrate,
                                        activeThumbColor: const Color(0xFF00F4FE),
                                        activeTrackColor: const Color(0xFF00F4FE).withValues(alpha: 0.3),
                                        inactiveThumbColor: const Color(0xFF70657B),
                                        inactiveTrackColor: const Color(0xFF2C1E4E),
                                        onChanged: (val) => setModalState(() => vibrate = val),
                                      ),
                                    ],
                                  ),
                                  const Divider(color: Color(0xFF2C1E4E), height: 16),
                                  Text(
                                    'LABEL ALARM',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF9B8BA1),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: labelCtrl,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12.5,
                                      color: const Color(0xFFE9DEF2),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Cth: Quest Harian: Waktunya Bangkit!',
                                      hintStyle: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: const Color(0xFF70657B),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFF1F1927),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Color(0xFF2C1E4E)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Color(0xFF2C1E4E)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(color: Color(0xFF00F4FE)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 6. Action Buttons: Simpan Alarm & Uji Sekarang
                            Row(
                              children: [
                                // Uji Alarm Sekarang Button
                                Expanded(
                                  flex: 1,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFFF2A6D),
                                      side: const BorderSide(color: Color(0xFFFF2A6D), width: 1.4),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      final testAlarm = AlarmModel(
                                        id: initialAlarm.id,
                                        hour: selectedHour,
                                        minute: selectedMinute,
                                        isEnabled: true,
                                        label: labelCtrl.text.trim().isEmpty ? 'Uji Alarm Hunter' : labelCtrl.text.trim(),
                                        ringtoneName: ringtoneName,
                                        ringtonePath: ringtonePath,
                                        volume: volume,
                                        vibrate: vibrate,
                                      );
                                      await AlarmService.stopPreview();
                                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                                      await AlarmService.triggerAlarm(alarm: testAlarm);
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.bolt_rounded, size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          'UJI ALARM',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Simpan Alarm Button
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00F4FE),
                                      foregroundColor: const Color(0xFF0D0814),
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 6,
                                      shadowColor: const Color(0xFF00F4FE).withValues(alpha: 0.5),
                                    ),
                                    onPressed: () async {
                                      final updatedAlarm = AlarmModel(
                                        id: initialAlarm.id,
                                        hour: selectedHour,
                                        minute: selectedMinute,
                                        isEnabled: isEnabled,
                                        label: labelCtrl.text.trim().isEmpty ? 'Waktunya Bangkit!' : labelCtrl.text.trim(),
                                        ringtoneName: ringtoneName,
                                        ringtonePath: ringtonePath,
                                        volume: volume,
                                        vibrate: vibrate,
                                      );

                                      final messenger = ScaffoldMessenger.of(context);
                                      await AlarmService.stopPreview();
                                      await AlarmService.scheduleAlarm(updatedAlarm);

                                      if (sheetContext.mounted) Navigator.pop(sheetContext);
                                      if (mounted) {
                                        setState(() {});
                                        messenger.showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isEnabled
                                                  ? '⏰ Alarm berhasil diset untuk ${updatedAlarm.formattedTime} WIB (${_getRemainingAlarmText(selectedHour, selectedMinute)})'
                                                  : '🔕 Alarm dinonaktifkan.',
                                              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
                                            ),
                                            backgroundColor: isEnabled ? const Color(0xFF00F4FE) : const Color(0xFF70657B),
                                          ),
                                        );
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.save_rounded, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          'SIMPAN ALARM',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 18),

                            // 7. Akses ke 5 Notifikasi Push Sistem (Tetap Tersedia)
                            Center(
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF9B8BA1),
                                ),
                                icon: const Icon(Icons.notifications_active_outlined, size: 16),
                                label: Text(
                                  'Akses 5 Protokol Push Notifikasi Sistem',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                onPressed: () {
                                  AlarmService.stopPreview();
                                  Navigator.pop(sheetContext);
                                  _openNotificationHubModal(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      AlarmService.stopPreview();
    });
  }

  /// Dialog Layar Penuh Saat Alarm Sedang Berdering (Awakening Alarm Screen)
  void _showAlarmRingingDialog() {
    if (_isAlarmDialogShowing || !mounted) return;
    _isAlarmDialogShowing = true;

    final alarm = HiveService.getAlarm();
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF140D22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF00F4FE),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F4FE).withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing icon
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                      border: Border.all(
                        color: const Color(0xFF00F4FE),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F4FE).withValues(alpha: 0.4),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.alarm_on_rounded,
                      color: Color(0xFF00F4FE),
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF2A6D).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFF2A6D).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      '🚨 PROTOKOL AWAKENING: ALARM AKTIF',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: const Color(0xFFFF2A6D),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Big Digital Time
                  Text(
                    timeStr,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Alarm Label
                  Text(
                    alarm.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00F4FE),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Ringtone info badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1927),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF2C1E4E),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.music_note_rounded, size: 14, color: Color(0xFFE5B5FF)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            alarm.ringtoneName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: const Color(0xFFD4C7E3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(alarm.volume * 100).toInt()}% Vol',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00F4FE),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Dismiss button: BANGKIT
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00F4FE),
                        foregroundColor: const Color(0xFF0D0814),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                        shadowColor: const Color(0xFF00F4FE).withValues(alpha: 0.5),
                      ),
                      onPressed: () async {
                        await AlarmService.stopAlarm();
                        _isAlarmDialogShowing = false;
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'BANGKIT (MATIKAN ALARM)',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Snooze button
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD4C7E3),
                        side: const BorderSide(
                          color: Color(0xFF2C1E4E),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
                        final snoozed = alarm.copyWith(
                          hour: snoozeTime.hour,
                          minute: snoozeTime.minute,
                          isEnabled: true,
                        );
                        await AlarmService.stopAlarm();
                        await AlarmService.scheduleAlarm(snoozed);
                        _isAlarmDialogShowing = false;
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '💤 Alarm ditunda 5 menit (${DateFormat('HH:mm').format(snoozeTime)} WIB)',
                                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
                              ),
                              backgroundColor: const Color(0xFFB026FF),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'TUNDA 5 MENIT (SNOOZE)',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFB5A9C2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Membuka Hub Pengaturan & Pengujian 5 Protokol Notifikasi Hunter (Sub-Terminal)
  void _openNotificationHubModal(BuildContext context) {
    final persona = HiveService.getAIPersona();
    final String aiName = persona.name;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      elevation: 0,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (dialogCtx, setModalState) {
            final screenHeight = MediaQuery.of(dialogCtx).size.height;
            return Material(
              color: Colors.transparent,
              child: Container(
                height: screenHeight * 0.88,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF110C19),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  border: Border.all(
                    color: const Color(0xFF00F4FE).withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F4FE).withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF383241),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF00F4FE).withValues(alpha: 0.4),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.notifications_active_rounded,
                                  color: Color(0xFF00F4FE),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HUNTER NOTIFICATION HUB',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                      color: const Color(0xFF00F4FE),
                                    ),
                                  ),
                                  Text(
                                    '5 Protokol Peringatan Sistem Solo Leveling',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF9B8BA1),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFF9B8BA1), size: 20),
                            onPressed: () => Navigator.pop(sheetContext),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Color(0xFF2C1E4E), height: 1),

                    // Content Scrollable
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Banner
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1F1927),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF00F4FE).withValues(alpha: 0.3),
                                  width: 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF00F4FE),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF00F4FE),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'AUTO-SCHEDULER: AKTIF',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF00F4FE),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        Text(
                                          '5 jadwal notifikasi otomatis aktif di latar belakang perangkat ponsel.',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            color: const Color(0xFFD4C7E3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      await NotifService.scheduleAllAutomatedNotifications();
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '5 Jadwal Notifikasi Berhasil Disinkronkan!',
                                            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
                                          ),
                                          backgroundColor: const Color(0xFF00F4FE),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
                                        ),
                                      ),
                                      child: Text(
                                        'SYNC',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFF00F4FE),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            Text(
                              'PENGUJIAN INSTAN & DAFTAR JADWAL (5 SKENARIO)',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: const Color(0xFFE5B5FF),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 1. Reset Quest Harian
                            _buildNotifCard(
                              number: '01',
                              icon: Icons.restart_alt_rounded,
                              iconColor: const Color(0xFF00F4FE),
                              title: 'Reset Quest Harian',
                              schedule: 'Setiap 00:00 (Tengah Malam)',
                              desc: 'Pemberitahuan saat jam server berganti hari dan seluruh quest & dungeon disegarkan.',
                              onTest: () async {
                                await NotifService.showDailyResetNotif();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('⚡ Notifikasi Reset Quest Harian terkirim ke status bar!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),

                            // 2. Aktivitas Tertunda
                            _buildNotifCard(
                              number: '02',
                              icon: Icons.warning_amber_rounded,
                              iconColor: const Color(0xFFFFB800),
                              title: 'Aktivitas Belum Dijalankan',
                              schedule: 'Setiap 14:00 (Siang Hari)',
                              desc: 'Peringatan jika Quest Fisik, Dungeon Radar, atau Latihan Mana belum tuntas hari ini.',
                              onTest: () async {
                                await NotifService.showUnfinishedActivitiesNotif();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('⚠️ Notifikasi Aktivitas Tertunda terkirim ke status bar!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),

                            // 3. Quest Belum Dijalankan Tiap 3 Jam
                            _buildNotifCard(
                              number: '03',
                              icon: Icons.timer_rounded,
                              iconColor: const Color(0xFFFF4081),
                              title: 'Pengingat Berkala Tiap 3 Jam',
                              schedule: 'Interval 3 Jam (09:00, 12:00, 15:00, 18:00, 21:00)',
                              desc: 'Peringatan berulang tiap 3 jam server jika quest masih tertunda untuk mencegah penalti HP.',
                              onTest: () async {
                                await NotifService.showPeriodicQuestReminderNotif();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('⚔️ Notifikasi Siklus 3 Jam terkirim ke status bar!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),

                            // 4. AI Kangen User
                            _buildNotifCard(
                              number: '04',
                              icon: Icons.favorite_rounded,
                              iconColor: const Color(0xFFB026FF),
                              title: '[$aiName] Kangen User',
                              schedule: 'Setiap 19:30 (Malam Hari)',
                              desc: 'Pesan personal dari AI pendamping Anda ($aiName) untuk kembali berlatih bersama.',
                              onTest: () async {
                                await NotifService.showAiMissesUserNotif();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('💬 Notifikasi [$aiName Kangen] terkirim ke status bar!'),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),

                            // 5. Hari Ingin Berakhir
                            _buildNotifCard(
                              number: '05',
                              icon: Icons.hourglass_bottom_rounded,
                              iconColor: const Color(0xFFFF2A6D),
                              title: 'Hari / Server Ingin Berakhir',
                              schedule: 'Setiap 23:00 (1 Jam Sebelum 00:00)',
                              desc: 'Peringatan darurat sebelum pergantian hari untuk menghindari Penalty Quest.',
                              onTest: () async {
                                await NotifService.showEndOfDayWarningNotif();
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🚨 Notifikasi Peringatan Akhir Hari terkirim ke status bar!'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Helper Card untuk masing-masing skenario notifikasi
  Widget _buildNotifCard({
    required String number,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String schedule,
    required String desc,
    required VoidCallback onTest,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171022),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE9DEF2),
                      ),
                    ),
                    Text(
                      schedule,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onTest,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.send_rounded, size: 12, color: iconColor),
                      const SizedBox(width: 4),
                      Text(
                        'TES NOTIF',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: iconColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10.5,
              color: const Color(0xFF9B8BA1),
              height: 1.35,
            ),
          ),
        ],
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
