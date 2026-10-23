import 'package:flutter/material.dart';
import '../../services/hash_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hunter Codename & Passcode wajib diisi!'),
          backgroundColor: AppColors.hpRed,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi Passcode tidak cocok!'),
          backgroundColor: AppColors.hpRed,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passcode minimal 6 karakter!'),
          backgroundColor: AppColors.hpRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Hash password di sisi client menggunakan SHA-256
      final passwordHash = HashService.hashSha256(password);

      // 2. Insert ke tabel users via SupabaseService dengan exp: 0, gold: 0, rank: 'F', hp: 3
      final result = await SupabaseService.register(
        username: username,
        passwordHash: passwordHash,
        hp: 3,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (result != null) {
        // 3. Notifikasi SnackBar sukses dan kembali ke LoginScreen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hunter $username berhasil terdaftar! Silakan login.'),
            backgroundColor: AppColors.neonViolet,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi gagal. Username mungkin sudah digunakan.'),
            backgroundColor: AppColors.hpRed,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: AppColors.hpRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0713), // Deep Abyss Black
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
              // Top Bar with Back Button
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: const Color(0xFFD8B4F8),
                    iconSize: 18,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF120D24),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF2C1E4E),
                        width: 1.0,
                      ),
                    ),
                    child: const Text(
                      'NODE PROTOCOL: NEW-RECORD',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                        color: AppColors.manaCyan,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Header Titles
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF160F2C),
                        border: Border.all(
                          color: const Color(0xFF8A2BE2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8A2BE2).withValues(alpha: 0.35),
                            blurRadius: 18,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.how_to_reg_rounded,
                          size: 30,
                          color: Color(0xFFB026FF),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'SYSTEM REGISTRATION',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: Color(0xFFF3EFF5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'REGISTER NEW HUNTER CREDENTIALS',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: Color(0xFFD8B4F8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Registration Form Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF120D24),
                  borderRadius: BorderRadius.circular(18),
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
                    // Username
                    const Text(
                      'NEW HUNTER CODENAME',
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
                      controller: _usernameController,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        color: Color(0xFFF3EFF5),
                        fontSize: 13,
                      ),
                      cursorColor: const Color(0xFFB026FF),
                      decoration: InputDecoration(
                        hintText: 'e.g. SungJinWoo',
                        hintStyle: const TextStyle(
                          color: Color(0xFF5D5373),
                          fontSize: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_add_alt_1_outlined,
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

                    // Password
                    const Text(
                      'CREATE SECURITY CIPHER',
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
                        hintText: 'Minimum 6 characters',
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
                    const SizedBox(height: 12),

                    // Confirm Password
                    const Text(
                      'CONFIRM CIPHER',
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
                      controller: _confirmPasswordController,
                      obscureText: _isConfirmObscure,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        color: Color(0xFFF3EFF5),
                        fontSize: 13,
                      ),
                      cursorColor: const Color(0xFFB026FF),
                      decoration: InputDecoration(
                        hintText: 'Re-enter your passcode',
                        hintStyle: const TextStyle(
                          color: Color(0xFF5D5373),
                          fontSize: 12,
                        ),
                        prefixIcon: const Icon(
                          Icons.verified_user_outlined,
                          color: Color(0xFFD8B4F8),
                          size: 18,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF8B829E),
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmObscure = !_isConfirmObscure;
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

              const SizedBox(height: 18),

              // Submit Button
              Container(
                height: 50,
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
                    onTap: _isLoading ? null : _handleRegister,
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
                                  Icons.app_registration_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'INITIATE REGISTRATION',
                                  style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 13.5,
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

              const SizedBox(height: 16),

              // Back to Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have a Hunter ID? ",
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      color: Color(0xFF8B829E),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Portal Login',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFB026FF),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFFB026FF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
