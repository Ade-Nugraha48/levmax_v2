import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../widgets/avatar_image.dart';

/// QuestSensorScreen
/// Layar Cardio Shake Protocol berbasis sensor Accelerometer murni.
/// Mengadopsi visual cyberpunk HUD Solo Leveling 1:1 persis desain Stitch.
class QuestSensorScreen extends StatefulWidget {
  final String? currentRank;

  const QuestSensorScreen({
    super.key,
    this.currentRank,
  });

  @override
  State<QuestSensorScreen> createState() => _QuestSensorScreenState();
}

class _QuestSensorScreenState extends State<QuestSensorScreen> {
  String get _displayRank {
    final raw = widget.currentRank ?? HiveService.getSession()['rank']?.toString();
    if (raw == null || raw.trim().isEmpty) return 'F';
    final clean = raw.replaceAll(RegExp(r'^Rank\s*', caseSensitive: false), '').trim();
    return clean.isEmpty ? 'F' : clean;
  }
  // 1. Subscription Accelerometer (Wajib dibatalkan di dispose untuk mencegah memory leak)
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // 2. State Perhitungan Guncangan & Batas Target
  int _shakeCount = 0;
  static const int _targetShakes = 50;
  DateTime _lastShakeTime = DateTime.now();
  double _currentGForce = 1.0;
  bool _isCompleted = false;

  // 3. Timer Countdown 03:00 (180 detik)
  Timer? _countdownTimer;
  int _secondsRemaining = 180;

  @override
  void initState() {
    super.initState();
    _startAccelerometerSubscription();
    _startCountdownTimer();
  }

