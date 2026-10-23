import 'package:flutter/material.dart';

/// Halaman UI Registrasi Pengguna Baru (Boilerplate)
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Text('Register Screen - Solo Leveling System'),
        ),
      ),
    );
  }
}
