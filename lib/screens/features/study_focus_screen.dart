import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/hive_service.dart';

/// StudyFocusScreen
/// Layar Mana Knowledge Focus (Study Protocol) bertema Solo Leveling Intelligence Protocol.
/// Menyediakan Timer Pomodoro 30 menit dengan kalkulasi EXP dan Gold reward.
class StudyFocusScreen extends StatefulWidget {
  final String? currentRank;

  const StudyFocusScreen({
    super.key,
    this.currentRank,
  });

  @override
  State<StudyFocusScreen> createState() => _StudyFocusScreenState();
}

class _StudyFocusScreenState extends State<StudyFocusScreen> with SingleTickerProviderStateMixin {
  String get _displayRank {
    final raw = widget.currentRank ?? HiveService.getSession()['rank']?.toString();
    if (raw == null || raw.trim().isEmpty) return 'F';
    final clean = raw.replaceAll(RegExp(r'^Rank\s*', caseSensitive: false), '').trim();
    return clean.isEmpty ? 'F' : clean;
  }
  // 1. State Timer
  int remainingSeconds = 1800; // 30 Menit (1800 detik)
  bool isRunning = false;
  Timer? _focusTimer;

  // 2. Format waktu countdown MM:SS
  String get formattedTime =>
      '${(remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(remainingSeconds % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _focusTimer?.cancel();
    super.dispose();
  }

  /// Memulai timer hitung mundur setiap 1 detik
  void startTimer() {
    if (isRunning) return;

    setState(() {
      isRunning = true;
    });

    _focusTimer?.cancel();
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });

        // Saat timer selesai (0 detik)
        if (remainingSeconds == 0) {
          timer.cancel();
          setState(() {
            isRunning = false;
          });

          if (!mounted) return;

          // Tampilkan notifikasi keberhasilan protokol
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.black, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mana Sync Complete! +15 EXP & +10 Gold Diperoleh!',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF00F4FE),
              duration: const Duration(seconds: 3),
            ),
          );

          // Kembalikan reward ke caller di tab_home
          Navigator.pop(context, {'exp': 15, 'gold': 10});
        }
      }
    });
  }

  /// Menjeda timer tanpa mereset waktu
  void pauseTimer() {
    _focusTimer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  /// Toggle antara start dan pause
  void _toggleTimer() {
    if (isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  /// Menghentikan timer dan mereset ke 30 menit (1800 detik)
  void stopTimer() {
    _focusTimer?.cancel();
    setState(() {
      isRunning = false;
      remainingSeconds = 1800;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Protokol fokus dibatalkan. Timer direset ke 30:00.',
          style: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2C1E4E),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16111E), // Background Solo Leveling Abyss
      body: SafeArea(
        child: Column(
          children: [
            // 1. System HUD Header Bar
            _buildHeader(context),

            // Content Area Scrollable
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  children: [
                    // 2. Resonance Intelligence Mandate Strip
                    _buildMandateStrip(),

                    const SizedBox(height: 24),

                    // 3. Hero Centerpiece: Circular Mana Core Timer
                    _buildManaCoreDial(),

                    const SizedBox(height: 28),

                    // 4. 3 Infographic Status Pods
                    _buildInfoPods(),

                    const SizedBox(height: 32),

                    // 5. Command Actions Matrix (Play & Abort)
                    _buildActionButtons(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 1. Top System HUD Header Bar
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF110C19),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFF2C1E4E),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Back dengan neon violet housing
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFF1F1927),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2C1E4E),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB026FF).withValues(alpha: 0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFFE5B5FF),
                size: 20,
              ),
            ),
          ),

          // Center System Identity
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SYSTEM HUD',
                    style: GoogleFonts.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.2,
                      color: const Color(0xFF63F7FF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'INTELLIGENCE PROTOCOL',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: const Color(0xFFDCB8FC),
                ),
              ),
            ],
          ),

          // Rank Status Pill (RANK: S)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF110C19),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF00F4FE).withValues(alpha: 0.3),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F4FE).withValues(alpha: 0.2),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RANK:',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: const Color(0xFF63F7FF),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB026FF),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFFB026FF),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Text(
                    _displayRank,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Resonance Intelligence Mandate Strip
  Widget _buildMandateStrip() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF110C19),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2736),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Color(0xFF00F4FE),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'FOKUS BELAJAR // RESONANSI PENGETAHUAN & MANA INTELLECT',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: const Color(0xFFE6FEFF),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Hero Centerpiece: Circular Mana Core Timer (Dial 268x268)
  Widget _buildManaCoreDial() {
    // Nilai progress yang dihubungkan ke CircularProgressIndicator (remainingSeconds / 1800)
    final double progressValue = remainingSeconds / 1800.0;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient Radial Mana Glow Backdrops
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB026FF).withValues(alpha: 0.22),
                  blurRadius: 70,
                  spreadRadius: 20,
                ),
                BoxShadow(
                  color: const Color(0xFF00F4FE).withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),

          // Outer Dial Housing (268x268)
          Container(
            width: 268,
            height: 268,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF110C19),
              border: Border.all(
                color: const Color(0xFF2C1E4E),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB026FF).withValues(alpha: 0.3),
                  blurRadius: 35,
                ),
              ],
            ),
            child: Center(
              child: SizedBox(
                width: 236,
                height: 236,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return const SweepGradient(
                      startAngle: 0.0,
                      endAngle: 3.14159 * 2,
                      colors: [
                        Color(0xFFB026FF),
                        Color(0xFFDCB8FC),
                        Color(0xFF00F4FE),
                        Color(0xFFB026FF),
                      ],
                      stops: [0.0, 0.4, 0.8, 1.0],
                    ).createShader(rect);
                  },
                  child: CircularProgressIndicator(
                    value: progressValue,
                    strokeWidth: 9.0,
                    backgroundColor: const Color(0xFF231D2B),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeCap: StrokeCap.round,
                  ),
                ),
              ),
            ),
          ),

          // Inner Hologram Pod (214x214)
          Container(
            width: 206,
            height: 206,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1F1927),
              border: Border.all(
                color: const Color(0xFF383241),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 24,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Mana Book Relic Icon Badge
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFB026FF).withValues(alpha: 0.28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB026FF).withValues(alpha: 0.45),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: Color(0xFFF4D9FF),
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // High-Impact Digital Chrono "formattedTime"
                Text(
                  formattedTime,
                  style: GoogleFonts.sora(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: const Color(0xFFE9DEF2),
                    shadows: [
                      Shadow(
                        color: const Color(0xFFB026FF).withValues(alpha: 0.75),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Sync Active State Indicator
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isRunning ? const Color(0xFF00F4FE) : const Color(0xFFFFAA00),
                        boxShadow: [
                          BoxShadow(
                            color: isRunning ? const Color(0xFF00F4FE) : const Color(0xFFFFAA00),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isRunning
                          ? 'MANA SYNC IN PROGRESS...'
                          : (remainingSeconds < 1800 ? 'MANA SYNC PAUSED' : 'MANA SYNC STANDBY'),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                        color: isRunning ? const Color(0xFF00F4FE) : const Color(0xFFFFAA00),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4. 3 Infographic Status Pods (Duration, Study Stat, Reward)
  Widget _buildInfoPods() {
    return Row(
      children: [
        // Pod 1: Duration (30 Mins)
        Expanded(
          child: _buildPodContainer(
            icon: Icons.timer_outlined,
            iconColor: const Color(0xFFE5B5FF),
            label: 'DURATION',
            labelColor: const Color(0xFFDCB8FC),
            child: Text(
              '30 Mins',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE9DEF2),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Pod 2: Study Stat (Intellect)
        Expanded(
          child: _buildPodContainer(
            icon: Icons.psychology_rounded,
            iconColor: const Color(0xFF00F4FE),
            label: 'STUDY STAT',
            labelColor: const Color(0xFF00F4FE),
            child: Text(
              'Intellect',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00F4FE),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Pod 3: Reward (+15 EXP, +10 GOLD)
        Expanded(
          child: _buildPodContainer(
            icon: Icons.military_tech_rounded,
            iconColor: const Color(0xFFF4D9FF),
            label: 'REWARD',
            labelColor: const Color(0xFF9B8BA1),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+15 EXP',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE5B5FF),
                    shadows: const [
                      Shadow(
                        color: Color(0xFFB026FF),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                Text(
                  '+10 GOLD',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF63F7FF),
                    shadows: const [
                      Shadow(
                        color: Color(0xFF00F4FE),
                        blurRadius: 4,
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

  Widget _buildPodContainer({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color labelColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1927),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2D2736),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: labelColor,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  /// 5. Command Actions Matrix (Play / Pause & Abort Protocol)
  Widget _buildActionButtons() {
    final String mainBtnLabel = isRunning
        ? 'PAUSE RESONANCE'
        : (remainingSeconds < 1800 ? 'RESUME FOCUS' : 'INITIATE FOCUS');
    final IconData mainBtnIcon = isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded;

    return Column(
      children: [
        // Primary Awakened Action Button (Gradient Purple Neon)
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _toggleTimer,
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFB026FF),
                  Color(0xFF8A00D4),
                  Color(0xFFB026FF),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB026FF).withValues(alpha: 0.45),
                  blurRadius: 24,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  mainBtnIcon,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  mainBtnLabel,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Secondary Abort / Reset Action (Crimson Dark)
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: stopTimer,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF93000A).withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFB4AB).withValues(alpha: 0.25),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cancel_rounded,
                  color: Color(0xFFFFB4AB),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'ABORT PROTOCOL',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                    color: const Color(0xFFFFB4AB),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
