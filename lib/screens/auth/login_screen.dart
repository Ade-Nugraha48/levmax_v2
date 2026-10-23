import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../../services/hash_service.dart';
import '../../services/hive_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isObscure = true;
  bool _isLoading = false;
  bool _staySynchronized = true;

  @override
  void initState() {
    super.initState();
    // Otentikasi biometrik bersifat opsional saat user menekan tombol biometrik
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  /// Autentikasi biometrik menggunakan local_auth
  Future<void> _triggerBiometricAuth({bool autoPrompt = false}) async {
    try {
      final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) {
        if (!autoPrompt && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sensor biometrik tidak tersedia atau tidak didukung pada perangkat ini.'),
              backgroundColor: AppColors.hpRed,
            ),
          );
        }
        return;
      }

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Pindai sidik jari untuk otorisasi akses cepat ke Hunter System',
      );

      if (didAuthenticate && mounted) {
        _navigateToMain();
      }
    } catch (e) {
      debugPrint('[BiometricAuth] Error: $e');
      if (!autoPrompt && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Autentikasi biometrik gagal: $e'),
            backgroundColor: AppColors.hpRed,
          ),
        );
      }
    }
  }

  /// Validasi login manual: Hash SHA-256 + Supabase Query + Simpan Hive Session
  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hunter Identity & Security Cipher wajib diisi!'),
          backgroundColor: AppColors.hpRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Hash password di sisi client menggunakan SHA-256
      final passwordHash = HashService.hashSha256(password);

      // 2. Validasi username dan passwordHash ke Supabase
      final user = await SupabaseService.login(
        username: username,
        passwordHash: passwordHash,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (user != null) {
        // 3. Simpan userId, username, rank, exp, gold, hp ke Hive sessionBox
        await HiveService.saveSession(
          userId: user['id'].toString(),
          username: user['username'].toString(),
          rank: user['rank']?.toString() ?? 'F',
          exp: (user['exp'] as num?)?.toInt() ?? 0,
          gold: (user['gold'] as num?)?.toInt() ?? 0,
          hp: (user['hp'] as num?)?.toInt() ?? 3,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat datang kembali, Hunter ${user['username']}!'),
            backgroundColor: AppColors.neonViolet,
          ),
        );

        _navigateToMain();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kredensial tidak valid. Silakan periksa kembali.'),
            backgroundColor: AppColors.hpRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login error: $e'),
          backgroundColor: AppColors.hpRed,
        ),
      );
    }
  }

  void _navigateToMain() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigation(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF16111E), // Dark Abyss Background
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Ambient Diffuse Background Glows (No sharp circle edges)
            Positioned(
              top: -80,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    width: 340,
                    height: 340,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFB026FF).withValues(alpha: 0.20),
                          const Color(0xFFB026FF).withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF00F4FE).withValues(alpha: 0.08),
                          const Color(0xFF00F4FE).withValues(alpha: 0.02),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Main Content Flow (Vertically Centered on Screen)
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                  // Top Header: Protocol Status Pill & System Version
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Pill "HUNTER AUTHENTICATION PORTAL"
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF110C19).withValues(alpha: 0.80),
                          borderRadius: BorderRadius.circular(999),
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
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'HUNTER AUTHENTICATION PORTAL',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1.0,
                                color: const Color(0xFFE6FEFF),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right: Shield & SYS_V2.4
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 15,
                            color: Color(0xFFE5B5FF),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'SYS_V2.4',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                              color: const Color(0xFFD2C1D7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Center Hero: Awakened Brand Logo & Title
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft radial diffuse purple backlight
                          Container(
                            width: 160,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFFB026FF).withValues(alpha: 0.35),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/images/solo_leveling_logo.png',
                            height: 76,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 16,
                            height: 1,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.transparent, Color(0xFFE5B5FF)],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'LEVMAX • THE SYSTEM AWAKENING',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2.2,
                              color: const Color(0xFFE5B5FF),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 16,
                            height: 1,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFE5B5FF), Colors.transparent],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Main System Auth Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1927).withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Top Glowing Accent Line
                        Positioned(
                          top: 0,
                          left: 70,
                          right: 70,
                          child: Container(
                            height: 1.0,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFFE5B5FF).withValues(alpha: 0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Field 1: Hunter Identity
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.badge_outlined,
                                        size: 13,
                                        color: Color(0xFFE5B5FF),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'HUNTER IDENTITY',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.0,
                                          color: const Color(0xFFD2C1D7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'CLASS: UNKNOWN',
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFE5B5FF),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 5),

                              // Inset Input 1
                              Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF110C19),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: _usernameController,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFE9DEF2),
                                    fontSize: 14,
                                  ),
                                  cursorColor: const Color(0xFFB026FF),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Sung Jin-Woo / Codename',
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF9B8BA1).withValues(alpha: 0.40),
                                      fontSize: 14,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                      color: Color(0xFF9B8BA1),
                                      size: 18,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 11,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Field 2: Security Cipher
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.vpn_key_outlined,
                                        size: 13,
                                        color: Color(0xFFE5B5FF),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'SECURITY CIPHER',
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 1.0,
                                          color: const Color(0xFFD2C1D7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2D2736),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 4,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF00F4FE),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'SHA-256 READY',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.8,
                                            color: const Color(0xFFE6FEFF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 5),

                              // Inset Input 2
                              Container(
                                height: 42,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF110C19),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: _isObscure,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFE9DEF2),
                                    fontSize: 14,
                                    letterSpacing: _isObscure ? 2.0 : 0.5,
                                  ),
                                  cursorColor: const Color(0xFFB026FF),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: 'Enter Awakened Keyphrase',
                                    hintStyle: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF9B8BA1).withValues(alpha: 0.40),
                                      fontSize: 14,
                                      letterSpacing: 0,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: Color(0xFF9B8BA1),
                                      size: 18,
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isObscure = !_isObscure;
                                        });
                                      },
                                      child: Icon(
                                        _isObscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: const Color(0xFF9B8BA1),
                                        size: 18,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 11,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Stay Synchronized & Lost Cipher
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _staySynchronized = !_staySynchronized;
                                      });
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: _staySynchronized
                                                ? const Color(0xFFB026FF)
                                                : const Color(0xFF110C19),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          child: _staySynchronized
                                              ? const Icon(
                                                  Icons.check,
                                                  size: 11,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Stay Synchronized',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 10,
                                            color: const Color(0xFFD2C1D7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Cipher Recovery: Hubungi Sovereign Hunter System.',
                                          ),
                                          backgroundColor: Color(0xFF2D2736),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'LOST CIPHER?',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        letterSpacing: 0.6,
                                        color: const Color(0xFFDCB8FC),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Primary Button: AWAKEN (LOGIN)
                              Container(
                                height: 44,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF7B2CBF),
                                      Color(0xFF9D4EDD),
                                      Color(0xFFB026FF),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB026FF).withValues(alpha: 0.45),
                                      blurRadius: 24,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: _isLoading ? null : _handleLogin,
                                    child: Center(
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.bolt_rounded,
                                                  color: Color(0xFF00F4FE),
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'AWAKEN (LOGIN)',
                                                  style: GoogleFonts.spaceGrotesk(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.8,
                                                    color: const Color(0xFFFFFDFF),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // Biometric Separator: OR FAST SYSTEM ACCESS
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    height: 1,
                                    color: const Color(0xFF383241),
                                  ),
                                  Container(
                                    color: const Color(0xFF1F1927),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 2,
                                    ),
                                    child: Text(
                                      'OR FAST SYSTEM ACCESS',
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1.5,
                                        color: const Color(0xFF9B8BA1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Dual Biometric Pods (Fingerprint & Face Scan)
                              Row(
                                children: [
                                  // Pod 1: Fingerprint Pod
                                  Expanded(
                                    child: _buildBiometricPod(
                                      title: 'FINGERPRINT',
                                      subtitle: 'Mana Resonance',
                                      icon: Icons.fingerprint_rounded,
                                      iconColor: const Color(0xFFE5B5FF),
                                      glowColor: const Color(0xFFB026FF),
                                      onTap: () => _triggerBiometricAuth(autoPrompt: false),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Pod 2: Face Scan Pod
                                  Expanded(
                                    child: _buildBiometricPod(
                                      title: 'FACE SCAN',
                                      subtitle: 'Neural Recognition',
                                      icon: Icons.document_scanner_outlined,
                                      iconColor: const Color(0xFF00F4FE),
                                      glowColor: const Color(0xFF00F4FE),
                                      onTap: () => _triggerBiometricAuth(autoPrompt: false),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Footer: Registration Link & Status Protocol
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Unregistered Hunter? ',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                color: const Color(0xFFD2C1D7),
                              ),
                            ),
                            Text(
                              'Awaken New Record',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE5B5FF),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: Color(0xFFE5B5FF),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFB026FF),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'SYSTEM SHADOW PROTOCOL • SECURE GATE',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: const Color(0xFF9B8BA1),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricPod({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color glowColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF110C19),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF231D2B),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.35),
                      blurRadius: 14,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: const Color(0xFFE9DEF2),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 9,
                  color: const Color(0xFF9B8BA1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
