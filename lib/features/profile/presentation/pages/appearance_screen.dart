import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/theme/theme_mode_controller.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:alwan_hub/features/profile/presentation/widgets/profile_typography.dart';
import 'package:alwan_hub/features/profile/presentation/widgets/profile_ad_banner.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  static const _options = <_AppearanceOption>[
    _AppearanceOption(
      mode: ThemeMode.light,
      title: 'نهاري',
      subtitle: 'فاتح وواضح',
      icon: Icons.light_mode_rounded,
    ),
    _AppearanceOption(
      mode: ThemeMode.dark,
      title: 'ليلي',
      subtitle: 'داكن ومريح',
      icon: Icons.dark_mode_rounded,
    ),
    _AppearanceOption(
      mode: ThemeMode.system,
      title: 'تلقائي',
      subtitle: 'حسب الجهاز',
      icon: Icons.brightness_auto_rounded,
    ),
  ];

  late ThemeMode _selectedMode;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedMode = AppThemeModeController.instance.value;
  }

  _AppearanceOption get _selectedOption => _options.firstWhere(
    (option) => option.mode == _selectedMode,
    orElse: () => _options.last,
  );

  @override
  Widget build(BuildContext context) {
    final currentIsDark = Theme.of(context).brightness == Brightness.dark;
    return ProfileTypography(
      child: Scaffold(
        backgroundColor: currentIsDark
            ? const Color(0xFF091A34)
            : const Color(0xFFF7F8FD),
        body: Column(
          children: [
            AlwanPageHeader(
              title: 'المظهر',
              subtitle: 'صمّم تجربتك كما تحب',
              dark: currentIsDark,
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: ResponsiveContent(
                  maxWidth: 760,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const _AppearanceAdBanner(),
                      Padding(
                        padding: context.responsive.pagePadding,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _AppearanceIntro(dark: currentIsDark),
                            const SizedBox(height: 14),
                            _LiveThemePreview(mode: _selectedMode),
                            const SizedBox(height: 16),
                            _AppearanceOptions(
                              options: _options,
                              selectedMode: _selectedMode,
                              onSelected: (mode) =>
                                  setState(() => _selectedMode = mode),
                            ),
                            const SizedBox(height: 14),
                            _ThemeSummary(
                              option: _selectedOption,
                              dark: currentIsDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 728),
                child: _SaveAppearanceButton(
                  saving: _saving,
                  onPressed: _saveAppearance,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAppearance() async {
    setState(() => _saving = true);
    await AppThemeModeController.instance.update(_selectedMode);
    if (!mounted) return;
    setState(() => _saving = false);

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(_selectedMode);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم اعتماد المظهر ${_selectedOption.title}')),
    );
  }
}

class _AppearanceOption {
  const _AppearanceOption({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final ThemeMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
}

class _AppearanceAdBanner extends StatelessWidget {
  const _AppearanceAdBanner();

  @override
  Widget build(BuildContext context) {
    return const ProfileAdBanner(
      imageAsset: 'assets/images/banners/banner1.jpg',
      headline: 'اختيارات مميزة تضيف لونًا جديدًا ليومك',
    );
  }
}

class _AppearanceIntro extends StatelessWidget {
  const _AppearanceIntro({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'اختر المظهر الذي يناسبك',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? Colors.white : const Color(0xFF222B65),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'عاين النتيجة قبل تطبيقها على كامل المنصة',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? Colors.white60 : AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _LiveThemePreview extends StatelessWidget {
  const _LiveThemePreview({required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final resolvedDark = switch (mode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };
    final surface = resolvedDark
        ? const Color(0xFF10294D)
        : const Color(0xFFFFFFFF);
    final background = resolvedDark
        ? const Color(0xFF071A35)
        : const Color(0xFFEFF3FA);
    final foreground = resolvedDark ? Colors.white : const Color(0xFF253063);
    final secondary = resolvedDark ? Colors.white60 : const Color(0xFF7B8798);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      height: 145,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: resolvedDark
              ? const Color(0xFF27476E)
              : const Color(0xFFD8DFEA),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Color(0x19000000), blurRadius: 8),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF303A92), Color(0xFF9B22AF)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.graphic_eq_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 6,
                              width: 72,
                              decoration: BoxDecoration(
                                color: foreground.withValues(alpha: .86),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              height: 4,
                              width: 48,
                              decoration: BoxDecoration(
                                color: secondary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      for (var index = 0; index < 4; index++) ...[
                        Expanded(
                          child: Container(
                            height: index == 1 ? 27 : 21,
                            decoration: BoxDecoration(
                              color: index == 1
                                  ? const Color(0xFF8130A6)
                                  : background,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        if (index != 3) const SizedBox(width: 5),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF303A92), Color(0xFFA521AE)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 19,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 19,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceOptions extends StatelessWidget {
  const _AppearanceOptions({
    required this.options,
    required this.selectedMode,
    required this.onSelected,
  });

  final List<_AppearanceOption> options;
  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < options.length; index++) ...[
          Expanded(
            child: _AppearanceCard(
              option: options[index],
              selected: options[index].mode == selectedMode,
              onTap: () => onSelected(options[index].mode),
            ),
          ),
          if (index != options.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _AppearanceCard extends StatelessWidget {
  const _AppearanceCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _AppearanceOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ambientDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          constraints: const BoxConstraints(minHeight: 148),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 11),
          decoration: BoxDecoration(
            color: selected
                ? ambientDark
                      ? const Color(0xFF192D50)
                      : const Color(0xFFF9F4FF)
                : ambientDark
                ? const Color(0xFF10294D)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xFF8A2DA8)
                  : ambientDark
                  ? const Color(0xFF29476C)
                  : const Color(0xFFDCE1EB),
              width: selected ? 2.2 : 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: const Color(0xFF672996).withValues(alpha: .18),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF7C32A3)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF7C32A3)
                          : const Color(0xFFBCC7D7),
                    ),
                  ),
                  child: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: switch (option.mode) {
                    ThemeMode.light => const Color(0xFFFFF2D8),
                    ThemeMode.dark => const Color(0xFFE7ECF7),
                    ThemeMode.system => const Color(0xFFEAE9FA),
                  },
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  option.icon,
                  color: switch (option.mode) {
                    ThemeMode.light => const Color(0xFFF2A100),
                    ThemeMode.dark => const Color(0xFF394C86),
                    ThemeMode.system => const Color(0xFF6E45A8),
                  },
                  size: 27,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                option.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ambientDark ? Colors.white : const Color(0xFF2D336B),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                option.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ambientDark ? Colors.white60 : AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSummary extends StatelessWidget {
  const _ThemeSummary({required this.option, required this.dark});

  final _AppearanceOption option;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final message = switch (option.mode) {
      ThemeMode.light => 'وضوح عالٍ وألوان مشرقة للاستخدام نهارًا',
      ThemeMode.dark => 'إضاءة منخفضة وراحة أكبر للعين ليلًا',
      ThemeMode.system => 'يتغير تلقائيًا ليتوافق مع إعدادات جهازك',
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: Container(
        key: ValueKey(option.mode),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF10294D) : const Color(0xFFEFF5FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dark ? const Color(0xFF29486E) : const Color(0xFFC9DCF8),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF19385F) : const Color(0xFFDFEAFE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                option.icon,
                color: dark ? const Color(0xFFB9CCF1) : const Color(0xFF3154A0),
                size: 21,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'المظهر ${option.title}',
                    style: TextStyle(
                      color: dark ? Colors.white : const Color(0xFF283B78),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: dark ? Colors.white60 : AppColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SaveAppearanceButton extends StatelessWidget {
  const _SaveAppearanceButton({required this.saving, required this.onPressed});

  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
            colors: [Color(0xFF31368B), Color(0xFF9B20B2)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3D5E238C),
              blurRadius: 14,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: saving ? null : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.palette_rounded),
          label: Text(
            saving ? 'جارٍ الحفظ...' : 'حفظ المظهر والرجوع',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
