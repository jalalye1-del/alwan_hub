import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerAlarmSetting {
  const PrayerAlarmSetting({
    required this.id,
    required this.name,
    required this.time,
    this.enabled = true,
  });

  final String id;
  final String name;
  final TimeOfDay time;
  final bool enabled;

  PrayerAlarmSetting copyWith({TimeOfDay? time, bool? enabled}) {
    return PrayerAlarmSetting(
      id: id,
      name: name,
      time: time ?? this.time,
      enabled: enabled ?? this.enabled,
    );
  }
}

class PrayerReminderSettings {
  const PrayerReminderSettings({
    required this.automaticTimes,
    required this.alarms,
    required this.toneName,
    this.tonePath,
  });

  factory PrayerReminderSettings.defaults() {
    return const PrayerReminderSettings(
      automaticTimes: true,
      toneName: 'نغمة الأذان الافتراضية',
      alarms: [
        PrayerAlarmSetting(
          id: 'fajr',
          name: 'الفجر',
          time: TimeOfDay(hour: 4, minute: 28),
        ),
        PrayerAlarmSetting(
          id: 'dhuhr',
          name: 'الظهر',
          time: TimeOfDay(hour: 12, minute: 12),
        ),
        PrayerAlarmSetting(
          id: 'asr',
          name: 'العصر',
          time: TimeOfDay(hour: 15, minute: 30),
        ),
        PrayerAlarmSetting(
          id: 'maghrib',
          name: 'المغرب',
          time: TimeOfDay(hour: 18, minute: 35),
        ),
        PrayerAlarmSetting(
          id: 'isha',
          name: 'العشاء',
          time: TimeOfDay(hour: 19, minute: 48),
        ),
      ],
    );
  }

  final bool automaticTimes;
  final List<PrayerAlarmSetting> alarms;
  final String toneName;
  final String? tonePath;

  PrayerReminderSettings copyWith({
    bool? automaticTimes,
    List<PrayerAlarmSetting>? alarms,
    String? toneName,
    String? tonePath,
  }) {
    return PrayerReminderSettings(
      automaticTimes: automaticTimes ?? this.automaticTimes,
      alarms: alarms ?? this.alarms,
      toneName: toneName ?? this.toneName,
      tonePath: tonePath ?? this.tonePath,
    );
  }
}

class PrayerSettingsRepository {
  static const _automaticKey = 'prayer_automatic_times';
  static const _toneNameKey = 'prayer_tone_name';
  static const _tonePathKey = 'prayer_tone_path';

  Future<PrayerReminderSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final defaults = PrayerReminderSettings.defaults();
    final alarms = defaults.alarms
        .map((alarm) {
          final storedTime = preferences.getString('prayer_time_${alarm.id}');
          return alarm.copyWith(
            enabled:
                preferences.getBool('prayer_enabled_${alarm.id}') ??
                alarm.enabled,
            time: _decodeTime(storedTime) ?? alarm.time,
          );
        })
        .toList(growable: false);

    final tonePath = preferences.getString(_tonePathKey);
    return PrayerReminderSettings(
      automaticTimes:
          preferences.getBool(_automaticKey) ?? defaults.automaticTimes,
      alarms: alarms,
      toneName: preferences.getString(_toneNameKey) ?? defaults.toneName,
      tonePath: tonePath == null || tonePath.isEmpty ? null : tonePath,
    );
  }

  Future<void> save(PrayerReminderSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    final writes = <Future<bool>>[
      preferences.setBool(_automaticKey, settings.automaticTimes),
      preferences.setString(_toneNameKey, settings.toneName),
      preferences.setString(_tonePathKey, settings.tonePath ?? ''),
    ];

    for (final alarm in settings.alarms) {
      writes.add(
        preferences.setBool('prayer_enabled_${alarm.id}', alarm.enabled),
      );
      writes.add(
        preferences.setString(
          'prayer_time_${alarm.id}',
          '${alarm.time.hour}:${alarm.time.minute}',
        ),
      );
    }
    await Future.wait(writes);
  }

  TimeOfDay? _decodeTime(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
