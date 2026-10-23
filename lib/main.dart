import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:levmax_v2/screens/auth/login_screen.dart';
import 'package:levmax_v2/screens/main_navigation.dart';
import 'package:levmax_v2/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive Local Database & Buka Boxes yang dibutuhkan
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.sessionBox);
  await Hive.openBox(AppConstants.blockchainBox);
  await Hive.openBox(AppConstants.questBox);

  // Konfigurasi Supabase (Placeholder aman diedit)
  const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://placeholder-project.supabase.co',
  );
  const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'placeholder-anon-key',
  );

  try {
    if (!supabaseUrl.contains('placeholder')) {
      await Supabase.initialize(
        url: supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: supabaseAnonKey,
      );
    } else {
      debugPrint('[LevMax] Supabase: Berjalan dalam mode placeholder/offline.');
    }
  } catch (e) {
    debugPrint('[LevMax] Supabase initialization deferred: $e');
  }

  // Cek keberadaan sesi login di Hive
  final sessionBox = Hive.box(AppConstants.sessionBox);
  final bool isLoggedIn = sessionBox.get('isLoggedIn', defaultValue: false) as bool;

  runApp(LevMaxApp(isLoggedIn: isLoggedIn));
}

/// Root Widget LevMax dengan Tema Solo Leveling Dark-Purple
class LevMaxApp extends StatelessWidget {
  final bool isLoggedIn;

  const LevMaxApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: isLoggedIn ? const MainNavigation() : const LoginScreen(),
    );
  }
}
