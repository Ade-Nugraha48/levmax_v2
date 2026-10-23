import 'package:flutter/material.dart';
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
      backgroundColor: const Color(0xFF16111E), // Dark Abyss
      body: SafeArea(
        child: Stack(
          children: [
            // 1. Ambient Background Glows (Mana Surge & Cyber Backlight)
            Positioned(
              top: -50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFB026FF).withValues(alpha: 0.16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB026FF).withValues(alpha: 0.22),
                        blurRadius: 90,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00F4FE).withValues(alpha: 0.08),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F4FE).withValues(alpha: 0.12),
                        blurRadius: 90,
                        spreadRadius: 25,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. Main Scrollable Content
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top Section: Header & Hero
                          Column(
                            children: [
                              // Top Header: Protocol Status Pill & System Version
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Pill "HUNTER AUTHENTICATION PORTAL"
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF110C19).withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFF2D2736),
                                        width: 0.8,
                                      ),
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
                                                spreadRadius: 1.5,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 7),
                                        const Text(
                                          'HUNTER AUTHENTICATION PORTAL',
                                          style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.2,
                                            color: Color(0xFFE6FEFF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Right: Shield & SYS_V2.4
                                  const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.security_rounded,
                                        size: 15,
                                        color: Color(0xFFE5B5FF),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'SYS_V2.4',
                                        style: TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.0,
                                          color: Color(0xFFD2C1D7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Center Hero: Awakened Brand Logo
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 140,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFB026FF).withValues(alpha: 0.45),
                                          blurRadius: 40,
                                          spreadRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Image.asset(
                                    'assets/images/solo_leveling_logo.png',
                                    height: 74,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => Image.network(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuBt-Ugw9qKLfyMF_yb9l94IOUsbDQo6Tur25xVa5B6hEYjde831VoInnKBQnc4J-KMjnI79iPaIJnl56xGscNn8vaQqvszSmP_KF9xUSw0LnSSjBi_LwfeaMPiPjjSpQP8oTe27xvvARYejzoArDLMPb84-NJI0_SerQNfE-5mD8YixH8t7Ks3pokp6mdNYjyhDYEBAvpx5AkfVfSPpsggeHolfd-2Uj5FDFbZTb1OhE67rnxTFsgy0pXi-UgSEOTnd5Q',
                                      height: 74,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              // Sub-brand line: — LEVMAX • THE SYSTEM AWAKENING —
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 18,
                                    height: 1,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.transparent, Color(0xFFE5B5FF)],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'LEVMAX • THE SYSTEM AWAKENING',
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2.2,
                                      color: Color(0xFFE5B5FF),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 18,
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

                          const SizedBox(height: 12),

                          // Main System Auth Card
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F1927).withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF2D2736),
                                width: 1.0,
                              ),
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
                                  left: 60,
                                  right: 60,
                                  child: Container(
                                    height: 1.2,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Color(0xFFE5B5FF),
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
                                      const Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.badge_outlined,
                                                size: 14,
                                                color: Color(0xFFE5B5FF),
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'HUNTER IDENTITY',
                                                style: TextStyle(
                                                  fontFamily: 'Sora',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1.1,
                                                  color: Color(0xFFD2C1D7),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            'CLASS: UNKNOWN',
                                            style: TextStyle(
                                              fontFamily: 'Sora',
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.8,
                                              color: Color(0xFFE5B5FF),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      TextField(
                                        controller: _usernameController,
                                        style: const TextStyle(
                                          fontFamily: 'Sora',
                                          color: Color(0xFFE9DEF2),
                                          fontSize: 13,
                                        ),
                                        cursorColor: const Color(0xFFB026FF),
                                        decoration: InputDecoration(
                                          hintText: 'Sung Jin-Woo / Codename',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Sora',
                                            color: const Color(0xFF9B8BA1).withValues(alpha: 0.45),
                                            fontSize: 12.5,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.person_outline,
                                            color: Color(0xFF9B8BA1),
                                            size: 19,
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFF110C19),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF231D2B),
                                              width: 1.0,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF231D2B),
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFB026FF),
                                              width: 1.2,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Field 2: Security Cipher
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(
                                                Icons.vpn_key_outlined,
                                                size: 14,
                                                color: Color(0xFFE5B5FF),
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'SECURITY CIPHER',
                                                style: TextStyle(
                                                  fontFamily: 'Sora',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1.1,
                                                  color: Color(0xFFD2C1D7),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2.5,
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
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color(0xFF00F4FE),
                                                        blurRadius: 4,
                                                        spreadRadius: 1,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                const Text(
                                                  'SHA-256 READY',
                                                  style: TextStyle(
                                                    fontFamily: 'Sora',
                                                    fontSize: 8.5,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 0.8,
                                                    color: Color(0xFF00F4FE),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 6),

                                      TextField(
                                        controller: _passwordController,
                                        obscureText: _isObscure,
                                        style: const TextStyle(
                                          fontFamily: 'Sora',
                                          color: Color(0xFFE9DEF2),
                                          fontSize: 13,
                                        ),
                                        cursorColor: const Color(0xFFB026FF),
                                        decoration: InputDecoration(
                                          hintText: 'Enter Awakened Keyphrase',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Sora',
                                            color: const Color(0xFF9B8BA1).withValues(alpha: 0.45),
                                            fontSize: 12.5,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.lock_outline,
                                            color: Color(0xFF9B8BA1),
                                            size: 19,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isObscure
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                              color: const Color(0xFF9B8BA1),
                                              size: 19,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isObscure = !_isObscure;
                                              });
                                            },
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFF110C19),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 12,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF231D2B),
                                              width: 1.0,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: Color(0xFF231D2B),
                                              width: 1.0,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFB026FF),
                                              width: 1.2,
                                            ),
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

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
                                                  width: 15,
                                                  height: 15,
                                                  decoration: BoxDecoration(
                                                    color: _staySynchronized
                                                        ? const Color(0xFFB026FF)
                                                        : const Color(0xFF110C19),
                                                    borderRadius: BorderRadius.circular(3.5),
                                                    border: Border.all(
                                                      color: _staySynchronized
                                                          ? const Color(0xFFB026FF)
                                                          : const Color(0xFF4F4255),
                                                      width: 1.2,
                                                    ),
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
                                                const Text(
                                                  'Stay Synchronized',
                                                  style: TextStyle(
                                                    fontFamily: 'Sora',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w400,
                                                    color: Color(0xFFD2C1D7),
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
                                                    'Cipher Recovery: Hubungi System Administrator / Sovereign.',
                                                  ),
                                                  backgroundColor: Color(0xFF2D2736),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'LOST CIPHER?',
                                              style: TextStyle(
                                                fontFamily: 'Sora',
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.8,
                                                color: Color(0xFFDCB8FC),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 14),

                                      // Primary Button: AWAKEN (LOGIN)
                                      Container(
                                        height: 48,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
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
                                              blurRadius: 20,
                                              spreadRadius: 1,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(10),
                                            onTap: _isLoading ? null : _handleLogin,
                                            child: Center(
                                              child: _isLoading
                                                  ? const SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2.2,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : const Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.bolt_rounded,
                                                          color: Color(0xFF00F4FE),
                                                          size: 20,
                                                        ),
                                                        SizedBox(width: 7),
                                                        Text(
                                                          'AWAKEN (LOGIN)',
                                                          style: TextStyle(
                                                            fontFamily: 'Sora',
                                                            fontSize: 13,
                                                            fontWeight: FontWeight.w800,
                                                            letterSpacing: 1.4,
                                                            color: Colors.white,
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
                                          const Divider(
                                            color: Color(0xFF383241),
                                            thickness: 1,
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 2.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1F1927),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'OR FAST SYSTEM ACCESS',
                                              style: TextStyle(
                                                fontFamily: 'Sora',
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 1.1,
                                                color: Color(0xFF9B8BA1),
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
                                          const SizedBox(width: 12),
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
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Unregistered Hunter? ',
                                      style: TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFFD2C1D7),
                                      ),
                                    ),
                                    Text(
                                      'Awaken New Record',
                                      style: TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFE5B5FF),
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 13,
                                      color: Color(0xFFE5B5FF),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFB026FF),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFFB026FF),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'SYSTEM SHADOW PROTOCOL • SECURE GATE',
                                    style: TextStyle(
                                      fontFamily: 'Sora',
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.4,
                                      color: Color(0xFF9B8BA1),
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
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF110C19),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF231D2B),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF231D2B),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
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
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: Color(0xFFE9DEF2),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 8.5,
                  color: Color(0xFF9B8BA1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
