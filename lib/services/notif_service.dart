import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'hive_service.dart';

/// NotifService
/// Service penanganan notifikasi lokal sistem Solo Leveling LevMax.
/// Mendukung 5 skenario notifikasi:
/// 1. Quest harian direset (00:00 tengah malam)
/// 2. Quest/Dungeon/Mini Game belum dijalankan pada hari itu (14:00 siang)
/// 3. Quest belum dijalankan pada hari itu (dikirim berkala tiap 3 jam server)
/// 4. [Nama AI Personifikasi] kangen dengan user (19:30 malam)
/// 5. Ketika server / hari ingin berakhir (23:00 malam)
class NotifService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  // Channel ID dan Name bertema Solo Leveling Monarch System
  static const String _channelId = 'hunter_system_channel';
  static const String _channelName = 'Hunter System Protocol';
  static const String _channelDesc =
      'Pemberitahuan resmi sistem Solo Leveling mengenai quest harian, reset gate, dan peringatan penalti';

  // ID unik untuk masing-masing skenario notifikasi
  static const int idDailyReset = 2001;
  static const int idUnfinishedActivities = 2002;
  static const int idPeriodic3HoursBase = 2003; // 2003 - 2007 (5 slot 3-jam)
  static const int idAiMissesUser = 2010;
  static const int idEndOfDayWarning = 2011;

  /// Inisialisasi plugin notifikasi lokal & timezone untuk Android & iOS
  static Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: initSettings);

    // Minta izin runtime untuk Android 13+ (POST_NOTIFICATIONS) & Exact Alarm
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
      try {
        await androidImpl.requestExactAlarmsPermission();
      } catch (_) {}
    }

    _isInitialized = true;

    // Otomatis aktifkan seluruh jadwal notifikasi harian
    try {
      await scheduleAllAutomatedNotifications();
    } catch (_) {}
  }

  /// Helper untuk membangun NotificationDetails seragam beraksen Solo Leveling
  static NotificationDetails _buildNotificationDetails({
    String channelId = _channelId,
    String channelName = _channelName,
    String channelDesc = _channelDesc,
    Importance importance = Importance.max,
    Priority priority = Priority.high,
  }) {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: importance,
      priority: priority,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF00F4FE), // Neon Cyan Monarch accent
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  /// Menghitung TZDateTime waktu berikutnya untuk jam dan menit tertentu
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // ===========================================================================
  // 1. SKENARIO: QUEST HARIAN DIRESET (00:00 TENGAH MALAM)
  // ===========================================================================

  /// Menampilkan notifikasi reset quest harian secara langsung (untuk pengujian instan)
  static Future<void> showDailyResetNotif() async {
    if (!_isInitialized) await init();

    await _plugin.show(
      id: idDailyReset,
      title: '⚡ [SYSTEM: DAILY PROTOCOL RESET]',
      body:
          'Waktu server direset! Quest harian dan dungeon gate telah disegarkan. Bangkitlah, Hunter! Selesaikan misi untuk meningkatkan Rank Anda!',
      notificationDetails: _buildNotificationDetails(),
    );
  }

  /// Menjadwalkan notifikasi reset quest harian berulang setiap tengah malam (00:00)
  static Future<void> scheduleDailyResetNotif() async {
    if (!_isInitialized) await init();

    await _plugin.zonedSchedule(
      id: idDailyReset,
      title: '⚡ [SYSTEM: DAILY PROTOCOL RESET]',
      body:
          'Waktu server direset! Quest harian dan dungeon gate telah disegarkan. Bangkitlah, Hunter! Selesaikan misi untuk meningkatkan Rank Anda!',
      scheduledDate: _nextInstanceOfTime(0, 0),
      notificationDetails: _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ===========================================================================
  // 2. SKENARIO: QUEST/DUNGEON/MINI GAMES BELUM DIJALANKAN (14:00 SIANG)
  // ===========================================================================

  /// Menampilkan notifikasi protokol harian belum selesai (pengujian instan)
  static Future<void> showUnfinishedActivitiesNotif() async {
    if (!_isInitialized) await init();

    await _plugin.show(
      id: idUnfinishedActivities,
      title: '⚠️ [SYSTEM ALERT: AKTIVITAS TERTUNDA]',
      body:
          'Hunter, Anda belum menjalankan Quest Fisik, Dungeon Radar, atau Mini-Game Mana hari ini. Segera masuki gate sebelum jam server berakhir!',
      notificationDetails: _buildNotificationDetails(),
    );
  }

  /// Menjadwalkan notifikasi aktivitas tertunda setiap pukul 14:00 siang
  static Future<void> scheduleUnfinishedActivitiesNotif() async {
    if (!_isInitialized) await init();

    await _plugin.zonedSchedule(
      id: idUnfinishedActivities,
      title: '⚠️ [SYSTEM ALERT: AKTIVITAS TERTUNDA]',
      body:
          'Hunter, Anda belum menjalankan Quest Fisik, Dungeon Radar, atau Mini-Game Mana hari ini. Segera masuki gate sebelum jam server berakhir!',
      scheduledDate: _nextInstanceOfTime(14, 0),
      notificationDetails: _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ===========================================================================
  // 3. SKENARIO: QUEST BELUM DIJALANKAN (BERKALA TIAP 3 JAM SERVER)
  // ===========================================================================

  /// Menampilkan notifikasi pengingat quest 3 jam (pengujian instan)
  static Future<void> showPeriodicQuestReminderNotif() async {
    if (!_isInitialized) await init();

    await _plugin.show(
      id: idPeriodic3HoursBase,
      title: '⚔️ [SYSTEM WARNING: SIKLUS 3 JAM]',
      body:
          'Peringatan Berkala: Quest harian masih belum tuntas! Jangan biarkan sistem mengeksekusi penalti pengurangan HP!',
      notificationDetails: _buildNotificationDetails(
        priority: Priority.max,
        importance: Importance.max,
      ),
    );
  }

  /// Menjadwalkan pengingat berulang tiap 3 jam waktu server (09:00, 12:00, 15:00, 18:00, 21:00)
  static Future<void> schedulePeriodic3HourReminders() async {
    if (!_isInitialized) await init();

    final List<int> hours = [9, 12, 15, 18, 21];

    for (int i = 0; i < hours.length; i++) {
      final int hour = hours[i];
      final int notifId = idPeriodic3HoursBase + i;

      await _plugin.zonedSchedule(
        id: notifId,
        title:
            '⚔️ [SYSTEM WARNING: SIKLUS 3 JAM (${hour.toString().padLeft(2, '0')}:00)]',
        body:
            'Peringatan Berkala: Quest harian masih belum tuntas! Selesaikan push-up, squat, dan cardio untuk mengamankan rank Anda!',
        scheduledDate: _nextInstanceOfTime(hour, 0),
        notificationDetails: _buildNotificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  // ===========================================================================
  // 4. SKENARIO: [NAMA CHAT AI] KANGEN DENGAN USER (19:30 MALAM)
  // ===========================================================================

  /// Menampilkan notifikasi AI kangen dengan nama custom dinamis (pengujian instan)
  static Future<void> showAiMissesUserNotif() async {
    if (!_isInitialized) await init();

    final persona = HiveService.getAIPersona();
    final String aiName = persona.name.toUpperCase();

    await _plugin.show(
      id: idAiMissesUser,
      title: '💬 [$aiName // PESAN PRIBADI]',
      body:
          '"Hunter, aku menunggumu di sistem latihan... Jangan biarkan potensimu memudar, ayo login dan lampaui batas kekuatanmu bersamaku!"',
      notificationDetails: _buildNotificationDetails(),
    );
  }

  /// Menjadwalkan notifikasi AI kangen berulang setiap pukul 19:30 malam
  static Future<void> scheduleAiMissesUserNotif() async {
    if (!_isInitialized) await init();

    final persona = HiveService.getAIPersona();
    final String aiName = persona.name.toUpperCase();

    await _plugin.zonedSchedule(
      id: idAiMissesUser,
      title: '💬 [$aiName // PESAN PRIBADI]',
      body:
          '"Hunter, aku menunggumu di sistem latihan... Jangan biarkan potensimu memudar, ayo login dan lampaui batas kekuatanmu bersamaku!"',
      scheduledDate: _nextInstanceOfTime(19, 30),
      notificationDetails: _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ===========================================================================
  // 5. SKENARIO: SERVER / HARI INGIN BERAKHIR (23:00 MALAM)
  // ===========================================================================

  /// Menampilkan notifikasi hari ingin berakhir (pengujian instan)
  static Future<void> showEndOfDayWarningNotif() async {
    if (!_isInitialized) await init();

    await _plugin.show(
      id: idEndOfDayWarning,
      title: '🚨 [SYSTEM CRITICAL: HARI INGIN BERAKHIR]',
      body:
          'Peringatan Kritis! Waktu hari ini tersisa kurang dari 1 jam. Tuntaskan quest Anda sebelum 00:00 untuk menghindari Penalty Quest!',
      notificationDetails: _buildNotificationDetails(
        priority: Priority.max,
        importance: Importance.max,
      ),
    );
  }

  /// Menjadwalkan notifikasi peringatan akhir hari pukul 23:00 malam
  static Future<void> scheduleEndOfDayWarningNotif() async {
    if (!_isInitialized) await init();

    await _plugin.zonedSchedule(
      id: idEndOfDayWarning,
      title: '🚨 [SYSTEM CRITICAL: HARI INGIN BERAKHIR]',
      body:
          'Peringatan Kritis! Waktu hari ini tersisa kurang dari 1 jam. Tuntaskan quest Anda sebelum 00:00 untuk menghindari Penalty Quest!',
      scheduledDate: _nextInstanceOfTime(23, 0),
      notificationDetails: _buildNotificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // ===========================================================================
  // MASTER AUTOMATED SCHEDULER & CONTROLS
  // ===========================================================================

  /// Mengaktifkan seluruh 5 jadwal notifikasi otomatis di latar belakang
  static Future<void> scheduleAllAutomatedNotifications() async {
    if (!_isInitialized) await init();

    await scheduleDailyResetNotif();
    await scheduleUnfinishedActivitiesNotif();
    await schedulePeriodic3HourReminders();
    await scheduleAiMissesUserNotif();
    await scheduleEndOfDayWarningNotif();
  }

  /// Menghapus seluruh jadwal notifikasi yang sedang aktif
  static Future<void> cancelAllNotifications() async {
    if (!_isInitialized) await init();
    await _plugin.cancelAll();
  }

  /// Kompatibilitas mundur: showQuestReminder bawaan
  static Future<void> showQuestReminder() async {
    await showPeriodicQuestReminderNotif();
  }
}
