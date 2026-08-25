import 'dart:math' as math;

import 'package:adhan_dart/adhan_dart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:flutter_compass/flutter_compass.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/profile/data/prayer_settings_repository.dart';
import 'package:alwan_hub/features/profile/presentation/widgets/profile_typography.dart';

const _sanaaCoordinates = Coordinates(15.3694, 44.1910);
const _sanaaUtcOffset = Duration(hours: 3);

class PrayerQiblaScreen extends StatefulWidget {
  const PrayerQiblaScreen({super.key, this.locationLabel = 'صنعاء، اليمن'});

  final String locationLabel;

  @override
  State<PrayerQiblaScreen> createState() => _PrayerQiblaScreenState();
}

class _PrayerQiblaScreenState extends State<PrayerQiblaScreen> {
  final _repository = PrayerSettingsRepository();
  PrayerReminderSettings _settings = PrayerReminderSettings.defaults();
  bool _loading = true;
  bool _selectingTone = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    var settings = await _repository.load();
    if (settings.automaticTimes) {
      settings = _applyAutomaticTimes(settings);
      await _repository.save(settings);
    }
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _loading = false;
    });
  }

  Future<void> _updateSettings(PrayerReminderSettings settings) async {
    setState(() => _settings = settings);
    await _repository.save(settings);
  }

  Future<void> _toggleAutomaticTimes(bool automatic) {
    var settings = _settings.copyWith(automaticTimes: automatic);
    if (automatic) settings = _applyAutomaticTimes(settings);
    return _updateSettings(settings);
  }

  PrayerReminderSettings _applyAutomaticTimes(PrayerReminderSettings settings) {
    final now = DateTime.now();
    final parameters = CalculationMethodParameters.muslimWorldLeague()
      ..madhab = Madhab.shafi;
    final times = PrayerTimes(
      coordinates: _sanaaCoordinates,
      date: DateTime.utc(now.year, now.month, now.day),
      calculationParameters: parameters,
    );
    final calculated = <String, DateTime>{
      'fajr': times.fajr,
      'dhuhr': times.dhuhr,
      'asr': times.asr,
      'maghrib': times.maghrib,
      'isha': times.isha,
    };

    final alarms = settings.alarms
        .map((alarm) {
          final utcTime = calculated[alarm.id];
          if (utcTime == null) return alarm;
          final localTime = utcTime.add(_sanaaUtcOffset);
          return alarm.copyWith(
            time: TimeOfDay(hour: localTime.hour, minute: localTime.minute),
          );
        })
        .toList(growable: false);
    return settings.copyWith(alarms: alarms);
  }

  Future<void> _togglePrayer(String id, bool enabled) {
    final alarms = _settings.alarms
        .map(
          (alarm) => alarm.id == id ? alarm.copyWith(enabled: enabled) : alarm,
        )
        .toList(growable: false);
    return _updateSettings(_settings.copyWith(alarms: alarms));
  }

  Future<void> _pickPrayerTime(PrayerAlarmSetting alarm) async {
    if (_settings.automaticTimes) return;
    final selected = await showTimePicker(
      context: context,
      initialTime: alarm.time,
      helpText: 'تحديد وقت صلاة ${alarm.name}',
      cancelText: 'إلغاء',
      confirmText: 'حفظ',
      builder: (context, child) => ProfileTypography(child: child!),
    );
    if (selected == null || !mounted) return;

    final alarms = _settings.alarms
        .map(
          (item) => item.id == alarm.id ? item.copyWith(time: selected) : item,
        )
        .toList(growable: false);
    await _updateSettings(_settings.copyWith(alarms: alarms));
  }

  Future<void> _pickTone() async {
    if (_selectingTone) return;
    setState(() => _selectingTone = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'اختر نغمة تذكير الصلاة',
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty || !mounted) return;
      final file = result.files.single;
      await _updateSettings(
        _settings.copyWith(
          toneName: file.name,
          tonePath: file.path ?? file.identifier ?? file.name,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تم اعتماد النغمة: ${file.name}')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح الملفات الصوتية على هذا الجهاز'),
        ),
      );
    } finally {
      if (mounted) setState(() => _selectingTone = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileTypography(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFFF7F8FE),
          body: Column(
            children: [
              const AlwanPageHeader(
                title: 'منبه الصلاة وتحديد القبلة',
                subtitle: 'مواقيتك واتجاه قبلتك في مكان واحد',
              ),
              Expanded(
                child: ResponsiveContent(
                  maxWidth: 760,
                  child: Column(
                    children: [
                      const _PrayerQiblaTabs(),
                      const SizedBox(height: 14),
                      Expanded(
                        child: _loading
                            ? const Center(child: CircularProgressIndicator())
                            : TabBarView(
                                children: [
                                  _PrayerTimesView(
                                    settings: _settings,
                                    locationLabel: widget.locationLabel,
                                    selectingTone: _selectingTone,
                                    onAutomaticChanged: _toggleAutomaticTimes,
                                    onPrayerChanged: _togglePrayer,
                                    onPrayerTimeTap: _pickPrayerTime,
                                    onToneTap: _pickTone,
                                  ),
                                  _QiblaView(
                                    locationLabel: widget.locationLabel,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerQiblaTabs extends StatelessWidget {
  const _PrayerQiblaTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D172554),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF6A1B9A)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w900),
        tabs: const [
          Tab(
            icon: Icon(Icons.access_time_filled_rounded),
            child: Text('أوقات الصلاة'),
          ),
          Tab(icon: Icon(Icons.explore_rounded), child: Text('القبلة')),
        ],
      ),
    );
  }
}

class _PrayerTimesView extends StatelessWidget {
  const _PrayerTimesView({
    required this.settings,
    required this.locationLabel,
    required this.selectingTone,
    required this.onAutomaticChanged,
    required this.onPrayerChanged,
    required this.onPrayerTimeTap,
    required this.onToneTap,
  });

  final PrayerReminderSettings settings;
  final String locationLabel;
  final bool selectingTone;
  final ValueChanged<bool> onAutomaticChanged;
  final void Function(String id, bool enabled) onPrayerChanged;
  final ValueChanged<PrayerAlarmSetting> onPrayerTimeTap;
  final VoidCallback onToneTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PrayerSummaryCard(locationLabel: locationLabel),
          const SizedBox(height: 14),
          _TimeModeSelector(
            automatic: settings.automaticTimes,
            onChanged: onAutomaticChanged,
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < settings.alarms.length;
                  index++
                ) ...[
                  _PrayerAlarmRow(
                    alarm: settings.alarms[index],
                    automatic: settings.automaticTimes,
                    onEnabledChanged: (value) =>
                        onPrayerChanged(settings.alarms[index].id, value),
                    onTimeTap: () => onPrayerTimeTap(settings.alarms[index]),
                  ),
                  if (index < settings.alarms.length - 1)
                    const Divider(height: 1, indent: 18, endIndent: 18),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _TonePickerCard(
            toneName: settings.toneName,
            loading: selectingTone,
            onTap: onToneTap,
          ),
        ],
      ),
    );
  }
}

class _PrayerSummaryCard extends StatelessWidget {
  const _PrayerSummaryCard({required this.locationLabel});

  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0E4A85), Color(0xFF3C2588)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF283593).withValues(alpha: .20),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .13),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
            child: const Icon(
              Icons.mosque_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'تنبيهات الصلوات الخمس',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'الموقع المعتمد: $locationLabel',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeModeSelector extends StatelessWidget {
  const _TimeModeSelector({required this.automatic, required this.onChanged});

  final bool automatic;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'طريقة تحديد المواقيت',
            style: TextStyle(
              color: Color(0xFF202B65),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            automatic
                ? 'تُحدّث المواقيت تلقائيًا حسب الموقع'
                : 'اضغط على وقت أي صلاة لتعديله يدويًا',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  selected: automatic,
                  icon: Icons.my_location_rounded,
                  label: 'تلقائي',
                  onTap: () => onChanged(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ModeButton(
                  selected: !automatic,
                  icon: Icons.edit_calendar_rounded,
                  label: 'تحديد يدوي',
                  onTap: () => onChanged(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF293B9B) : const Color(0xFFF4F5FB),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerAlarmRow extends StatelessWidget {
  const _PrayerAlarmRow({
    required this.alarm,
    required this.automatic,
    required this.onEnabledChanged,
    required this.onTimeTap,
  });

  final PrayerAlarmSetting alarm;
  final bool automatic;
  final ValueChanged<bool> onEnabledChanged;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    final color = _prayerColor(alarm.id);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .11),
              shape: BoxShape.circle,
            ),
            child: Icon(_prayerIcon(alarm.id), color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'صلاة ${alarm.name}',
                  style: const TextStyle(
                    color: Color(0xFF202B65),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  alarm.enabled ? 'التذكير مفعّل' : 'التذكير متوقف',
                  style: TextStyle(
                    color: alarm.enabled
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: automatic
                ? const Color(0xFFF2F4F8)
                : const Color(0xFFE9EDFF),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: automatic ? null : onTimeTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      automatic ? Icons.gps_fixed_rounded : Icons.edit_rounded,
                      size: 13,
                      color: const Color(0xFF5363A6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatPrayerTime(alarm.time),
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: Color(0xFF26376F),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Transform.scale(
            scale: .83,
            child: Switch(value: alarm.enabled, onChanged: onEnabledChanged),
          ),
        ],
      ),
    );
  }

  static IconData _prayerIcon(String id) {
    return switch (id) {
      'fajr' => Icons.nights_stay_rounded,
      'dhuhr' => Icons.wb_sunny_rounded,
      'asr' => Icons.light_mode_rounded,
      'maghrib' => Icons.wb_twilight_rounded,
      _ => Icons.dark_mode_rounded,
    };
  }

  static Color _prayerColor(String id) {
    return switch (id) {
      'fajr' => const Color(0xFF5C6BC0),
      'dhuhr' => const Color(0xFFFF9800),
      'asr' => const Color(0xFFF9A825),
      'maghrib' => const Color(0xFFEF6C00),
      _ => const Color(0xFF4527A0),
    };
  }
}

class _TonePickerCard extends StatelessWidget {
  const _TonePickerCard({
    required this.toneName,
    required this.loading,
    required this.onTap,
  });

  final String toneName;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0ECFF), Color(0xFFEAF6FF)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD9D4F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF6D5DF6),
                foregroundColor: Colors.white,
                child: Icon(Icons.music_note_rounded),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نغمة تذكير الصلاة',
                      style: TextStyle(
                        color: Color(0xFF202B65),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      toneName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: loading ? null : onTap,
            icon: loading
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.audio_file_rounded),
            label: Text(
              loading ? 'جارٍ فتح الملفات...' : 'اختيار نغمة من الجهاز',
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'يمكنك اختيار أي ملف صوتي محفوظ في جهازك كنغمة للتذكير.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _QiblaView extends StatelessWidget {
  const _QiblaView({required this.locationLabel});

  static final double qiblaBearing = Qibla.qibla(_sanaaCoordinates);
  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'بوصلة اتجاه القبلة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF202B65),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '${_ArabicCalendar.gregorian(now)}\n${_ArabicCalendar.hijri(now)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 12),
          _LocationPill(locationLabel: _formatLocation(locationLabel)),
          const SizedBox(height: 14),
          _BearingLabel(bearing: qiblaBearing),
          const SizedBox(height: 10),
          StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              final heading = snapshot.data?.heading;
              return _QiblaCompass(
                heading: heading,
                qiblaBearing: qiblaBearing,
              );
            },
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF273586),
              side: const BorderSide(color: Color(0xFFD3D8F0)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () => DefaultTabController.of(context).animateTo(0),
            icon: const Icon(Icons.access_time_filled_rounded),
            label: const Text(
              'الرجوع لمواقيت الصلاة',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatLocation(String value) {
    final parts = value.split(RegExp(r'[،,]'));
    if (parts.length < 2) return value;
    return '${parts[1].trim()} - ${parts[0].trim()}';
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill({required this.locationLabel});

  final String locationLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: Color(0xFF1565C0),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              locationLabel,
              style: const TextStyle(
                color: Color(0xFF26376F),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BearingLabel extends StatelessWidget {
  const _BearingLabel({required this.bearing});

  final double bearing;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'زاوية اتجاه القبلة',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: bearing.round().toString()),
              const WidgetSpan(
                alignment: PlaceholderAlignment.top,
                child: Text(
                  '°',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          textDirection: TextDirection.ltr,
          style: const TextStyle(
            color: Color(0xFF222D75),
            fontSize: 42,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _QiblaCompass extends StatelessWidget {
  const _QiblaCompass({required this.heading, required this.qiblaBearing});

  final double? heading;
  final double qiblaBearing;

  @override
  Widget build(BuildContext context) {
    final currentHeading = heading ?? 0;
    final relativeBearing = (qiblaBearing - currentHeading) % 360;
    final size = context.responsive.value(
      compact: 300,
      medium: 330,
      expanded: 350,
    );

    return Column(
      children: [
        SizedBox.square(
          dimension: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0xFF273475), Color(0xFF11152F)],
                    stops: [.25, 1],
                  ),
                  border: Border.all(color: const Color(0xFFB6C6FF), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF172266).withValues(alpha: .28),
                      blurRadius: 26,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13),
                child: AnimatedRotation(
                  turns: -currentHeading / 360,
                  duration: const Duration(milliseconds: 300),
                  child: const CustomPaint(
                    painter: _CompassDialPainter(),
                    size: Size.infinite,
                  ),
                ),
              ),
              Positioned.fill(
                child: AnimatedRotation(
                  turns: relativeBearing / 360,
                  duration: const Duration(milliseconds: 300),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.translate(
                        offset: Offset(0, -size * .16),
                        child: const Icon(
                          Icons.navigation_rounded,
                          color: Color(0xFFFFC84A),
                          size: 86,
                          shadows: [
                            Shadow(color: Colors.black45, blurRadius: 10),
                          ],
                        ),
                      ),
                      Positioned(top: size * .075, child: const _KaabaMarker()),
                    ],
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC84A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 8),
                  ],
                ),
              ),
              const Positioned(
                top: 2,
                child: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: Color(0xFF56C7FF),
                  size: 34,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: heading == null
                ? const Color(0xFFFFF4DE)
                : const Color(0xFFE7F6EE),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                heading == null
                    ? Icons.info_outline_rounded
                    : Icons.sensors_rounded,
                size: 16,
                color: heading == null
                    ? const Color(0xFF9A6700)
                    : AppColors.success,
              ),
              const SizedBox(width: 6),
              Text(
                heading == null
                    ? 'تُفعّل حركة البوصلة على جهاز يدعم مستشعر الاتجاه'
                    : 'اتجاه الجهاز ${currentHeading.round()}°',
                style: TextStyle(
                  color: heading == null
                      ? const Color(0xFF805900)
                      : AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KaabaMarker extends StatelessWidget {
  const _KaabaMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 39,
      decoration: BoxDecoration(
        color: const Color(0xFF090909),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFFFD76C), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 8)],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 0,
            left: 0,
            child: Container(height: 5, color: const Color(0xFFFFD34E)),
          ),
          Positioned(
            bottom: 3,
            left: 8,
            child: Container(
              width: 8,
              height: 15,
              decoration: BoxDecoration(
                color: const Color(0xFF9B651B),
                border: Border.all(color: const Color(0xFFFFD76C)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  const _CompassDialPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white24;

    canvas.drawCircle(center, radius - 5, ringPaint);
    canvas.drawCircle(center, radius * .68, ringPaint);

    for (var index = 0; index < 72; index++) {
      final angle = (index * 5 - 90) * math.pi / 180;
      final isCardinal = index % 18 == 0;
      final isMajor = index % 3 == 0;
      final length = isCardinal ? 17.0 : (isMajor ? 11.0 : 5.0);
      final outer = Offset(
        center.dx + math.cos(angle) * (radius - 10),
        center.dy + math.sin(angle) * (radius - 10),
      );
      final inner = Offset(
        center.dx + math.cos(angle) * (radius - 10 - length),
        center.dy + math.sin(angle) * (radius - 10 - length),
      );
      canvas.drawLine(
        outer,
        inner,
        Paint()
          ..color = isCardinal
              ? const Color(0xFF65D4FF)
              : (isMajor ? Colors.white70 : Colors.white30)
          ..strokeWidth = isCardinal ? 3 : (isMajor ? 2 : 1)
          ..strokeCap = StrokeCap.round,
      );
    }

    _drawDirection(canvas, center, radius, 'ش', -math.pi / 2);
    _drawDirection(canvas, center, radius, 'ق', 0);
    _drawDirection(canvas, center, radius, 'ج', math.pi / 2);
    _drawDirection(canvas, center, radius, 'غ', math.pi);
  }

  void _drawDirection(
    Canvas canvas,
    Offset center,
    double radius,
    String label,
    double angle,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.rtl,
    )..layout();
    final labelRadius = radius - 41;
    final target = Offset(
      center.dx + math.cos(angle) * labelRadius - painter.width / 2,
      center.dy + math.sin(angle) * labelRadius - painter.height / 2,
    );
    painter.paint(canvas, target);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArabicCalendar {
  static const _weekdays = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static const _gregorianMonths = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  static const _hijriMonths = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  static String gregorian(DateTime date) {
    return '${_weekdays[date.weekday - 1]}، ${date.day} '
        '${_gregorianMonths[date.month - 1]} ${date.year} م';
  }

  static String hijri(DateTime date) {
    final converted = _toHijri(date);
    return '${converted.day} ${_hijriMonths[converted.month - 1]} '
        '${converted.year} هـ';
  }

  static _HijriDate _toHijri(DateTime date) {
    final a = (14 - date.month) ~/ 12;
    final y = date.year + 4800 - a;
    final m = date.month + 12 * a - 3;
    final julianDay =
        date.day +
        ((153 * m + 2) ~/ 5) +
        365 * y +
        (y ~/ 4) -
        (y ~/ 100) +
        (y ~/ 400) -
        32045;

    var l = julianDay - 1948440 + 10632;
    final n = (l - 1) ~/ 10631;
    l = l - 10631 * n + 354;
    final j =
        ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
        (l ~/ 5670) * ((43 * l) ~/ 15238);
    l =
        l -
        ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) +
        29;
    final month = (24 * l) ~/ 709;
    final day = l - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;
    return _HijriDate(year: year, month: month, day: day);
  }
}

class _HijriDate {
  const _HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  final int year;
  final int month;
  final int day;
}

String _formatPrayerTime(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'ص' : 'م';
  return '$hour:$minute $period';
}
