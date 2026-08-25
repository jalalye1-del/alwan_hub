import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/more/presentation/pages/about_app_screen.dart';
import 'package:alwan_hub/features/more/presentation/pages/about_us_screen.dart';
import 'package:alwan_hub/features/more/presentation/pages/app_updates_screen.dart';
import 'package:alwan_hub/features/more/presentation/pages/contact_us_screen.dart';
import 'package:alwan_hub/features/more/presentation/pages/news_screen.dart';
import 'package:alwan_hub/features/more/presentation/pages/team_screen.dart';
import 'package:alwan_hub/features/more/presentation/widgets/more_typography.dart';
import 'package:alwan_hub/features/profile/presentation/pages/app_rating_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/profile_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/share_app_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return MoreTypography(
      child: ColoredBox(
        color: const Color(0xFFF7F8FD),
        child: Column(
          children: [
            AlwanPageHeader(
              title: 'المزيد',
              subtitle: 'كل تفاصيل منصة ألوان في مكان واحد',
              onBack: onBack,
              trailing: IconButton.filledTonal(
                tooltip: context.translateInterface('الملف الشخصي'),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF30377C),
                  side: const BorderSide(color: Color(0xFFDDE2EB)),
                ),
                onPressed: () => _push(context, const ProfileScreen()),
                icon: const Icon(Icons.person_outline_rounded),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 28),
                child: ResponsiveContent(
                  maxWidth: 800,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const _MoreAdBanner(),
                      Padding(
                        padding: context.responsive.pagePadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 20),
                            const _MoreWelcome(),
                            const SizedBox(height: 16),
                            const _StatsCard(),
                            const SizedBox(height: 22),
                            const _SectionTitle(
                              icon: Icons.explore_rounded,
                              title: 'استكشف ألوان',
                            ),
                            const SizedBox(height: 10),
                            _FeatureGrid(
                              items: [
                                _MoreFeature(
                                  icon: Icons.newspaper_rounded,
                                  color: const Color(0xFFE94A68),
                                  title: 'الأخبار',
                                  subtitle:
                                      'رائجة وفنية وثقافية ورياضية وعالمية',
                                  onTap: () =>
                                      _push(context, const NewsScreen()),
                                ),
                                _MoreFeature(
                                  icon: Icons.groups_rounded,
                                  color: const Color(0xFF7A3DB2),
                                  title: 'فريق ألوان',
                                  subtitle: 'تعرف على صناع محتوى المنصة',
                                  onTap: () =>
                                      _push(context, const TeamScreen()),
                                ),
                                _MoreFeature(
                                  icon: Icons.auto_awesome_rounded,
                                  color: const Color(0xFF0A9E9A),
                                  title: 'من نحن',
                                  subtitle: 'رؤيتنا ورسالتنا وقيمنا',
                                  onTap: () =>
                                      _push(context, const AboutUsScreen()),
                                ),
                                _MoreFeature(
                                  icon: Icons.support_agent_rounded,
                                  color: const Color(0xFF2189C9),
                                  title: 'تواصل معنا',
                                  subtitle: 'نحن هنا للاستماع إليك',
                                  onTap: () =>
                                      _push(context, const ContactUsScreen()),
                                ),
                                _MoreFeature(
                                  icon: Icons.info_outline_rounded,
                                  color: const Color(0xFFF09A19),
                                  title: 'عن التطبيق',
                                  subtitle: 'المنصة والشركة المطورة',
                                  onTap: () =>
                                      _push(context, const AboutAppScreen()),
                                ),
                                _MoreFeature(
                                  icon: Icons.star_rounded,
                                  color: const Color(0xFFE0A000),
                                  title: 'تقييم التطبيق',
                                  subtitle: 'رأيك يساعدنا على التطور',
                                  onTap: () =>
                                      _push(context, const AppRatingScreen()),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            const _SectionTitle(
                              icon: Icons.favorite_rounded,
                              title: 'ابقَ قريبًا من ألوان',
                            ),
                            const SizedBox(height: 10),
                            _WideActionTile(
                              icon: Icons.ios_share_rounded,
                              title: 'مشاركة التطبيق',
                              subtitle: 'انشر صوت الفن اليمني مع أصدقائك',
                              onTap: () =>
                                  _push(context, const ShareAppScreen()),
                            ),
                            const SizedBox(height: 8),
                            _WideActionTile(
                              icon: Icons.system_update_alt_rounded,
                              title: 'آخر تحديثات التطبيق',
                              subtitle: 'اطلع على التحسينات والميزات الجديدة',
                              onTap: () =>
                                  _push(context, const AppUpdatesScreen()),
                            ),
                            const SizedBox(height: 20),
                            const _VersionFooter(),
                          ],
                        ),
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

  static void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}

class _MoreAdBanner extends StatelessWidget {
  const _MoreAdBanner();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 400,
        child: AspectRatio(
          aspectRatio: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/banners/banner3.jpg',
                  fit: BoxFit.cover,
                  semanticLabel: 'بنر إعلاني بمقاس 400 في 200',
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xB31B1027)],
                    ),
                  ),
                ),
                const Positioned(
                  top: 12,
                  right: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xEFFFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      child: Text(
                        'إعلان',
                        style: TextStyle(
                          color: Color(0xFF3C2473),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(
                  right: 16,
                  left: 16,
                  bottom: 14,
                  child: Text(
                    'اكتشف عروض شركاء منصة ألوان',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                    ),
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

class _MoreWelcome extends StatelessWidget {
  const _MoreWelcome();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اكتشف عالم ألوان',
                style: TextStyle(
                  color: Color(0xFF262D70),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'أخبارنا وفريقنا ورسالتنا وطرق التواصل معنا',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF343A8D), Color(0xFF9E25AE)],
            ),
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.apps_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFDDE3ED)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D13203B),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'مستمع شهريًا',
              value: '2.4M+',
              color: Color(0xFFE6356B),
            ),
          ),
          _StatsDivider(),
          Expanded(
            child: _StatItem(
              label: 'تردد ألوان',
              value: 'FM 88.7',
              color: Color(0xFF238DD1),
            ),
          ),
          _StatsDivider(),
          Expanded(
            child: _StatItem(
              label: 'منذ انطلاقنا',
              value: '2012',
              color: Color(0xFF8B28A9),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsDivider extends StatelessWidget {
  const _StatsDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 38,
      child: VerticalDivider(color: Color(0xFFE3E7EE)),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontFamily: 'MohammadBoldArt',
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF7536A2).withValues(alpha: .10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: const Color(0xFF7133A0), size: 19),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF282E70),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.items});

  final List<_MoreFeature> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.52,
      ),
      itemBuilder: (context, index) => _FeatureCard(item: items[index]),
    );
  }
}

class _MoreFeature {
  const _MoreFeature({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.item});

  final _MoreFeature item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDDE3EC)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D14213A),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2B3267),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WideActionTile extends StatelessWidget {
  const _WideActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
          side: const BorderSide(color: Color(0xFFDDE3EC)),
        ),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF343A8D), Color(0xFF9E25AE)],
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2B3267),
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
        ),
        trailing: Icon(
          Directionality.of(context) == TextDirection.rtl
              ? Icons.chevron_left_rounded
              : Icons.chevron_right_rounded,
          color: Color(0xFF6C7390),
        ),
      ),
    );
  }
}

class _VersionFooter extends StatelessWidget {
  const _VersionFooter();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.radio_rounded, color: Color(0xFF8B42AA), size: 24),
        SizedBox(height: 5),
        Text(
          'منصة ألوان FM • الإصدار 1.0.0',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF7E879B), fontSize: 10),
        ),
        Text(
          'مصممة لأندرويد وآيفون والويب',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFA0A8B7), fontSize: 9),
        ),
      ],
    );
  }
}
