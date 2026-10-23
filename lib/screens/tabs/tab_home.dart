import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';

/// Tab 1: Dashboard Hunter, HUD Status, Daftar Quest Harian, dan Server Time Real-time
class TabHome extends StatefulWidget {
  const TabHome({super.key});

  @override
  State<TabHome> createState() => _TabHomeState();
}

class _TabHomeState extends State<TabHome> {
  // Variabel State Hunter (Diambil dari HiveSession & disiapkan untuk sinkronisasi Supabase)
  String _hunterName = 'Sung Jin-Woo';
  String _rank = 'F';
  int _currentExp = 0;
  final int _maxExp = 100;
  int _currentHp = 3;
  final int _maxHp = 3;
  int _gold = 0;
  String? _userId;

  // Real-time Server Clock 4 Zona (WIB, WITA, WIT, London GMT)
  Timer? _serverClockTimer;
  String _wibTime = '--:--:--';
  String _witaTime = '--:--:--';
  String _witTime = '--:--:--';
  String _gmtTime = '--:--:--';

  // Filter Kategori & Pencarian Quest
  String _selectedCategory = 'All Quests';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserSession();
    _initServerClock();
    _fetchUserDataFromSupabase();
  }

  /// Memuat data username dan statistik Hunter dari Hive sessionBox
  void _loadUserSession() {
    final session = HiveService.getSession();
    final savedUsername = session['username']?.toString();
    if (savedUsername != null && savedUsername.isNotEmpty) {
      _hunterName = savedUsername;
    }
    _rank = session['rank']?.toString() ?? 'F';
    _currentExp = (session['exp'] as int?) ?? 0;
    _gold = (session['gold'] as int?) ?? 0;
    _currentHp = (session['hp'] as int?) ?? 3;
    _userId = session['userId']?.toString();
  }

  /// Menginisialisasi timer detik untuk jam server 4 zona
  void _initServerClock() {
    _updateServerTimes();
    _serverClockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateServerTimes();
    });
  }

  /// Mengonversi waktu sistem saat ini ke UTC, lalu mengkalkulasi UTC+7, UTC+8, UTC+9, dan UTC+0
  void _updateServerTimes() {
    final nowUtc = DateTime.now().toUtc();
    final wib = nowUtc.add(const Duration(hours: 7));
    final wita = nowUtc.add(const Duration(hours: 8));
    final wit = nowUtc.add(const Duration(hours: 9));
    final gmt = nowUtc;

    final formatter = DateFormat('HH:mm:ss');
    if (mounted) {
      setState(() {
        _wibTime = formatter.format(wib);
        _witaTime = formatter.format(wita);
        _witTime = formatter.format(wit);
        _gmtTime = formatter.format(gmt);
      });
    }
  }

  /// Disiapkan untuk fetch data statistik Hunter terbaru dari database Supabase
  Future<void> _fetchUserDataFromSupabase() async {
    if (_userId == null) return;
    try {
      final data = await SupabaseService.client
          .from('users')
          .select('username, rank, exp, gold, hp')
          .eq('id', _userId!)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          if (data['username'] != null) _hunterName = data['username'].toString();
          if (data['rank'] != null) _rank = data['rank'].toString();
          if (data['exp'] != null) _currentExp = (data['exp'] as num).toInt();
          if (data['gold'] != null) _gold = (data['gold'] as num).toInt();
          if (data['hp'] != null) _currentHp = (data['hp'] as num).toInt();
        });

        // Sinkronkan ke session box lokal
        await HiveService.saveSession(
          userId: _userId!,
          username: _hunterName,
          rank: _rank,
          exp: _currentExp,
          gold: _gold,
          hp: _currentHp,
        );
      }
    } catch (e) {
      debugPrint('TabHome: Note fetch Supabase -> $e');
    }
  }

  @override
  void dispose() {
    // Membatalkan timer real-time clock untuk mencegah memory leak
    _serverClockTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0713), // Deep Abyss Black
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Awakened HUD Header
              _buildAwakenedHudHeader(),

              const SizedBox(height: 12),

              // 2. Server Time Banner (WIB | WITA | WIT | GMT)
              _buildServerTimeBanner(),

              const SizedBox(height: 14),

              // 3. Quick System Status & Daily Reset Countdown Notice
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF140D28),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF2C1E4E),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.manaCyan,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.manaCyan,
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'DAILY QUESTS ASSIGNED: Complete min. 3 quests to protect HP from penalty.',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFD8B4F8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 4. Search and Filter Bar
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF120D24),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF24193F),
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          color: Color(0xFFF3EFF5),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Cari nama quest...',
                          hintStyle: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 11,
                            color: Color(0xFF5D5373),
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: Color(0xFF8B829E),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF120D24),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF24193F),
                          width: 1.0,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          dropdownColor: const Color(0xFF160F2C),
                          icon: const Icon(
                            Icons.tune_rounded,
                            size: 16,
                            color: Color(0xFFB026FF),
                          ),
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF3EFF5),
                          ),
                          items: <String>['All Quests', 'Workout', 'Cardio', 'Study', 'Skin']
                              .map<DropdownMenuItem<String>>((String val) {
                            return DropdownMenuItem<String>(
                              value: val,
                              child: Text(val),
                            );
                          }).toList(),
                          onChanged: (String? newVal) {
                            if (newVal != null) {
                              setState(() {
                                _selectedCategory = newVal;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 5. Daily Quest Section Preview
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: Color(0xFFFF4D6D),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'TODAY\'S DAILY QUESTS',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Color(0xFFF3EFF5),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '0 / 4 DONE',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B829E),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Sample Quest Cards preview
              _buildQuestCard(
                title: 'Push Up Protocol',
                req: '20 Repetisi Terverifikasi Sensor Proximity',
                expReward: '+10 EXP',
                goldReward: '+5 Gold',
                tag: 'WORKOUT',
                tagColor: const Color(0xFFB026FF),
                icon: Icons.fitness_center_rounded,
              ),
              const SizedBox(height: 8),
              _buildQuestCard(
                title: 'Cardio Shake',
                req: 'Guncang HP 50x untuk membangkitkan mana hunter',
                expReward: '+20 EXP',
                goldReward: '+15 Gold',
                tag: 'CARDIO',
                tagColor: AppColors.manaCyan,
                icon: Icons.vibration_rounded,
              ),
              const SizedBox(height: 8),
              _buildQuestCard(
                title: 'Mana Knowledge Focus',
                req: 'Fokus Belajar / Baca Materi 30 Menit',
                expReward: '+15 EXP',
                goldReward: '+10 Gold',
                tag: 'STUDY',
                tagColor: const Color(0xFFFFD166),
                icon: Icons.auto_stories_rounded,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// 1. Awakened HUD Header
  Widget _buildAwakenedHudHeader() {
    final double expProgress = _maxExp > 0 ? (_currentExp / _maxExp).clamp(0.0, 1.0) : 0.0;
    final String rankLabel = _rank.toUpperCase().startsWith('RANK')
        ? _rank.toUpperCase()
        : 'Rank ${_rank.toUpperCase()}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF120D24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Row 1: Avatar + Name + Rank Badge
          Row(
            children: [
              // Hunter Avatar (Kiri)
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A1233),
                      border: Border.all(
                        color: const Color(0xFF8A2BE2),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8A2BE2).withOpacity(0.4),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_rounded,
                        size: 28,
                        color: Color(0xFFD8B4F8),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF0B0713),
                    ),
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.manaCyan,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // Name & System Codename
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _hunterName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                              color: Color(0xFFF3EFF5),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.manaCyan,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'NODE PROTOCOL: SYSTEM AWAKENED',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: Color(0xFF8B829E),
                      ),
                    ),
                  ],
                ),
              ),

              // Rank Status Badge dengan Pendar Shadow Monarch Purple (#8A2BE2)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B0E33),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF8A2BE2),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A2BE2).withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.military_tech_rounded,
                      size: 14,
                      color: Color(0xFFB026FF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rankLabel,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: Color(0xFFF3EFF5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: Status Baris Bawah (3 HP + Gold Counter)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Indikator 3 HP (Health Points)
              Row(
                children: [
                  const Text(
                    'HP:',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFF8B829E),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Row(
                    children: List.generate(_maxHp, (index) {
                      final bool isFull = index < _currentHp;
                      return Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(
                          isFull ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 15,
                          color: isFull ? const Color(0xFFFF4D6D) : const Color(0xFF5D5373),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '$_currentHp/$_maxHp',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFF4D6D),
                    ),
                  ),
                ],
              ),

              // Indikator Gold
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF221706),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFFFD166).withOpacity(0.5),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on_rounded,
                      size: 13,
                      color: Color(0xFFFFD166),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_gold GOLD',
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Color(0xFFFFD166),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Row 3: Progress Bar EXP Futuristik / Gaming
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'EXPERIENCE PROGRESS',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFFD8B4F8),
                    ),
                  ),
                  Text(
                    '$_currentExp / $_maxExp EXP (${(expProgress * 100).toInt()}%)',
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.manaCyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Stack(
                children: [
                  // Track background
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0C0716),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF24193F),
                        width: 0.8,
                      ),
                    ),
                  ),
                  // Progress Fill
                  FractionallySizedBox(
                    widthFactor: expProgress > 0.02 ? expProgress : 0.02,
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7B2CBF), Color(0xFFB026FF), Color(0xFF00E5FF)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB026FF).withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Server Time Banner (WIB | WITA | WIT | GMT)
  Widget _buildServerTimeBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF120D24), // Midnight Indigo
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 0.9,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 13,
                  color: AppColors.manaCyan,
                ),
                SizedBox(width: 4),
                Text(
                  'SERVER:',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppColors.manaCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            _buildZoneTime(label: 'WIB', time: _wibTime, isPrimary: true),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '•',
                style: TextStyle(color: Color(0xFF3B2D5C), fontSize: 10),
              ),
            ),
            _buildZoneTime(label: 'WITA', time: _witaTime, isPrimary: false),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '•',
                style: TextStyle(color: Color(0xFF3B2D5C), fontSize: 10),
              ),
            ),
            _buildZoneTime(label: 'WIT', time: _witTime, isPrimary: false),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '•',
                style: TextStyle(color: Color(0xFF3B2D5C), fontSize: 10),
              ),
            ),
            _buildZoneTime(label: 'GMT', time: _gmtTime, isPrimary: false),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneTime({
    required String label,
    required String time,
    required bool isPrimary,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label ',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 8.5,
            fontWeight: FontWeight.w700,
            color: isPrimary ? const Color(0xFFD8B4F8) : const Color(0xFF8B829E),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: isPrimary ? const Color(0xFFF3EFF5) : const Color(0xFFD8B4F8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestCard({
    required String title,
    required String req,
    required String expReward,
    required String goldReward,
    required String tag,
    required Color tagColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF120D24),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF24193F),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1233),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: tagColor.withOpacity(0.4),
                width: 1.0,
              ),
            ),
            child: Icon(
              icon,
              size: 20,
              color: tagColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF3EFF5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: tagColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 7.5,
                          fontWeight: FontWeight.w700,
                          color: tagColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  req,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 9.5,
                    color: Color(0xFF8B829E),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                expReward,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB026FF),
                ),
              ),
              Text(
                goldReward,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFD166),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
