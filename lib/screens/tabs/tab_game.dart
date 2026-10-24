import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';

/// Tab 3: Mini Game Mana Core Stabilization (Sensor Gyroscope)
/// Layout UI diadopsi 1:1 dari Stitch LevMax Solo Leveling Monarch System.
/// Mengintegrasikan sensor Gyroscope dengan Memory-Safe Throttling untuk perangkat low-end.
class TabGame extends StatefulWidget {
  const TabGame({super.key});

  @override
  State<TabGame> createState() => _TabGameState();
}

class _TabGameState extends State<TabGame> with SingleTickerProviderStateMixin {
  // 1. Setup State Posisi Bola & Arena (Arena: 300x300, Bola: 40x40, Center = 130)
  static const double arenaSize = 300.0;
  static const double ballSize = 40.0;
  static const double targetRadius = 43.0; // Target zone radius (diameter 86px)
  static const double safeZoneThreshold = 35.0; // Toleransi pusat aman

  double ballX = 130.0;
  double ballY = 130.0;

  // 2. Sensor & Throttling
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  DateTime _lastUiUpdate = DateTime.now();
  double _pitch = 0.0;
  double _roll = 0.0;
  bool _isSensorActive = false;

  // 3. Logika Game & Timer Survival Mode (30 Detik Hardcore)
  Timer? _survivalTimer;
  bool isPlaying = false;
  bool isGameOver = false;
  int timeRemaining = 30; // Hitung mundur 30 detik
  bool hasPlayedToday = false;
  bool _isInCenter = true;

  // 4. Hunter Session Data dari Hive
  String _hunterName = 'HUNTER SUNG';
  String _rank = 'RANK S';
  int _currentExp = 150;
  int _gold = 250;
  final int _maxExp = 300;

  // 5. System Clock (WIB, WITA, WIT, GMT)
  Timer? _serverClockTimer;
  String _wibTime = '14:32';
  String _witaTime = '15:32';
  String _witTime = '16:32';
  String _gmtTime = '07:32';

  @override
  void initState() {
    super.initState();
    _loadHunterSession();
    _initServerClock();
    _initGyroscope();
  }

  void _loadHunterSession() {
    final session = HiveService.getSession();
    setState(() {
      _hunterName = session['username']?.toString() ?? 'HUNTER SUNG';
      _rank = session['rank']?.toString() ?? 'RANK S';
      _currentExp = (session['exp'] as int?) ?? 150;
      _gold = (session['gold'] as int?) ?? 250;
    });
    _checkDailyRewardStatus();
  }

  /// Sinkronisasi status reward harian berdasarkan tanggal waktu server WIB (UTC+7)
  void _checkDailyRewardStatus() {
    final nowUtc = DateTime.now().toUtc();
    final wib = nowUtc.add(const Duration(hours: 7));
    final currentServerDate = DateFormat('yyyy-MM-dd').format(wib);
    final lastRewardDate = HiveService.getGameRewardDate();

    final bool claimedToday = (lastRewardDate == currentServerDate);
    if (hasPlayedToday != claimedToday && mounted) {
      setState(() {
        hasPlayedToday = claimedToday;
      });
    }
  }