  /// Memulai stream sensor accelerometer dengan toleransi threshold & debounce cooldown
  void _startAccelerometerSubscription() {
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (_isCompleted) return;

      // Hitung magnitudo akselerasi total sqrt(x^2 + y^2 + z^2)
      final double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      // G-force relatif (1G = 9.80665 m/s^2)
      final double gForce = magnitude / 9.80665;

      if (mounted) {
        setState(() {
          _currentGForce = gForce;
        });
      }

      // Toleransi threshold: delta pergerakan > 15 m/s^2 dari gravitasi normal
      final double delta = (magnitude - 9.80665).abs();
      final DateTime now = DateTime.now();

      // Debounce cooldown 320ms agar guncangan tidak terhitung ganda terlalu cepat
      if (delta > 15.0 && now.difference(_lastShakeTime).inMilliseconds > 320) {
        _lastShakeTime = now;
        _registerShake();
      }
    });
  }

  /// Menjalankan timer hitung mundur 03:00 menit
  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _secondsRemaining--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  String get _formattedTimeRemaining {
    final int minutes = _secondsRemaining ~/ 60;
    final int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} REMAINING';
  }

  /// Sinkronisasi Persentase: Dimulai dari 0% saat awal, meningkat dinamis hingga 100% saat target selesai
  int get _syncPercent {
    final double pct = (_shakeCount / _targetShakes) * 100.0;
    return pct.clamp(0.0, 100.0).toInt();
  }

  String get _syncPercentLabel => '$_syncPercent%';

  Color get _syncColor {
    if (_syncPercent >= 100) {
      return const Color(0xFF00F4FE);
    } else if (_syncPercent > 0) {
      return const Color(0xFFE9DEF2);
    }
    return const Color(0xFF9B8BA1);
  }

  /// Rules Intensitas Dinamis:
  /// - 'LENGKAP': Target 50 shakes tercapai (sinkronisasi 100%)
  /// - 'STANDBY': Kondisi awal (0 shakes) belum ada guncangan aktif
  /// - 'MENURUN': Hunter berhenti bergerak / idle lebih dari 2.5 detik di tengah quest
  /// - 'MAKSIMAL': Akselerasi guncangan tinggi (G-Force >= 2.4 G)
  /// - 'OPTIMAL': Ritme akselerasi mantap dan stabil (1.45 G s/d 2.4 G)
  /// - 'RENDAH': Guncangan perlahan di bawah ambang optimal (< 1.45 G)
  String get _intensityLabel {
    if (_isCompleted || _shakeCount >= _targetShakes) {
      return 'LENGKAP';
    }
    if (_shakeCount == 0 && _currentGForce <= 1.25) {
      return 'STANDBY';
    }
    final int millisSinceLastShake = DateTime.now().difference(_lastShakeTime).inMilliseconds;
    if (_shakeCount > 0 && millisSinceLastShake > 2500) {
      return 'MENURUN';
    }
    if (_currentGForce >= 2.4) {
      return 'MAKSIMAL';
    } else if (_currentGForce >= 1.45) {
      return 'OPTIMAL';
    } else {
      return 'RENDAH';
    }
  }

  Color get _intensityColor {
    switch (_intensityLabel) {
      case 'MAKSIMAL':
        return const Color(0xFFB026FF); // Ungu neon Solo Leveling
      case 'OPTIMAL':
      case 'LENGKAP':
        return const Color(0xFF00F4FE); // Cyan neon Hunter System
      case 'RENDAH':
        return const Color(0xFFD8B4F8); // Ungu muda
      case 'MENURUN':
        return const Color(0xFFFF7A85); // Merah warning
      case 'STANDBY':
      default:
        return const Color(0xFF9B8BA1); // Abu-abu standby
    }
  }

  /// Menambah jumlah shake dan memvalidasi jika target >= 50 tercapai
  void _registerShake() {
    if (_isCompleted) return;

    setState(() {
      _shakeCount++;
      _lastShakeTime = DateTime.now();
      // Simulasi peningkatan G-force jika dipicu interaktif melalui tap di simulator
      if (_currentGForce <= 1.25) {
        _currentGForce = 1.65 + Random().nextDouble() * 0.8;
      }

      if (_shakeCount >= _targetShakes) {
        _shakeCount = _targetShakes;
        _handleProtocolComplete();
      }
    });
  }

  /// Logika saat target 50 shakes tercapai: hentikan stream, beri reward, dan pop
  Future<void> _handleProtocolComplete() async {
    _isCompleted = true;
    _accelerometerSubscription?.cancel();
    _countdownTimer?.cancel();

    // 1. Simpan reward +20 EXP & +15 Gold ke sesi lokal Hive & Supabase
    try {
      final session = HiveService.getSession();
      final currentExp = (session['exp'] as int? ?? 0) + 20;
      final currentGold = (session['gold'] as int? ?? 0) + 15;
      final userId = session['userId']?.toString() ?? 'anonymous';
      final username = session['username']?.toString() ?? 'hunter';
      final rank = session['rank']?.toString() ?? 'F';
      final hp = session['hp'] as int? ?? 3;

      await HiveService.saveSession(
        userId: userId,
        username: username,
        rank: rank,
        exp: currentExp,
        gold: currentGold,
        hp: hp,
      );

      if (userId != 'anonymous') {
        await SupabaseService.updateUserStats(
          userId: userId,
          exp: currentExp,
          gold: currentGold,
          rank: rank,
        );
      }
    } catch (_) {}

    if (!mounted) return;

    // 2. Tampilkan SnackBar notifikasi Protocol Complete
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Protocol Complete! Sinkronisasi 100% (+20 EXP & +15 Gold)',
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00F4FE),
        duration: const Duration(seconds: 2),
      ),
    );

    // Beri jeda 800ms agar hunter melihat status 100% dan LENGKAP sebelum kembali
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // 3. Kembali ke halaman utama dengan nilai kembalian true
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    // WAJIB: Batalkan subscription dan timer untuk mencegah memory leak
    _accelerometerSubscription?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_shakeCount / _targetShakes).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: const Color(0xFF16111E), // Background #16111E
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Ambient Mana Surge Glowing Orbs di Background
            Positioned(
              top: -40,
              left: MediaQuery.of(context).size.width / 2 - 120,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB026FF).withValues(alpha: 0.12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB026FF).withValues(alpha: 0.15),
                      blurRadius: 90,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 220,
              left: MediaQuery.of(context).size.width / 2 - 130,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00F4FE).withValues(alpha: 0.08),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F4FE).withValues(alpha: 0.12),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable Content
            Column(
              children: [
                // 1. Top Bar: "DUNGEON RAID LIVE"
                _buildTopAppBar(context),

                // Konten Utama
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 95.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 2. Sub-Header Status: SENSOR PROTOCOL: ACCELEROMETER & CALIBRATED
                        _buildSensorStatusBadgeRow(),

                        const SizedBox(height: 12),

                        // Title & Reward Pill Cluster
                        _buildQuestTitleCluster(),

                        const SizedBox(height: 16),

                        // 3. Centerpiece HUD (Lingkaran Sensor 250x250)
                        _buildCenterpieceHud(progress),

                        const SizedBox(height: 14),

                        // 4. Live G-Force Sensitivity Bar
                        _buildGForceBar(),

                        const SizedBox(height: 20),

                        // 5. Kotak Instruksi Sistem
                        _buildInstructionBox(),

                        const SizedBox(height: 14),

                        // 6. Realtime Stats Strip (Intensitas & Sinkronisasi)
                        _buildRealtimeStatsStrip(),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 7. Sticky Footer: Tombol "BATALKAN PROTOKOL" Merah Glowing
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 8
                  : 18,
              child: _buildCancelProtocolButton(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Top App Bar dengan Back Button & Status Window
  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Back Kiri
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1F1927),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF2C1E4E),
                  width: 1.0,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFFE9DEF2),
                  size: 16,
                ),
              ),
            ),
          ),

          // Teks Tengah: "SYSTEM HUD •" & "DUNGEON RAID LIVE"
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SYSTEM HUD',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: const Color(0xFF00F4FE),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 5,
                    height: 5,
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
                ],
              ),
              const SizedBox(height: 1),
              Text(
                'DUNGEON RAID LIVE',
                style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          // Kanan: Badge RANK: S dan Avatar Profil
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF141E2D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00F4FE).withValues(alpha: 0.7),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 13,
                      color: Color(0xFF00F4FE),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'RANK: $_displayRank',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: const Color(0xFF00F4FE),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Builder(
                builder: (context) {
                  final avatarUrl = HiveService.getSession()['avatar_url']?.toString();
                  return Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD8B4F8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB026FF).withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: HunterAvatar(
                      avatarUrl: avatarUrl,
                      size: 34,
                      fallback: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 20,
                          color: Color(0xFF1A1228),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Sub-Header: SENSOR PROTOCOL & CALIBRATED
  Widget _buildSensorStatusBadgeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Badge SENSOR PROTOCOL: ACCELEROMETER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1927),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFF00F4FE).withValues(alpha: 0.3),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00F4FE).withValues(alpha: 0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
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
              const SizedBox(width: 6),
              Text(
                'SENSOR PROTOCOL: ACCELEROMETER',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: const Color(0xFF00F4FE),
                ),
              ),
            ],
          ),
        ),

        // Status Kanan: CALIBRATED
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.sensors_rounded,
              size: 14,
              color: Color(0xFF00F4FE),
            ),
            const SizedBox(width: 4),
            Text(
              'CALIBRATED',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: const Color(0xFF00F4FE),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Title & Meta Cluster (+20 EXP • +15 GOLD & Timer Pill)
  Widget _buildQuestTitleCluster() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'DAILY DUNGEON QUEST',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: const Color(0xFFB026FF),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFB026FF),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'PHASE 01',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
                color: const Color(0xFF9B8BA1),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'CARDIO SHAKE PROTOCOL',
          style: GoogleFonts.sora(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: const Color(0xFFE9DEF2),
            shadows: const [
              Shadow(
                color: Colors.black,
                blurRadius: 12,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Row Pill: Reward Emas & Timer
        Row(
          children: [
            // Pill Reward Emas
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
              decoration: BoxDecoration(
                color: const Color(0xFF110C19),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFFD166).withValues(alpha: 0.3),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD166).withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    size: 14,
                    color: Color(0xFFFFD166),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '+20 EXP • +15 GOLD',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: const Color(0xFFFFD166),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Pill Timer Countdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1927),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF383241),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 13,
                    color: Color(0xFF9B8BA1),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formattedTimeRemaining,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: const Color(0xFF9B8BA1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 3. Centerpiece Cyberpunk HUD Ring (Lingkaran Sensor 250x250)
  Widget _buildCenterpieceHud(double progress) {
    return Center(
      child: GestureDetector(
        // Memungkinkan tap untuk simulasi / testing cepat di simulator
        onTap: _registerShake,
        child: SizedBox(
          width: 250,
          height: 250,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Custom Painter: Lingkaran Dashed, Corner Reticles, dan Glow Track
              CustomPaint(
                size: const Size(250, 250),
                painter: _CyberpunkHudPainter(progress: progress),
              ),

              // Glowing Circular Core
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF110C19),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00F4FE).withValues(alpha: 0.08),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),

              // Konten Tengah: Ikon Phone Vibration + Hitungan Shakes
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ikon Phone Vibration di Kotak Cyan Glowing
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16111E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00F4FE).withValues(alpha: 0.6),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00F4FE).withValues(alpha: 0.35),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.vibration_rounded,
                        color: Color(0xFF00F4FE),
                        size: 26,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Teks Angka Progres: "$shakeCount / 50"
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$_shakeCount',
                          style: GoogleFonts.sora(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.0,
                          ),
                        ),
                        TextSpan(
                          text: ' / $_targetShakes',
                          style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF9B8BA1),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 2),

                  // Label: "SHAKES DETECTED"
                  Text(
                    'SHAKES DETECTED',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.2,
                      color: const Color(0xFF00F4FE),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 4. Live G-Force Sensitivity Bar
  Widget _buildGForceBar() {
    final double gBarPercent = (_currentGForce / 3.5).clamp(0.1, 1.0);

    return Column(
      children: [
        SizedBox(
          width: 220,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'G-FORCE THRESHOLD',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: const Color(0xFF9B8BA1),
                ),
              ),
              Text(
                '${_currentGForce.toStringAsFixed(2)} G',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00F4FE),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 220,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFF110C19),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: const Color(0xFF2C1E4E),
              width: 0.8,
            ),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: gBarPercent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  colors: [Color(0xFFB026FF), Color(0xFF00F4FE)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F4FE).withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 5. Kotak Instruksi Sistem
  Widget _buildInstructionBox() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF383241),
          width: 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Garis Border Kiri Warna Cyan
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF00F4FE),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00F4FE),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141E2D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF00F4FE).withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Color(0xFF00F4FE),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INSTRUKSI SISTEM',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: const Color(0xFF00F4FE),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Pegang perangkat dengan erat dan lakukan gerakan lari/guncang! Sistem memantau ritme pergerakan akselerometer secara langsung.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          height: 1.45,
                          color: const Color(0xFFD2C1D7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 6. Realtime Stats Strip (Intensitas & Sinkronisasi)
  Widget _buildRealtimeStatsStrip() {
    return Row(
      children: [
        // Kotak INTENSITAS: Dinamis (STANDBY / RENDAH / OPTIMAL / MAKSIMAL / MENURUN / LENGKAP)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1927),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _intensityLabel == 'MAKSIMAL'
                    ? const Color(0xFFB026FF).withValues(alpha: 0.6)
                    : _intensityLabel == 'LENGKAP'
                        ? const Color(0xFF00F4FE).withValues(alpha: 0.6)
                        : const Color(0xFF383241),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D164D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.speed_rounded,
                      size: 18,
                      color: _intensityColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INTENSITAS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9B8BA1),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _intensityLabel,
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _intensityColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // Kotak SINKRONISASI: Dinamis (0% s/d 100%)
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1927),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _syncPercent >= 100
                    ? const Color(0xFF00F4FE).withValues(alpha: 0.6)
                    : const Color(0xFF383241),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A2730),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.show_chart_rounded,
                      size: 18,
                      color: _syncColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SINKRONISASI',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9B8BA1),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _syncPercentLabel,
                        style: GoogleFonts.sora(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _syncColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 7. Tombol Footer: "BATALKAN PROTOKOL" Merah Glowing
  Widget _buildCancelProtocolButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.pop(context),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF2D121B), // Translucent red background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFFF4D6D).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4D6D).withValues(alpha: 0.2),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.close_rounded,
                size: 20,
                color: Color(0xFFFF4D6D),
              ),
              const SizedBox(width: 8),
              Text(
                'BATALKAN PROTOKOL',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: const Color(0xFFFF4D6D),
                  shadows: [
                    Shadow(
                      color: const Color(0xFFFF4D6D).withValues(alpha: 0.5),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CustomPainter untuk menggambar Cyberpunk HUD Ring dengan Corner Reticles dan Glow Progress Arc
class _CyberpunkHudPainter extends CustomPainter {
  final double progress;

  _CyberpunkHudPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // 1. Lingkaran Background Track Abu-abu gelap
    final trackPaint = Paint()
      ..color = const Color(0xFF231D2B)
      ..strokeWidth = 9.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // 2. Corner Reticles (Tanda Sudut Cyan pada 45, 135, 225, 315 derajat)
    final reticlePaint = Paint()
      ..color = const Color(0xFF00F4FE)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final double reticleInner = radius + 10;
    final double reticleOuter = radius + 18;

    for (int i = 0; i < 4; i++) {
      final double angle = (pi / 4) + (i * pi / 2);
      final p1 = Offset(center.dx + reticleInner * cos(angle), center.dy + reticleInner * sin(angle));
      final p2 = Offset(center.dx + reticleOuter * cos(angle), center.dy + reticleOuter * sin(angle));
      canvas.drawLine(p1, p2, reticlePaint);
    }

    // 3. Dynamic Progress Glow Arc (#B026FF ke #00F4FE)
    if (progress > 0) {
      final sweepAngle = 2 * pi * progress;
      final progressRect = Rect.fromCircle(center: center, radius: radius);

      final progressPaint = Paint()
        ..shader = const SweepGradient(
          startAngle: -pi / 2,
          endAngle: 3 * pi / 2,
          colors: [
            Color(0xFFB026FF),
            Color(0xFF00F4FE),
          ],
        ).createShader(progressRect)
        ..strokeWidth = 9.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        progressRect,
        -pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CyberpunkHudPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
