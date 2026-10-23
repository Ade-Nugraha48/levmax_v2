import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service untuk penanganan notifikasi lokal harian via flutter_local_notifications
class NotifService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  /// Inisialisasi plugin notifikasi lokal untuk Android & iOS
  static Future<void> init() async {
    if (_isInitialized) return;

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

    // Request runtime permission for Android 13+ (API 33+)
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      await androidImpl.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  /// Menampilkan notifikasi pengingat quest harian
  static Future<void> showQuestReminder() async {
    if (!_isInitialized) {
      await init();
    }

    const androidDetails = AndroidNotificationDetails(
      'quest_reminder_channel',
      'Quest Reminders',
      channelDescription:
          'Notifikasi peringatan quest harian hunter untuk mencegah penalti HP',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id: 1001,
      title: 'System Alert!',
      body: 'Hunter! Selesaikan minimal 3 quest harian agar HP tidak berkurang!',
      notificationDetails: notificationDetails,
    );
  }
}
