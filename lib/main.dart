import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:levmax_v2/screens/splash_screen.dart';
import 'package:levmax_v2/services/alarm_service.dart';
import 'package:levmax_v2/services/notif_service.dart';
import 'package:levmax_v2/utils/constants.dart';

Future<void> main() async {
  // Wajib untuk binding sebelum pemanggilan asynchronous runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Hive Local Database & Buka Boxes
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.sessionBox);
  await Hive.openBox(AppConstants.blockchainBox);
  await Hive.openBox(AppConstants.questBox);

  // 2. Inisialisasi Supabase menggunakan kredensial riil
  await Supabase.initialize(
    url: 'https://urpfytwepfgaybbautcf.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'sb_publishable_MZDpNOFHMgRKp8Ec7rhvKw_RXuO8kpw',
  );

  // 3. Inisialisasi Notifikasi Lokal & Alarm Service
  try {
    await NotifService.init();
    await AlarmService.init();
  } catch (_) {}

  runApp(const LevMaxApp());
}
//
/// Root Widget LevMax dengan Tema Solo Leveling Dark-Purple
class LevMaxApp extends StatelessWidget {
  const LevMaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}
