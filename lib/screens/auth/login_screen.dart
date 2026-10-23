import 'package:flutter/material.dart';
import 'package:levmax_v2/utils/constants.dart';

/// Halaman UI Login dengan integrasi tema Solo Leveling (Boilerplate Responsif)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Solo Leveling System Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    border: Border.all(color: AppColors.borderGlow, width: 1.5),
                    boxShadow: AppConstants.monarchGlow(),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '[ SYSTEM AWAKENING ]',
                        style: TextStyle(
                          color: AppColors.neonViolet,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'LEVMAX',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          letterSpacing: 3.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Selamat Datang, Hunter',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Masukkan kredensial Anda untuk mengakses sistem.',
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Form Fields
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Hunter Username',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Secret Passcode',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 24),
                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('MASUK KE SISTEM'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
