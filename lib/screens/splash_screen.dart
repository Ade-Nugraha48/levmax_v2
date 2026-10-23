import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'auth/login_screen.dart';

/// Halaman Pertama: Awakening Splash Screen bertema Solo Leveling
/// Mengadaptasi visual web Tailwind dengan animasi murni Flutter (SingleTickerProviderStateMixin)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    // Inisialisasi controller animasi putaran cincin Mana Reactor
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();

    _handleInitializationAndRouting();
  }

  /// Menunggu durasi animasi splash lalu langsung navigasi ke layar Login tanpa pop-up biometrik otomatis
  Future<void> _handleInitializationAndRouting() async {
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    _navigateToLogin();
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08050E), // Deep Abyss Void
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Background Radial Gradient (#08050E ke #120D24 / ungu abyss gelap)
          gradient: RadialGradient(
            center: Alignment(0, -0.25),
            radius: 1.15,
            colors: [
              Color(0xFF2B1148), // Pendar ungu aura core
              Color(0xFF120D24), // Midnight abyss
              Color(0xFF08050E), // Deep abyss black
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 14.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. Top Header (System Vault)
                        _buildTopHeader(),

                        // 2. Center Hero (Awakening + Mana Reactor Loader)
                        _buildCenterHero(),

                        // 3. Bottom Status Anchor
                        _buildBottomAnchor(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// 1. Top Header: Pill System Vault Protocol dengan Glowing Cyan Beacon
  Widget _buildTopHeader() {
    return Container(
      margin: const EdgeInsets.only(top: 4.0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F091A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2C1E4E),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titik Cyan Glowing
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF00F0FF),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF00F0FF),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'SYSTEM VAULT PROTOCOL  •  NODE-ALPHA',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.8,
              color: Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Center Hero: Emblem Solo Leveling, Judul, Mana Reactor, & Status Telemetri
  Widget _buildCenterHero() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emblem Solo Leveling dengan Shadow Ungu Menyala (#B026FF)
        Container(
          constraints: const BoxConstraints(maxWidth: 290, maxHeight: 155),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB026FF).withValues(alpha: 0.4),
                blurRadius: 45,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Image.network(
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDMXgjosUaovw7DlKRkHq3xmY-ojH0vjen7RFj8ca9Z_1t1g3lpIU4VcowbrLDbAVgRf-waX2dZRNWc-Kjgz0KdR59zAPdvRu-XQn0G6uuoNfKwjk_sPNKHf5qRuhV-CAfoIX-pQnnh51rdCHELNUz671bN6pt8CJNnsStzteUuGBwOdaSz8QuNNs2JybGwzhqzC3_A09H_wRAytF2YMqtmAsAbDvEHG4kxYwgtqWw_Qvv74SnzDqElVDQstsyDNkGy7A',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              'assets/images/solo_leveling_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.shield_rounded,
                size: 72,
                color: Color(0xFFB026FF),
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Teks Judul Hero
        const Text(
          'LEVMAX  ◈  THE HUNTER AWAKENING',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.6,
            color: Color(0xFFF3EFF5),
            shadows: [
              Shadow(
                color: Color(0xFFB026FF),
                blurRadius: 16,
              ),
            ],
          ),
        ),

        const SizedBox(height: 7),

        // Garis Aksen Tipis Gradient Kiri-Kanan
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xFFB026FF)],
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'SYSTEM SYNC IN PROGRESS',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 8.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.2,
                color: Color(0xFFD8B4F8),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB026FF), Colors.transparent],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),

        // 4. Mana Reactor Loader (3 Cincin Konsentris + Pulsing Diamond)
        _buildManaReactorLoader(),

        const SizedBox(height: 28),

        // Teks Status Telemetri
        const Text(
          'Establishing connection to the System...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: Color(0xFFD8B4F8),
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Verifying cryptographic credentials (SHA-256) & local Hive registry...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 10.5,
            letterSpacing: 0.4,
            color: Color(0xFF8B829E),
          ),
        ),
      ],
    );
  }

  /// 4. Mana Reactor Loader dengan 3 layer cincin animasi
  Widget _buildManaReactorLoader() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layer 1: Cincin luar putar lambat (Clockwise) dengan 2 titik orbital
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Cincin Luar Putus-putus
                    CustomPaint(
                      size: const Size(120, 120),
                      painter: _DashedCirclePainter(
                        color: const Color(0xFFB026FF).withValues(alpha: 0.35),
                        strokeWidth: 1.2,
                        dashes: 24,
                      ),
                    ),
                    // Titik Orbital Cyan di Atas
                    Positioned(
                      top: 0,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00F0FF),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF00F0FF),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Titik Orbital Purple di Bawah
                    Positioned(
                      bottom: 0,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFB026FF),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFB026FF),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Layer 2: Cincin tengah berputar berlawanan arah (Counter-Clockwise)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_controller.value * 2 * math.pi * 1.5,
                child: const SizedBox(
                  width: 96,
                  height: 96,
                  child: CustomPaint(
                    painter: _ArcRingPainter(
                      color: Color(0xFFC05CFF),
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
              );
            },
          ),

          // Layer 3: Cincin inti breathing/pulsing dengan Cyan Diamond di tengah
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double breath =
                  (math.sin(_controller.value * 2 * math.pi * 2) + 1) / 2;
              final double scale = 0.94 + (0.06 * breath);

              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0F091A).withValues(alpha: 0.7),
                    border: Border.all(
                      color: Color.lerp(
                        const Color(0xFFB026FF).withValues(alpha: 0.6),
                        const Color(0xFFC05CFF),
                        breath,
                      )!,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB026FF).withValues(
                          alpha: 0.35 + (0.35 * breath),
                        ),
                        blurRadius: 18 + (12 * breath),
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    // Diamond Rune Cyan
                    child: Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6D19A8).withValues(alpha: 0.5),
                          border: Border.all(
                            color: const Color(0xFF00F0FF),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00F0FF).withValues(
                                alpha: 0.8,
                              ),
                              blurRadius: 10 + (6 * breath),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 5. Bottom Status Anchor: Bar Melengkung Telemetri & Core Version
  Widget _buildBottomAnchor() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bar Status Telemetri Melengkung
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0818).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF2C1E4E),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Titik Ungu Neon
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFB026FF),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFB026FF),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 9.5,
                      letterSpacing: 1.1,
                      color: Color(0xFFCBD5E1),
                    ),
                    children: [
                      TextSpan(text: 'SUPABASE RPC: '),
                      TextSpan(
                        text: 'CONNECTING',
                        style: TextStyle(
                          color: Color(0xFF00F0FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '  |  BIOMETRIC SENSOR: ',
                        style: TextStyle(color: Color(0xFF8B829E)),
                      ),
                      TextSpan(
                        text: 'ARMED',
                        style: TextStyle(
                          color: Color(0xFF00FF88),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Version & Mobile Architecture Core Tag
        const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'V1.0.0  •  MOBILE ARCHITECTURE CORE',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 9.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
              color: Color(0xFF6E6485),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom Painter untuk menggambar lingkaran putus-putus pada cincin luar Mana Reactor
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashes;

  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    this.dashes = 24,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final double dashAngle = (2 * math.pi) / (dashes * 2);

    for (int i = 0; i < dashes * 2; i += 2) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * dashAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

/// Custom Painter untuk menggambar busur cincin Layer 2 tanpa memicu error non-uniform circle border
class _ArcRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  const _ArcRingPainter({
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final paint1 = Paint()
      ..color = color.withValues(alpha: 0.9)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paint2 = Paint()
      ..color = color.withValues(alpha: 0.65)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Busur atas ke kanan (dari -pi/2 sepanjang pi/2)
    canvas.drawArc(rect, -math.pi / 2, math.pi / 2, false, paint1);
    // Busur lanjutan kanan ke bawah (dari 0 sepanjang pi/3)
    canvas.drawArc(rect, 0, math.pi / 3, false, paint2);
  }

  @override
  bool shouldRepaint(covariant _ArcRingPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
