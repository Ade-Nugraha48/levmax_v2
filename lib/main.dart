import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:levmax_v2/screens/splash_screen.dart';
import 'package:levmax_v2/services/alarm_service.dart';
import 'package:levmax_v2/services/notif_service.dart';
import 'package:levmax_v2/utils/constants.dart';

/// Entry point utama aplikasi LevMax.
/// Berperan menginisialisasi seluruh service krusial (database lokal, cloud backend, notifikasi) sebelum UI dijalankan.
Future<void> main() async {
  // Memastikan engine Flutter terhubung sempurna sebelum mengeksekusi operasi asynchronous
  WidgetsFlutterBinding.ensureInitialized();

  // [POIN PRESENTASI]: Inisialisasi Hive (NoSQL Local Database) untuk penyimpanan sesi, data quest offline, dan verifikasi blok
  await Hive.initFlutter();
  await Hive.openBox(AppConstants.sessionBox);
  await Hive.openBox(AppConstants.blockchainBox);
  await Hive.openBox(AppConstants.questBox);

  // [POIN PRESENTASI]: Inisialisasi Supabase (BaaS) sebagai remote database untuk autentikasi dan sinkronisasi data online
  await Supabase.initialize(
    url: 'https://urpfytwepfgaybbautcf.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'sb_publishable_MZDpNOFHMgRKp8Ec7rhvKw_RXuO8kpw',
  );

  // Inisialisasi layanan notifikasi lokal dan penjadwalan alarm untuk pengingat quest
  try {
    await NotifService.init();
    await AlarmService.init();
  } catch (_) {}

  runApp(const LevMaxApp());
}

/// Root Widget LevMax dengan Tema Solo Leveling Dark-Purple.
/// Mengatur konfigurasi global aplikasi, tema visual utama, dan navigasi pertama ke SplashScreen.
class LevMaxApp extends StatelessWidget {
  const LevMaxApp({super.key});

  // [POIN PRESENTASI]: Membangun konfigurasi dasar aplikasi (MaterialApp), menerapkan dark theme secara konsisten, dan memuat SplashScreen sebagai halaman awal
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // [UBAH_WARNA: Konfigurasi Tema Utama Aplikasi]
      themeMode: ThemeMode.dark, // [UBAH_WARNA: Mode Tema Global (Dark Mode)]
      home: const SplashScreen(),
    );
  }
}
