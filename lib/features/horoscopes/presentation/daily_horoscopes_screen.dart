import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/core/widgets/adaptive_content_image.dart';
import 'package:alwan_hub/features/horoscopes/data/daily_horoscope_catalog.dart';
import 'package:alwan_hub/features/horoscopes/data/local_daily_horoscope_repository.dart';
import 'package:alwan_hub/features/horoscopes/domain/daily_horoscope.dart';
import 'package:alwan_hub/features/horoscopes/domain/horoscope_banner.dart';
import 'package:alwan_hub/features/horoscopes/presentation/providers/daily_horoscope_provider.dart';

class DailyHoroscopesScreen extends ConsumerWidget {
  const DailyHoroscopesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final horoscopes = ref.watch(dailyHoroscopesProvider).maybeWhen(
      data: (value) => value.isEmpty ? DailyHoroscopeCatalog.items : value,
      orElse: () => DailyHoroscopeCatalog.items,
    );
    final banner = ref.watch(horoscopeBannerProvider).maybeWhen(
      data: (value) => value ?? LocalDailyHoroscopeRepository.defaultBanner,
      orElse: () => LocalDailyHoroscopeRepository.defaultBanner,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FC),
      body: Column(
        children: [
          const AlwanPageHeader(
            title: 'الأبراج اليومية',
            subtitle: 'توقعات اليوم للأبراج الاثني عشر',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 32),
              child: ResponsiveContent(
                maxWidth: 1050,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HoroscopeHero(
                      banner: banner,
                      dateLabel: _arabicDate(now),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'اختر برجك',
                      style: TextStyle(
                        color: Color(0xFF292F70),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'اضغط على البرج لعرض توقعاته اليومية بالتفصيل',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final responsive = context.responsive;
                        final columns = responsive.columns(
                          compact: constraints.maxWidth < 350 ? 1 : 2,
                          medium: 3,
                          expanded: 4,
                          large: 4,
                        );
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: horoscopes.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: columns == 1
                                    ? 2.6
                                    : columns == 2
                                    ? 0.95
                                    : 1.08,
                              ),
                          itemBuilder: (context, index) {
                            final horoscope = horoscopes[index];
                            return _HoroscopeCard(
                              horoscope: horoscope,
                              onTap: () => _showHoroscopeDetails(
                                context,
                                horoscope,
                                _arabicDate(now),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    const _EntertainmentNotice(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _arabicDate(DateTime date) {
    const weekdays = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    const months = [
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
    return '${weekdays[date.weekday - 1]}، ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _HoroscopeHero extends StatelessWidget {
  const _HoroscopeHero({required this.banner, required this.dateLabel});

  final HoroscopeBanner banner;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SizedBox(
          key: const ValueKey('horoscope-banner-400x100'),
          width: double.infinity,
          height: 100,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  Color(0xFF242A76),
                  Color(0xFF6E42B6),
                  Color(0xFFB34AA7),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x353E257E),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (banner.imageSource?.trim().isNotEmpty == true)
                  AdaptiveContentImage(
                    key: const ValueKey('horoscope-dashboard-banner-image'),
                    source: banner.imageSource!,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.cover,
                    semanticLabel: banner.title,
                  ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.centerStart,
                      end: AlignmentDirectional.centerEnd,
                      colors: [
                        const Color(0xDD242A76),
                        const Color(0xB36E42B6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.nights_stay_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              banner.subtitle.isEmpty
                                  ? dateLabel
                                  : '${banner.subtitle} • $dateLabel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HoroscopeCard extends StatelessWidget {
  const _HoroscopeCard({required this.horoscope, required this.onTap});

  final DailyHoroscope horoscope;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        key: ValueKey('horoscope-${horoscope.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE1DDF0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F2B2259),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                horoscope.symbol,
                style: const TextStyle(
                  color: Color(0xFF6B41AD),
                  fontSize: 36,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'برج ${horoscope.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF292F70),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                horoscope.dateRange,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                horoscope.summary,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF5B6079),
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntertainmentNotice extends StatelessWidget {
  const _EntertainmentNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF0ECF9),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFDAD1ED)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF6D4BA1)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'محتوى الأبراج ترفيهي عام ولا يمثل نصيحة علمية أو قرارًا شخصيًا.',
              style: TextStyle(
                color: Color(0xFF5E5270),
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showHoroscopeDetails(
  BuildContext context,
  DailyHoroscope horoscope,
  String dateLabel,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _HoroscopeDetailsSheet(
      horoscope: horoscope,
      dateLabel: dateLabel,
    ),
  );
}

class _HoroscopeDetailsSheet extends StatelessWidget {
  const _HoroscopeDetailsSheet({
    required this.horoscope,
    required this.dateLabel,
  });

  final DailyHoroscope horoscope;
  final String dateLabel;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: .9,
      child: Material(
        color: const Color(0xFFF8F7FC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'برج ${horoscope.name}',
                          style: const TextStyle(
                            color: Color(0xFF292F70),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          dateLabel,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    horoscope.symbol,
                    style: const TextStyle(
                      color: Color(0xFF7045AE),
                      fontSize: 42,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SummaryCard(horoscope: horoscope),
                      const SizedBox(height: 14),
                      _DetailCard(
                        icon: Icons.favorite_rounded,
                        title: 'الحب والعلاقات',
                        content: horoscope.love,
                        color: const Color(0xFFE84C82),
                      ),
                      const SizedBox(height: 10),
                      _DetailCard(
                        icon: Icons.work_rounded,
                        title: 'العمل والمال',
                        content: horoscope.work,
                        color: const Color(0xFF4169B1),
                      ),
                      const SizedBox(height: 10),
                      _DetailCard(
                        icon: Icons.spa_rounded,
                        title: 'الصحة والطاقة',
                        content: horoscope.health,
                        color: const Color(0xFF2B9A74),
                      ),
                      const SizedBox(height: 10),
                      _DetailCard(
                        icon: Icons.lightbulb_rounded,
                        title: 'نصيحة اليوم',
                        content: horoscope.advice,
                        color: const Color(0xFFE3932C),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _LuckyCard(
                              label: 'رقم الحظ',
                              value: '${horoscope.luckyNumber}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _LuckyCard(
                              label: 'لون الحظ',
                              value: horoscope.luckyColor,
                            ),
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
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.horoscope});

  final DailyHoroscope horoscope;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF332F7A), Color(0xFF8050B5)],
        ),
        borderRadius: BorderRadius.circular(23),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoPill(label: 'العنصر', value: horoscope.element),
              _InfoPill(label: 'المزاج', value: horoscope.mood),
              _InfoPill(label: 'الفترة', value: horoscope.dateRange),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            horoscope.summary,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.6,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String content;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE3DFEA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF30345F),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  content,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LuckyCard extends StatelessWidget {
  const _LuckyCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF0ECF9),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF5F3797),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
