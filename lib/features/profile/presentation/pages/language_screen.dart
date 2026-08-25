import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/localization/app_locale_controller.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:alwan_hub/features/profile/data/profile_repository.dart';
import 'package:alwan_hub/features/profile/presentation/widgets/profile_typography.dart';
import 'package:alwan_hub/features/profile/presentation/widgets/profile_ad_banner.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key, this.initialLanguage});

  final String? initialLanguage;

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  static const _languages = <_LanguageOption>[
    _LanguageOption(
      value: 'العربية',
      nativeName: 'العربية',
      internationalName: 'Arabic',
      flag: '🇾🇪',
      greeting: 'مرحبًا بك',
      available: true,
    ),
    _LanguageOption(
      value: 'English',
      nativeName: 'English',
      internationalName: 'الإنجليزية',
      flag: '🇬🇧',
      greeting: 'Welcome',
      available: true,
    ),
  ];

  final _repository = ProfileRepository();
  late String _selectedLanguage;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.initialLanguage ?? 'العربية';
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    if (widget.initialLanguage != null) {
      setState(() => _loading = false);
      return;
    }

    final language = await _repository.loadLanguage();
    if (!mounted) return;
    setState(() {
      _selectedLanguage = language;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ProfileTypography(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FD),
        body: Column(
          children: [
            AlwanPageHeader(
              title: 'اللغة / Language',
              subtitle: 'تجربة عالمية تبدأ بلغتك',
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ResponsiveContent(
                        maxWidth: 760,
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            const _LanguageAdBanner(),
                            Padding(
                              padding: context.responsive.pagePadding,
                              child: Column(
                                children: [
                                  const SizedBox(height: 22),
                                  const _LanguageIntro(),
                                  const SizedBox(height: 14),
                                  const _GlobalLanguageVisual(),
                                  const SizedBox(height: 16),
                                  for (
                                    var index = 0;
                                    index < _languages.length;
                                    index++
                                  ) ...[
                                    _LanguageCard(
                                      option: _languages[index],
                                      selected:
                                          _selectedLanguage ==
                                          _languages[index].value,
                                      onTap: () =>
                                          _chooseLanguage(_languages[index]),
                                    ),
                                    if (index != _languages.length - 1)
                                      const SizedBox(height: 10),
                                  ],
                                  const SizedBox(height: 12),
                                  const _LanguagePrivacyNote(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            if (!_loading)
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 728),
                  child: _ConfirmLanguageButton(
                    saving: _saving,
                    onPressed: _saveLanguage,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _chooseLanguage(_LanguageOption option) {
    setState(() => _selectedLanguage = option.value);
  }

  Future<void> _saveLanguage() async {
    setState(() => _saving = true);
    await _repository.saveLanguage(_selectedLanguage);
    await AppLocaleController.instance.setLanguage(_selectedLanguage);
    if (!mounted) return;
    setState(() => _saving = false);

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop(_selectedLanguage);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم اعتماد اللغة $_selectedLanguage')),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.value,
    required this.nativeName,
    required this.internationalName,
    required this.flag,
    required this.greeting,
    required this.available,
  });

  final String value;
  final String nativeName;
  final String internationalName;
  final String flag;
  final String greeting;
  final bool available;
}

class _LanguageAdBanner extends StatelessWidget {
  const _LanguageAdBanner();

  @override
  Widget build(BuildContext context) {
    return const ProfileAdBanner(
      imageAsset: 'assets/images/banners/banner3.jpg',
      headline: 'عروض مختارة لجمهور ألوان حول العالم',
    );
  }
}

class _LanguageIntro extends StatelessWidget {
  const _LanguageIntro();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'اختر لغة التطبيق',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF222B65),
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 2),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            'Choose your preferred app language',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'MohammadBoldArt',
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _GlobalLanguageVisual extends StatelessWidget {
  const _GlobalLanguageVisual();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'خريطة العالم واللغات المتنوعة',
      child: Container(
        width: double.infinity,
        height: 142,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFF2EEFF), Color(0xFFEAF5FF)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD9D7F2)),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: _WorldMapPainter()),
            ),
            Center(
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF343B91), Color(0xFF9D24B2)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x385D2B91),
                      blurRadius: 16,
                      offset: Offset(0, 7),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ),
            const Positioned(
              top: 15,
              right: 34,
              child: _LanguageBubble(label: 'ع', color: Color(0xFF31398E)),
            ),
            const Positioned(
              top: 19,
              left: 38,
              child: _LanguageBubble(label: 'EN', color: Color(0xFF932EAA)),
            ),
            const Positioned(
              bottom: 15,
              right: 75,
              child: _LanguageBubble(label: 'हिं', color: Color(0xFF1478A4)),
            ),
            const Positioned(
              bottom: 13,
              left: 69,
              child: _LanguageBubble(label: 'FR', color: Color(0xFF6745B5)),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageBubble extends StatelessWidget {
  const _LanguageBubble({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 35, minHeight: 35),
      padding: const EdgeInsets.all(7),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: .22)),
        boxShadow: const [BoxShadow(color: Color(0x171E2A52), blurRadius: 8)],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontFamily: 'MohammadBoldArt',
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _WorldMapPainter extends CustomPainter {
  const _WorldMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7776B8).withValues(alpha: .12)
      ..style = PaintingStyle.fill;

    Path scaledPath(List<Offset> points) {
      final path = Path()
        ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx * size.width, point.dy * size.height);
      }
      return path..close();
    }

    final continents = <List<Offset>>[
      const [
        Offset(.06, .25),
        Offset(.13, .11),
        Offset(.23, .16),
        Offset(.27, .29),
        Offset(.21, .41),
        Offset(.17, .55),
        Offset(.10, .48),
      ],
      const [
        Offset(.22, .53),
        Offset(.29, .58),
        Offset(.31, .72),
        Offset(.27, .91),
        Offset(.22, .75),
        Offset(.19, .63),
      ],
      const [
        Offset(.42, .25),
        Offset(.50, .17),
        Offset(.57, .25),
        Offset(.55, .38),
        Offset(.48, .41),
        Offset(.43, .35),
      ],
      const [
        Offset(.47, .40),
        Offset(.57, .40),
        Offset(.62, .55),
        Offset(.56, .79),
        Offset(.48, .68),
        Offset(.44, .50),
      ],
      const [
        Offset(.56, .19),
        Offset(.74, .14),
        Offset(.91, .27),
        Offset(.86, .47),
        Offset(.71, .53),
        Offset(.61, .40),
      ],
      const [
        Offset(.78, .69),
        Offset(.89, .65),
        Offset(.94, .76),
        Offset(.87, .88),
        Offset(.77, .82),
      ],
    ];

    for (final continent in continents) {
      canvas.drawPath(scaledPath(continent), paint);
    }

    final dotPaint = Paint()
      ..color = const Color(0xFF4E62A6).withValues(alpha: .15);
    for (var index = 0; index < 13; index++) {
      final x = (.06 + index * .073) * size.width;
      final y = (.18 + (index % 3) * .31) * size.height;
      canvas.drawCircle(Offset(x, y), 1.8, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _LanguageOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? const Color(0xFF7A2EA2)
        : const Color(0xFFDCE1EB);

    return Opacity(
      opacity: option.available ? 1 : .76,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            constraints: const BoxConstraints(minHeight: 92),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF9F4FF) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: selected ? 2.2 : 1),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? const Color(0xFF5F2B91).withValues(alpha: .17)
                      : const Color(0xFF172B4D).withValues(alpha: .05),
                  blurRadius: selected ? 15 : 8,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4FA),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    option.flag,
                    style: const TextStyle(
                      fontFamily: 'MohammadBoldArt',
                      fontSize: 31,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              option.nativeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: selected
                                    ? const Color(0xFF29266D)
                                    : const Color(0xFF303758),
                                fontFamily: option.value == 'English'
                                    ? 'MohammadBoldArt'
                                    : null,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (!option.available) ...[
                            const SizedBox(width: 7),
                            const _ComingSoonBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${option.internationalName} • ${option.greeting}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: option.value == 'English'
                              ? 'MohammadBoldArt'
                              : null,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _LanguageSelectionMark(
                  selected: selected,
                  available: option.available,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComingSoonBadge extends StatelessWidget {
  const _ComingSoonBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3DB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'قريبًا',
        style: TextStyle(
          color: Color(0xFFA16500),
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LanguageSelectionMark extends StatelessWidget {
  const _LanguageSelectionMark({
    required this.selected,
    required this.available,
  });

  final bool selected;
  final bool available;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF7334A4) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFF7334A4) : const Color(0xFFCBD3E0),
          width: 1.6,
        ),
      ),
      child: Icon(
        selected
            ? Icons.check_rounded
            : available
            ? Icons.circle_outlined
            : Icons.schedule_rounded,
        color: selected ? Colors.white : const Color(0xFF9AA8BC),
        size: selected ? 20 : 16,
      ),
    );
  }
}

class _LanguagePrivacyNote extends StatelessWidget {
  const _LanguagePrivacyNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.translate_rounded, size: 16, color: Color(0xFF6D72A8)),
        SizedBox(width: 6),
        Flexible(
          child: Text(
            'يمكنك تغيير لغة التطبيق لاحقًا من الملف الشخصي',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ),
      ],
    );
  }
}

class _ConfirmLanguageButton extends StatelessWidget {
  const _ConfirmLanguageButton({required this.saving, required this.onPressed});

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
              : const Icon(Icons.language_rounded),
          label: Text(
            saving ? 'جارٍ الحفظ...' : 'تأكيد اللغة والرجوع',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}