  void _initServerClock() {
    _updateClock();
    _serverClockTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateClock());
  }

  void _updateClock() {
    if (!mounted) return;
    final nowUtc = DateTime.now().toUtc();
    final timeFormat = DateFormat('HH:mm');
    final wib = nowUtc.add(const Duration(hours: 7));
    final wita = nowUtc.add(const Duration(hours: 8));
    final wit = nowUtc.add(const Duration(hours: 9));

    setState(() {
      _wibTime = timeFormat.format(wib);
      _witaTime = timeFormat.format(wita);
      _witTime = timeFormat.format(wit);
      _gmtTime = timeFormat.format(nowUtc);
    });

    // Periksa status refresh harian otomatis setiap pergantian detik (reset pada 00:00 WIB)
    _checkDailyRewardStatus();
  }

  /// 2. Integrasi Gyroscope dengan Throttling (~30ms) agar hemat baterai & aman di perangkat low-end (Oppo A5)
  /// Memulai Survival Protocol 30 Detik
  void _startProtocol() {
    if (hasPlayedToday) return;

    _survivalTimer?.cancel();
    _survivalTimer = null;

    setState(() {
      ballX = 130.0;
      ballY = 130.0;
      timeRemaining = 30;
      isPlaying = true;
      isGameOver = false;
      _isInCenter = true;
    });

    _survivalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (timeRemaining > 1) {
        setState(() {
          timeRemaining--;
        });
      } else {
        // timeRemaining == 0: Berhasil bertahan 30 detik tanpa keluar target zone!
        timer.cancel();
        _survivalTimer = null;
        _handleGameVictory();
      }
    });
  }

  /// 2. Integrasi Gyroscope dengan Sensitivitas Ekstrem (Hardcore Mode)
  void _initGyroscope() {
    try {
      _gyroSubscription = gyroscopeEventStream().listen(
        (GyroscopeEvent event) {
          if (!mounted) return;

          _isSensorActive = true;

          // Hitung orientasi derajat (Pitch & Roll) untuk display HUD
          final double currentPitch = event.x * (180.0 / pi);
          final double currentRoll = event.y * (180.0 / pi);
          _pitch = currentPitch;
          _roll = currentRoll;

          // Bola hanya bergerak jika game sedang berjalan
          if (!isPlaying) return;

          // PEROMBAKAN FISIKA SENSOR (Sangat Sensitif & Sulit):
          // Pengali dilipatgandakan secara drastis (22.0) tanpa damping/friction
          // Bola terasa sangat licin, liar, dan bereaksi kuat terhadap kemiringan / guncangan sekecil apa pun
          const double sensitivity = 22.0;
          final double newX = (ballX + event.y * sensitivity).clamp(6.0, arenaSize - ballSize - 6.0);
          final double newY = (ballY + event.x * sensitivity).clamp(6.0, arenaSize - ballSize - 6.0);

          ballX = newX;
          ballY = newY;

          // Cek apakah bola keluar dari Target Zone
          _checkTargetZone();

          // THROTTLING: Batasi pemanggilan setState maksimum ~33 FPS (30ms interval)
          final DateTime now = DateTime.now();
          if (now.difference(_lastUiUpdate).inMilliseconds >= 30) {
            _lastUiUpdate = now;
            setState(() {});
          }
        },
        onError: (err) {
          setState(() {
            _isSensorActive = false;
          });
        },
      );
    } catch (e) {
      _isSensorActive = false;
    }
  }

  /// 3. Logika Deteksi Zona Tengah & Aturan Survival (30 Detik)
  void _checkTargetZone() {
    if (!isPlaying) return;

    // Pusat arena adalah (150, 150)
    final double centerArena = arenaSize / 2; // 150.0
    // Pusat bola adalah (ballX + 20, ballY + 20)
    final double ballCenterX = ballX + (ballSize / 2);
    final double ballCenterY = ballY + (ballSize / 2);

    final double distanceToCenter = sqrt(
      pow(ballCenterX - centerArena, 2) + pow(ballCenterY - centerArena, 2),
    );

    final bool inZone = distanceToCenter <= safeZoneThreshold;

    if (inZone) {
      _isInCenter = true;
    } else {
      // BOLA KELUAR DARI ZONA AMAN! PROTOCOL FAILED!
      _handleGameOver();
    }
  }

  void _handleGameOver() {
    if (!isPlaying) return;

    _survivalTimer?.cancel();
    _survivalTimer = null;

    setState(() {
      isPlaying = false;
      isGameOver = true;
      _isInCenter = false;
    });

    _showFailedDialog();
  }

  /// Penanganan Kemenangan: Berhasil bertahan 30 detik tanpa keluar target zone
  Future<void> _handleGameVictory() async {
    _survivalTimer?.cancel();
    _survivalTimer = null;

    final nowUtc = DateTime.now().toUtc();
    final wib = nowUtc.add(const Duration(hours: 7));
    final currentServerDate = DateFormat('yyyy-MM-dd').format(wib);

    // Kunci reward harian berdasarkan tanggal server WIB (refresh 00:00 WIB)
    await HiveService.saveGameRewardDate(currentServerDate);

    setState(() {
      hasPlayedToday = true;
      isPlaying = false;
      isGameOver = false;
      timeRemaining = 0;
      _isInCenter = true;
      _gold += 50;
    });

    // Simpan reward ke Hive & Supabase
    final session = HiveService.getSession();
    final userId = session['userId']?.toString() ?? 'anonymous';
    final username = session['username']?.toString() ?? _hunterName;
    final rank = session['rank']?.toString() ?? _rank;
    final currentHp = session['hp'] as int? ?? 3;

    HiveService.saveSession(
      userId: userId,
      username: username,
      rank: rank,
      exp: _currentExp,
      gold: _gold,
      hp: currentHp,
    );

    if (userId != 'anonymous') {
      SupabaseService.updateUserStats(
        userId: userId,
        exp: _currentExp,
        gold: _gold,
        rank: rank,
      );
    }

    _showVictoryDialog();
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF140D24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF00F4FE), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.verified_rounded, color: Color(0xFF00F4FE), size: 36),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'MANA CORE STABILIZED!',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: const Color(0xFF00F4FE),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Inti Mana berhasil distabilkan selama 30 detik penuh dalam mode Hardcore Survival! Reward +50 Gold telah diklaim (Batas 1x sehari, reset otomatis pukul 00:00 WIB).',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFFD2C1D7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFB026FF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFB026FF).withValues(alpha: 0.6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.monetization_on_rounded, color: Color(0xFFFFD166), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '+50 GOLD DITAMBAHKAN',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFFD166),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00F4FE),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 6,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'TERIMA & KEMBALI',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFailedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF140D24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFFF4D4D), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF4D4D).withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4D4D).withValues(alpha: 0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4D4D), size: 36),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'PROTOCOL FAILED!',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: const Color(0xFFFF4D4D),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Inti Mana tidak stabil! Bola keluar dari Target Zone sebelum 30 detik selesai. Jaga kestabilan gyroscope perangkat Anda dan coba lagi.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  color: const Color(0xFFD2C1D7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF93000A).withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFF4D4D).withValues(alpha: 0.5)),
                ),
                child: Text(
                  'SISA WAKTU: $timeRemaining DETIK',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFFFB4AB),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D4D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 6,
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _startProtocol();
                  },
                  child: Text(
                    'COBA LAGI (RETRY PROTOCOL)',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'KEMBALI KE TERMINAL',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 4. Keamanan Memori: Wajib batalkan stream & timer saat widget ditutup
  @override
  void dispose() {
    _gyroSubscription?.cancel();
    _survivalTimer?.cancel();
    _serverClockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Sinkronkan data sesi Hunter secara dinamis
    final session = HiveService.getSession();
    _hunterName = session['username']?.toString() ?? _hunterName;
    _gold = (session['gold'] as int?) ?? _gold;
    _currentExp = (session['exp'] as int?) ?? _currentExp;
    _rank = session['rank']?.toString() ?? _rank;

    // Sinkronisasi status reward harian dengan tanggal server WIB (refresh 00:00 WIB)
    final nowUtc = DateTime.now().toUtc();
    final wib = nowUtc.add(const Duration(hours: 7));
    final currentServerDate = DateFormat('yyyy-MM-dd').format(wib);
    final lastRewardDate = HiveService.getGameRewardDate();
    hasPlayedToday = (lastRewardDate == currentServerDate);

    final double progress = isPlaying
        ? ((30 - timeRemaining) / 30.0).clamp(0.0, 1.0)
        : (hasPlayedToday ? 1.0 : 0.0);

    return Scaffold(
      backgroundColor: const Color(0xFF16111E),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header Hunter Bar
              _buildHunterHeader(),

              const SizedBox(height: 12),

              // Sensor Telemetry Status Bar
              _buildSensorBar(),

              const SizedBox(height: 14),

              // Title & Protocol Hint
              _buildTitleSection(),

              const SizedBox(height: 14),

              // Centerpiece Arena Box (300 x 300)
              _buildArenaBox(),

              const SizedBox(height: 14),

              // Real-time HUD Tilt Indicators (Pitch & Roll)
              _buildTiltIndicators(),

              const SizedBox(height: 12),

              // Hold Core Duration Progress Panel
              _buildHoldDurationCard(progress),

              const SizedBox(height: 12),

              // Daily Reward Box
              _buildRewardCard(),

              const SizedBox(height: 14),

              // Action / Reset Button
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Top Hunter Bar
  Widget _buildHunterHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF110C19).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _hunterName,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: const Color(0xFFE9DEF2),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFB026FF).withValues(alpha: 0.5),
                            width: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB026FF).withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          _rank,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: const Color(0xFFE5B5FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Row(
                        children: List.generate(
                          3,
                          (i) => const Padding(
                            padding: EdgeInsets.only(right: 2.0),
                            child: Icon(Icons.favorite_rounded, size: 13, color: Color(0xFFFF4D4D)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('•', style: TextStyle(color: Colors.grey.shade700, fontSize: 10)),
                      const SizedBox(width: 6),
                      Row(
                        children: [
                          const Icon(Icons.monetization_on_rounded, size: 12.5, color: Color(0xFFFFD166)),
                          const SizedBox(width: 3),
                          Text(
                            '+$_gold G',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFFD166),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Builder(
                builder: (context) {
                  final avatarUrl = HiveService.getSession()['avatar_url']?.toString();
                  return Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFB026FF),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: avatarUrl != null && avatarUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              avatarUrl,
                              width: 34,
                              height: 34,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.person, color: Colors.white, size: 20),
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                          ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXP RECOVERY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: const Color(0xFFD2C1D7),
                ),
              ),
              Text(
                '$_currentExp/$_maxExp EXP',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: const Color(0xFFE5B5FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentExp / _maxExp).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: const Color(0xFF2D2736),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00F4FE)),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'SYS.TIME: WIB $_wibTime | WITA $_witaTime | WIT $_witTime | GMT $_gmtTime',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
              color: const Color(0xFF9B8BA1),
            ),
          ),
        ],
      ),
    );
  }

  /// Sensor Telemetry Bar
  Widget _buildSensorBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2736).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00F4FE),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F4FE).withValues(alpha: 0.8),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'SENSOR: GYROSCOPE',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: const Color(0xFF63F7FF),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            color: const Color(0xFF2D2736).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.sensors_rounded, size: 12, color: Color(0xFFE5B5FF)),
              const SizedBox(width: 5),
              Text(
                _isSensorActive ? 'GYRO: ACTIVE' : 'AXIS: X/Y/Z READY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: const Color(0xFFF4D9FF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Title Section
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt_rounded, size: 15, color: Color(0xFFB026FF)),
            const SizedBox(width: 4),
            Text(
              'DAILY PROTOCOL • MINI GAME',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: const Color(0xFFE5B5FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          'MANA CORE STABILIZATION',
          style: GoogleFonts.sora(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: const Color(0xFFE9DEF2),
            shadows: [
              Shadow(
                color: const Color(0xFF00F4FE).withValues(alpha: 0.5),
                blurRadius: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1927),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5B5FF).withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              const Icon(Icons.screen_rotation_rounded, color: Color(0xFF00F4FE), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFFD2C1D7)),
                    children: [
                      const TextSpan(text: 'Miringkan perangkat untuk bertahan di zona tengah selama '),
                      TextSpan(
                        text: '30 detik',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF63F7FF),
                        ),
                      ),
                      const TextSpan(text: ' tanpa keluar target zone!'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Arena Utama (300 x 300)
  Widget _buildArenaBox() {
    return Center(
      child: GestureDetector(
        // Fallback interaksi sentuh / pan untuk pengujian pada emulator
        onPanUpdate: (details) {
          if (!isPlaying) return;
          setState(() {
            const double touchSensitivity = 2.0;
            ballX = (ballX + details.delta.dx * touchSensitivity).clamp(6.0, arenaSize - ballSize - 6.0);
            ballY = (ballY + details.delta.dy * touchSensitivity).clamp(6.0, arenaSize - ballSize - 6.0);
            _pitch = ((ballY - 130.0) / 3.0);
            _roll = ((ballX - 130.0) / 3.0);
            _checkTargetZone();
          });
        },
        child: Container(
          width: arenaSize,
          height: arenaSize,
          decoration: BoxDecoration(
            color: const Color(0xFF120D24),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _isInCenter ? const Color(0xFF00F4FE) : const Color(0xFFB026FF).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB026FF).withValues(alpha: 0.35),
                blurRadius: 36,
              ),
              BoxShadow(
                color: const Color(0xFF00F4FE).withValues(alpha: _isInCenter ? 0.35 : 0.18),
                blurRadius: 60,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Concentric Vector Grid Paint
              Positioned.fill(
                child: CustomPaint(
                  painter: _ArenaGridPainter(),
                ),
              ),

              // 2. Corner HUD Diagnostic Tags
              Positioned(
                top: 10,
                left: 12,
                child: Text(
                  'ZONE // 01',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: const Color(0xFFF0DBFF),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 12,
                child: Text(
                  !isPlaying
                      ? (hasPlayedToday
                          ? 'STATUS: STABILIZED'
                          : (isGameOver ? 'FAILED: OUT OF ZONE' : 'SYSTEM: STANDBY'))
                      : (_isInCenter
                          ? 'SURVIVING: $timeRemaining s'
                          : 'CRITICAL: OUT OF ZONE!'),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: !isPlaying
                        ? (hasPlayedToday
                            ? const Color(0xFF00DCE5)
                            : (isGameOver ? const Color(0xFFFF4D4D) : const Color(0xFFF0DBFF)))
                        : (_isInCenter ? const Color(0xFF00DCE5) : const Color(0xFFFF4D4D)),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 12,
                child: Text(
                  'RADIUS: 43px',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    color: const Color(0xFF9B8BA1),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 12,
                child: Text(
                  'HARDCORE v3.0',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE5B5FF),
                  ),
                ),
              ),

              // 3. Target Safe Zone (Center Reticle 86x86 px)
              Positioned(
                left: (arenaSize - (targetRadius * 2)) / 2, // 107.0
                top: (arenaSize - (targetRadius * 2)) / 2,  // 107.0
                width: targetRadius * 2,                   // 86.0
                height: targetRadius * 2,                  // 86.0
                child: _buildTargetZoneWidget(),
              ),

              // 4. Mana Core Orb (Positioned dengan ballX dan ballY)
              Positioned(
                left: ballX,
                top: ballY,
                width: ballSize,
                height: ballSize,
                child: _buildManaCoreOrb(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Target Zone Reticle Box
  Widget _buildTargetZoneWidget() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _isInCenter
            ? const Color(0xFF00F4FE).withValues(alpha: 0.15)
            : const Color(0xFF00F4FE).withValues(alpha: 0.05),
        border: Border.all(
          color: _isInCenter ? const Color(0xFF00F4FE) : const Color(0xFF00F4FE).withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F4FE).withValues(alpha: _isInCenter ? 0.6 : 0.25),
            blurRadius: _isInCenter ? 28 : 16,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 4 Notches Crosshairs Reticle
          Positioned(
            top: -2,
            child: Container(width: 8, height: 2, color: const Color(0xFF00F4FE)),
          ),
          Positioned(
            bottom: -2,
            child: Container(width: 8, height: 2, color: const Color(0xFF00F4FE)),
          ),
          Positioned(
            left: -2,
            child: Container(width: 2, height: 8, color: const Color(0xFF00F4FE)),
          ),
          Positioned(
            right: -2,
            child: Container(width: 2, height: 8, color: const Color(0xFF00F4FE)),
          ),
        ],
      ),
    );
  }

  /// Mana Core Orb (Bola Inti Mana)
  Widget _buildManaCoreOrb() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Colors.white,
            Color(0xFF00F4FE),
            Color(0xFFB026FF),
            Color(0xFF3F225B),
          ],
          stops: [0.1, 0.4, 0.75, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB026FF).withValues(alpha: 0.8),
            blurRadius: 18,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFF00F4FE).withValues(alpha: 0.8),
            blurRadius: 24,
            spreadRadius: 4,
          ),
          const BoxShadow(
            color: Colors.white,
            blurRadius: 8,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// HUD Tilt Indicators
  Widget _buildTiltIndicators() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2736).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF383241), width: 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PITCH (X)',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: const Color(0xFFD2C1D7),
                  ),
                ),
                Text(
                  '${_pitch >= 0 ? '+' : ''}${_pitch.toStringAsFixed(1)}°',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF00F4FE),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2736).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF383241), width: 0.8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ROLL (Y)',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: const Color(0xFFD2C1D7),
                  ),
                ),
                Text(
                  '${_roll >= 0 ? '+' : ''}${_roll.toStringAsFixed(1)}°',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE5B5FF),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Hold Duration Card
  Widget _buildHoldDurationCard(double progress) {
    String statusText = 'STANDBY';
    Color statusColor = const Color(0xFF9B8BA1);

    if (hasPlayedToday) {
      statusText = 'LOCKED (COMPLETED)';
      statusColor = const Color(0xFF00F4FE);
    } else if (isPlaying) {
      statusText = 'SURVIVING (HARDCORE)';
      statusColor = const Color(0xFF00F4FE);
    } else if (isGameOver) {
      statusText = 'PROTOCOL FAILED';
      statusColor = const Color(0xFFFF4D4D);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2C1E4E), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: Color(0xFFE5B5FF)),
                  const SizedBox(width: 6),
                  Text(
                    'SURVIVAL PROTOCOL DURATION',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: const Color(0xFFD2C1D7),
                    ),
                  ),
                ],
              ),
              Text(
                statusText,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$timeRemaining',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFE9DEF2),
                      shadows: [
                        Shadow(
                          color: (isGameOver ? const Color(0xFFFF4D4D) : const Color(0xFF00F4FE))
                              .withValues(alpha: 0.7),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/ 30 Detik',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9B8BA1),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF383241),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isPlaying ? 'SENSITIVITY: 22.0x' : 'SYNC 1.0x',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFF4D9FF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFF110C19),
              valueColor: AlwaysStoppedAnimation<Color>(
                isGameOver ? const Color(0xFFFF4D4D) : const Color(0xFF00F4FE),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Daily Reward Box
  Widget _buildRewardCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1406),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFFFD166).withValues(alpha: 0.35),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD166).withValues(alpha: 0.12),
            blurRadius: 18,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF342407),
                ),
                child: const Center(
                  child: Icon(Icons.military_tech_rounded, color: Color(0xFFFFD166), size: 20),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REWARD: +50 GOLD',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: const Color(0xFFFFD166),
                    ),
                  ),
                  Text(
                    'Batas Klaim: 1x / Hari (Reset 00:00 WIB)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      color: const Color(0xFFD8B478),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFF2D1F08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              hasPlayedToday ? 'CLAIMED' : 'READY',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: hasPlayedToday ? const Color(0xFF00F4FE) : const Color(0xFFFFD166),
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Action / Start / Reset Button
  Widget _buildActionButton() {
    if (hasPlayedToday) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1E1728),
          border: Border.all(color: const Color(0xFF00F4FE).withValues(alpha: 0.4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_rounded, color: Color(0xFF00F4FE), size: 18),
                const SizedBox(width: 8),
                Text(
                  'REWARD HARIAN SUDAH DIKLAIM',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: const Color(0xFF00F4FE),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              'Batas 1x sehari • Reset otomatis pukul 00:00 WIB (Waktu Server)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                color: const Color(0xFF9B8BA1),
              ),
            ),
          ],
        ),
      );
    }

    if (isPlaying) {
      return Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF005F73), Color(0xFF00F4FE)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F4FE).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'BERTAHAN DI ZONA TENGAH! ($timeRemaining s)',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    // Tombol Start / Retry Protocol
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _startProtocol,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: isGameOver
                ? [const Color(0xFF93000A), const Color(0xFFFF5449)]
                : [const Color(0xFF7B2CBF), const Color(0xFFB026FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [
            BoxShadow(
              color: (isGameOver ? const Color(0xFFFF5449) : const Color(0xFFB026FF))
                  .withValues(alpha: 0.6),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isGameOver ? Icons.refresh_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isGameOver
                  ? 'RETRY PROTOCOL (SURVIVAL 30s)'
                  : 'START PROTOCOL (SURVIVAL 30s)',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter untuk menggambar Concentric Rings & Crosshair Grid radar arena
class _ArenaGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Ring 1 (r=130): Dashed Violet
    final paintRing1 = Paint()
      ..color = const Color(0xFFB026FF).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    _drawDashedCircle(canvas, center, 130, paintRing1, [4, 6]);

    // Ring 2 (r=100): Solid Purple
    final paintRing2 = Paint()
      ..color = const Color(0xFF8868A6).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, 100, paintRing2);

    // Ring 3 (r=68): Dashed Cyan
    final paintRing3 = Paint()
      ..color = const Color(0xFF00F4FE).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    _drawDashedCircle(canvas, center, 68, paintRing3, [2, 4]);

    // Crosshairs
    final paintCross = Paint()
      ..color = const Color(0xFFB026FF).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    _drawDashedLine(canvas, const Offset(20, 150), const Offset(280, 150), paintCross, [3, 3]);
    _drawDashedLine(canvas, const Offset(150, 20), const Offset(150, 280), paintCross, [3, 3]);

    // Center Ticks
    final paintTicks = Paint()
      ..color = const Color(0xFF00F4FE)
      ..strokeWidth = 1.5;
    canvas.drawLine(const Offset(140, 150), const Offset(160, 150), paintTicks);
    canvas.drawLine(const Offset(150, 140), const Offset(150, 160), paintTicks);
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint, List<double> dash) {
    const double totalAngle = 2 * pi;
    final double dashAngle = dash[0] / radius;
    final double gapAngle = dash[1] / radius;

    double currentAngle = 0.0;
    while (currentAngle < totalAngle) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        dashAngle,
        false,
        paint,
      );
      currentAngle += dashAngle + gapAngle;
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint, List<double> dash) {
    final double dx = p2.dx - p1.dx;
    final double dy = p2.dy - p1.dy;
    final double totalDistance = sqrt(dx * dx + dy * dy);
    final double unitX = dx / totalDistance;
    final double unitY = dy / totalDistance;

    double currentDist = 0.0;
    while (currentDist < totalDistance) {
      final double nextDist = min(currentDist + dash[0], totalDistance);
      canvas.drawLine(
        Offset(p1.dx + unitX * currentDist, p1.dy + unitY * currentDist),
        Offset(p1.dx + unitX * nextDist, p1.dy + unitY * nextDist),
        paint,
      );
      currentDist += dash[0] + dash[1];
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
