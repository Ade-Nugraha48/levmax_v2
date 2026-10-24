/// Model data untuk Konfigurasi Alarm Sistem Solo Leveling (LevMax)
class AlarmModel {
  final int id;
  final int hour;
  final int minute;
  final bool isEnabled;
  final String label;
  final String ringtoneName;
  final String? ringtonePath;
  final double volume; // 0.0 sampai 1.0 (0% - 100%)
  final bool vibrate;

  const AlarmModel({
    this.id = 101,
    required this.hour,
    required this.minute,
    this.isEnabled = false,
    this.label = 'HUNTER AWAKENING // WAKTU LATIHAN TIBA!',
    this.ringtoneName = 'System Monarch Siren (Default)',
    this.ringtonePath,
    this.volume = 0.8,
    this.vibrate = true,
  });

  /// Alarm default pukul 06:00 pagi
  static AlarmModel get defaultAlarm => const AlarmModel(
        hour: 6,
        minute: 0,
        isEnabled: false,
        label: 'HUNTER AWAKENING // WAKTU LATIHAN TIBA!',
        ringtoneName: 'System Monarch Siren (Default)',
        volume: 0.8,
        vibrate: true,
      );

  /// Format jam dua digit, contoh: "06:30"
  String get formattedTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  AlarmModel copyWith({
    int? id,
    int? hour,
    int? minute,
    bool? isEnabled,
    String? label,
    String? ringtoneName,
    String? ringtonePath,
    bool clearRingtonePath = false,
    double? volume,
    bool? vibrate,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isEnabled: isEnabled ?? this.isEnabled,
      label: label ?? this.label,
      ringtoneName: ringtoneName ?? this.ringtoneName,
      ringtonePath:
          clearRingtonePath ? null : (ringtonePath ?? this.ringtonePath),
      volume: volume ?? this.volume,
      vibrate: vibrate ?? this.vibrate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'isEnabled': isEnabled,
        'label': label,
        'ringtoneName': ringtoneName,
        'ringtonePath': ringtonePath,
        'volume': volume,
        'vibrate': vibrate,
      };

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as int? ?? 101,
      hour: json['hour'] as int? ?? 6,
      minute: json['minute'] as int? ?? 0,
      isEnabled: json['isEnabled'] as bool? ?? false,
      label: json['label'] as String? ?? 'HUNTER AWAKENING // WAKTU LATIHAN TIBA!',
      ringtoneName: json['ringtoneName'] as String? ?? 'System Monarch Siren (Default)',
      ringtonePath: json['ringtonePath'] as String?,
      volume: (json['volume'] as num?)?.toDouble() ?? 0.8,
      vibrate: json['vibrate'] as bool? ?? true,
    );
  }
}
