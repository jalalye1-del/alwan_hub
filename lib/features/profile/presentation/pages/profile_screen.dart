import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/theme/theme_mode_controller.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:alwan_hub/features/profile/data/profile_repository.dart';
import 'package:alwan_hub/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/appearance_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/app_rating_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/language_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/prayer_qibla_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/share_app_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/stream_quality_screen.dart';
import 'package:alwan_hub/features/profile/presentation/widgets/profile_typography.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repository = ProfileRepository();
  UserProfile _profile = const UserProfile.initial();
  String _streamQuality = 'عالية';
  String _language = 'العربية';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final values = await Future.wait([
      _repository.load(),
      _repository.loadStreamQuality(),
      _repository.loadLanguage(),
    ]);
    if (!mounted) return;
    setState(() {
      _profile = values[0] as UserProfile;
      _streamQuality = values[1] as String;
      _language = values[2] as String;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileTypography(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        body: Column(
          children: [
            AlwanPageHeader(
              title: 'الملف الشخصي',
              onNotificationTap: () => _push(const NotificationsScreen()),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: ResponsiveContent(
                        maxWidth: 820,
                        child: Column(
                          children: [
                            _ProfileHero(
                              profile: _profile,
                              onEdit: _editProfile,
                            ),
                            const SizedBox(height: 16),
                            _SettingsCard(
                              children: [
                                _SettingItem(
                                  emoji: '🔔',
                                  title: 'الإشعارات',
                                  subtitle:
                                      'تابع أحدث التنبيهات والعروض وبث البرامج المباشرة',
                                  onTap: () =>
                                      _push(const NotificationsScreen()),
                                ),
                                _SettingItem(
                                  emoji: '🕌',
                                  title: 'منبه الصلاة وتحديد القبلة',
                                  subtitle:
                                      'مواقيت الصلوات والنغمة وبوصلة اتجاه القبلة',
                                  onTap: () => _push(
                                    PrayerQiblaScreen(
                                      locationLabel: _profile.city,
                                    ),
                                  ),
                                ),
                                _SettingItem(
                                  emoji: '🌐',
                                  title: 'اللغة لتصفح التطبيق',
                                  subtitle: 'اللغة الحالية: $_language',
                                  onTap: _chooseLanguage,
                                ),
                                _SettingItem(
                                  emoji: '📶',
                                  title: 'جودة البث المناسبة لك',
                                  subtitle:
                                      'درجة الجودة الحالية: $_streamQuality',
                                  onTap: _chooseQuality,
                                ),
                                _SettingItem(
                                  emoji: '🎨',
                                  title: 'المظهر',
                                  subtitle:
                                      'المظهر الحالي: ${_themeLabel(AppThemeModeController.instance.value)}',
                                  onTap: _chooseTheme,
                                ),
                                _SettingItem(
                                  emoji: '⭐',
                                  title: 'تقييم التطبيق',
                                  subtitle:
                                      'شاركنا رأيك واقترح علينا كيف نتحسن',
                                  onTap: () => _push(const AppRatingScreen()),
                                ),
                                _SettingItem(
                                  emoji: '📤',
                                  title: 'مشاركة التطبيق',
                                  subtitle:
                                      'شارك التطبيق مع أصدقائك عبر وسائل التواصل',
                                  onTap: () => _push(const ShareAppScreen()),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(profile: _profile)),
    );
    if (result != null && mounted) setState(() => _profile = result);
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _chooseLanguage() async {
    final language = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => LanguageScreen(initialLanguage: _language),
      ),
    );
    if (language != null && mounted) {
      setState(() => _language = language);
    }
  }

  Future<void> _chooseQuality() async {
    final quality = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => StreamQualityScreen(initialQuality: _streamQuality),
      ),
    );
    if (quality != null && mounted) {
      setState(() => _streamQuality = quality);
    }
  }

  Future<void> _chooseTheme() async {
    final mode = await Navigator.push<ThemeMode>(
      context,
      MaterialPageRoute(builder: (_) => const AppearanceScreen()),
    );
    if (mode != null && mounted) setState(() {});
  }

  String _themeLabel(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'نهاري',
      ThemeMode.dark => 'ليلي',
      ThemeMode.system => 'تلقائي حسب الجهاز',
    };
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile, required this.onEdit});

  final UserProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF130926), Color(0xFF5E35B1), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5E35B1).withValues(alpha: .25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .14),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 56,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            profile.city,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Text(
            profile.bio,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Text('🏆'),
                label: Text('${profile.points} نقطة'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('تعديل الملف'),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text(
            '🟡 رصيد نقاط الألعاب والجوائز اليومي للفن اليماني',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: .4),
        ),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingItem extends StatelessWidget {
  const _SettingItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 21)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
      trailing: Icon(
        Directionality.of(context) == TextDirection.rtl
            ? Icons.chevron_left_rounded
            : Icons.chevron_right_rounded,
      ),
    );
  }
}
