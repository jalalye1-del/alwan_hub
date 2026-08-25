import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/more/presentation/widgets/more_typography.dart';

class AppUpdatesScreen extends StatelessWidget {
  const AppUpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoreTypography(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FD),
        body: Column(
          children: [
            const AlwanPageHeader(
              title: 'آخر تحديثات التطبيق',
              subtitle: 'التحسينات والميزات الجديدة في ألوان',
              trailing: SizedBox(width: 48, height: 48),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 30),
                child: ResponsiveContent(
                  maxWidth: 760,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CurrentVersionCard(),
                      SizedBox(height: 22),
                      _SectionHeading(
                        icon: Icons.auto_awesome_rounded,
                        title: 'ما الجديد؟',
                      ),
                      SizedBox(height: 10),
                      _UpdateItem(
                        icon: Icons.dashboard_customize_rounded,
                        color: Color(0xFF8E2BAB),
                        title: 'واجهات أكثر وضوحًا',
                        description:
                            'تحديث الملف الشخصي وقسم المزيد وتوحيد الألوان والخطوط لتجربة أسهل.',
                      ),
                      SizedBox(height: 10),
                      _UpdateItem(
                        icon: Icons.explore_rounded,
                        color: Color(0xFF238FCF),
                        title: 'مواقيت الصلاة والقبلة',
                        description:
                            'منبه مخصص للصلوات الخمس مع واجهة احترافية لتحديد اتجاه القبلة.',
                      ),
                      SizedBox(height: 10),
                      _UpdateItem(
                        icon: Icons.tune_rounded,
                        color: Color(0xFF0A9E9A),
                        title: 'خيارات استماع وشكل أفضل',
                        description:
                            'تحسين جودة البث واللغة والمظهر لتناسب سرعة الشبكة وتفضيلاتك.',
                      ),
                      SizedBox(height: 10),
                      _UpdateItem(
                        icon: Icons.favorite_rounded,
                        color: Color(0xFFE94A68),
                        title: 'التقييم ومشاركة التطبيق',
                        description:
                            'واجهات جديدة لتقييم تجربتك ومشاركة تطبيق ألوان مع أصدقائك بسهولة.',
                      ),
                      SizedBox(height: 22),
                      _ComingSoonCard(),
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

class _CurrentVersionCard extends StatelessWidget {
  const _CurrentVersionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF30377C), Color(0xFF9B26B0)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332E347B),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0x24FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 54,
                  height: 54,
                  child: Icon(
                    Icons.system_update_alt_rounded,
                    color: Colors.white,
                    size: 29,
                  ),
                ),
              ),
              SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الإصدار الحالي 1.0.0',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '6 أغسطس 2026',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF7FF0C6)),
                SizedBox(width: 7),
                Text(
                  'أنت تستخدم أحدث إصدار',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF8E2BAB), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF292F70),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _UpdateItem extends StatelessWidget {
  const _UpdateItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE2EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF292F70),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF687189),
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

class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDFA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE1D3F0)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            icon: Icons.rocket_launch_rounded,
            title: 'قادم قريبًا',
          ),
          SizedBox(height: 10),
          Text(
            '• دعم أوسع للغة الإنجليزية\n• تنزيل المحتوى للاستماع دون اتصال\n• اقتراحات مخصصة حسب اهتماماتك',
            style: TextStyle(
              color: Color(0xFF5E4B74),
              fontSize: 12,
              height: 1.9,
            ),
          ),
        ],
      ),
    );
  }
}
