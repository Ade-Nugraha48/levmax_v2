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

  @override
  void initState() {
    super.initState();
    // Di dalam initState, buat pengecekan sesi dari Hive & picu popup biometrik jika sudah login
    _checkStoredSessionAndBiometrics();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Cek sesi dari Hive. Jika isLoggedIn true, langsung picu popup biometrik
  Future<void> _checkStoredSessionAndBiometrics() async {
    final session = HiveService.getSession();
    final bool isLoggedIn = session['isLoggedIn'] == true;

    if (isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerBiometricAuth(autoPrompt: true);
      });
    }
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
      backgroundColor: const Color(0xFF0B0713), // Deep Abyss Black
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top System Protocol Badge
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF120D24),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF2C1E4E),
                      width: 1.0,
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
                      const SizedBox(width: 6),
                      const Text(
                        'HUNTER AUTHENTICATION PORTAL',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                          color: AppColors.textLavender,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Solo Leveling Authentic Logo & Branding Header
              Center(
                child: Column(
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxHeight: 82),
                      child: Image.asset(
                        'assets/images/solo_leveling_logo.png', // Authentic Solo Leveling Logo
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.shield_outlined,
                          size: 48,
                          color: Color(0xFFB026FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'LEVMAX • THE SYSTEM AWAKENING',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: Color(0xFFD8B4F8),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Form Inputs Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF120D24),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF2C1E4E),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hunter Identity Label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'HUNTER IDENTITY',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Color(0xFFD8B4F8),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1433),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'CLASS: ACTIVE',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF00E5FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        color: Color(0xFFF3EFF5),
                        fontSize: 13,
                      ),
                      cursorColor: const Color(0xFFB026FF),
                      decoration: InputDecoration(
                        hintText: 'Enter Hunter Codename',
                        hintStyle: const TextStyle(
                          color: Color(0xFF5D5373),
                          fontSize: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFFD8B4F8),
                          size: 18,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0D0818),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF24193F),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFB026FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password Label
                    const Text(
                      'SECURITY CIPHER',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: Color(0xFFD8B4F8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        color: Color(0xFFF3EFF5),
                        fontSize: 13,
                      ),
                      cursorColor: const Color(0xFFB026FF),
                      decoration: InputDecoration(
                        hintText: 'Enter Secret Passcode',
                        hintStyle: const TextStyle(
                          color: Color(0xFF5D5373),
                          fontSize: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: Color(0xFFD8B4F8),
                          size: 18,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF8B829E),
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: const Color(0xFF0D0818),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF24193F),
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFB026FF),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Awaken (Login) Button
              Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B2CBF), Color(0xFFB026FF)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB026FF).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
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
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'AWAKEN (LOGIN)',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
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
                ),
              ),

              const Spacer(flex: 1),

              // Dual Biometric Authentication Options: Fingerprint & Face Scan
              Column(
                children: [
                  const Text(
                    'OR FAST SYSTEM ACCESS',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                      color: Color(0xFF8B829E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Option 1: Fingerprint Pod
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => _triggerBiometricAuth(autoPrompt: false),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF120D24),
                                border: Border.all(
                                  color: const Color(0xFF8A2BE2).withValues(alpha: 0.7),
                                  width: 1.4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFB026FF).withValues(alpha: 0.25),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.fingerprint_rounded,
                                  size: 26,
                                  color: Color(0xFFD8B4F8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Fingerprint',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 9.5,
                              color: Color(0xFF8B829E),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 28),

                      // Option 2: Face Scan Pod
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => _triggerBiometricAuth(autoPrompt: false),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF120D24),
                                border: Border.all(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.7),
                                  width: 1.4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.face_retouching_natural_rounded,
                                  size: 24,
                                  color: Color(0xFF00E5FF),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Face Scan',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 9.5,
                              color: Color(0xFF8B829E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const Spacer(flex: 1),

              // Bottom Navigation to Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Unregistered Hunter? ",
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 11.5,
                      color: Color(0xFF8B829E),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Awaken New Record',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB026FF),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFB026FF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
