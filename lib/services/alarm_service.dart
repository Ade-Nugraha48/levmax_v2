import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/alarm_model.dart';
import 'hive_service.dart';

/// AlarmService
/// Service manajemen alarm Solo Leveling System dengan dukungan:
/// - Pengaturan Jam & Menit
/// - Ringtone MP3 Lokal Kustom dari Penyimpanan HP / Default System WAV
/// - Kontrol Intensitas Volume (0% - 100%)
/// - Mode Looping & Notifikasi Suara Alarm
class AlarmService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static bool _isRinging = false;
  static Timer? _activeTimer;
  static VoidCallback? onAlarmStateChanged;

  static const int alarmNotifId = 9999;
  static const String alarmChannelId = 'hunter_alarm_channel';
  static const String alarmChannelName = 'Hunter Awakening Alarm';
  static const String alarmChannelDesc =
      'Saluran khusus alarm latihan & awakening harian dengan prioritas tertinggi';

  static bool get isRinging => _isRinging;

  /// Inisialisasi Audio Player & Konfigurasi Audio Context Alarm
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      final AudioContext audioContext = AudioContext(
        android: const AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.alarm,
          audioFocus: AndroidAudioFocus.gainTransient,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: const {
            AVAudioSessionOptions.duckOthers,
          },
        ),
      );
      await AudioPlayer.global.setAudioContext(audioContext);
    } catch (_) {}

    _isInitialized = true;

    // Aktifkan timer jika alarm tersimpan dalam keadaan aktif
    final alarm = HiveService.getAlarm();
    if (alarm.isEnabled) {
      scheduleAlarm(alarm);
    }
  }

  /// Menjadwalkan alarm berdasarkan konfigurasi jam & menit
  static Future<void> scheduleAlarm(AlarmModel alarm) async {
    await init();
    await HiveService.saveAlarm(alarm);

    _activeTimer?.cancel();

    if (!alarm.isEnabled) {
      await cancelNotification();
      return;
    }

    final now = DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, alarm.hour, alarm.minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final diff = scheduled.difference(now);

    // 1. Timer internal aplikasi
    _activeTimer = Timer(diff, () {
      triggerAlarm(alarm: alarm);
    });

    // 2. Exact Alarm Notification
    try {
      final tz.TZDateTime tzScheduled = tz.TZDateTime.from(scheduled, tz.local);

      const androidDetails = AndroidNotificationDetails(
        alarmChannelId,
        alarmChannelName,
        channelDescription: alarmChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF00F4FE),
        playSound: false, // Suara di-handle oleh AudioPlayer dengan volume kustom
        enableVibration: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
      );

      const notifDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _plugin.zonedSchedule(
        id: alarmNotifId,
        title: '⏰ [HUNTER ALARM: WAKTU LATIHAN TIBA!]',
        body: '${alarm.label} (${alarm.formattedTime}) - Buka aplikasi untuk mematikan alarm!',
        scheduledDate: tzScheduled,
        notificationDetails: notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  /// Membunyikan alarm (Audio Looping + Volume Kustom + Notifikasi Aktif)
  static Future<void> triggerAlarm({AlarmModel? alarm}) async {
    await init();
    final targetAlarm = alarm ?? HiveService.getAlarm();

    _isRinging = true;
    onAlarmStateChanged?.call();

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(targetAlarm.volume.clamp(0.0, 1.0));

      // Jika ada file MP3 lokal yang dipilih dan file masih ada di storage ponsel:
      if (targetAlarm.ringtonePath != null &&
          targetAlarm.ringtonePath!.isNotEmpty &&
          File(targetAlarm.ringtonePath!).existsSync()) {
        await _audioPlayer.play(DeviceFileSource(targetAlarm.ringtonePath!));
      } else {
        // Gunakan ringtone default Solo Leveling system alarm WAV
        await _audioPlayer.play(AssetSource('audio/system_alarm.wav'));
      }
    } catch (e) {
      debugPrint('Error playing alarm audio: $e');
    }

    // Tampilkan notifikasi darurat alarm aktif
    try {
      const androidDetails = AndroidNotificationDetails(
        alarmChannelId,
        alarmChannelName,
        channelDescription: alarmChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        ongoing: true, // Tidak bisa di-swipe sampai alarm dimatikan
        category: AndroidNotificationCategory.alarm,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF00F4FE),
      );

      const notifDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(presentAlert: true, presentSound: false),
      );

      await _plugin.show(
        id: alarmNotifId,
        title: '⏰ [ALARM SEDANG BERBUNYI!]',
        body: '${targetAlarm.label} (${targetAlarm.formattedTime}) - Ketuk untuk mematikan!',
        notificationDetails: notifDetails,
      );
    } catch (_) {}
  }

  /// Mematikan alarm yang sedang berbunyi
  static Future<void> stopAlarm() async {
    _isRinging = false;
    onAlarmStateChanged?.call();

    try {
      await _audioPlayer.stop();
    } catch (_) {}

    await cancelNotification();

    // Jadwalkan kembali untuk hari berikutnya jika alarm tetap aktif
    final alarm = HiveService.getAlarm();
    if (alarm.isEnabled) {
      scheduleAlarm(alarm);
    }
  }

  /// Memutar preview ringtone sementara (untuk pengujian volume & suara di UI)
  static Future<void> previewRingtone({
    String? ringtonePath,
    required double volume,
  }) async {
    await init();
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));

      if (ringtonePath != null &&
          ringtonePath.isNotEmpty &&
          File(ringtonePath).existsSync()) {
        await _audioPlayer.play(DeviceFileSource(ringtonePath));
      } else {
        await _audioPlayer.play(AssetSource('audio/system_alarm.wav'));
      }
    } catch (e) {
      debugPrint('Error previewing ringtone: $e');
    }
  }

  /// Menghentikan preview ringtone
  static Future<void> stopPreview() async {
    try {
      await _audioPlayer.stop();
    } catch (_) {}
  }

  /// Menghapus notifikasi alarm terjadwal
  static Future<void> cancelNotification() async {
    try {
      await _plugin.cancel(id: alarmNotifId);
    } catch (_) {}
  }
}
