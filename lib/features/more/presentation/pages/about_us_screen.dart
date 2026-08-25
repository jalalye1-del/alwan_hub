import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/more/presentation/widgets/more_typography.dart';
import 'package:alwan_hub/features/notifications/presentation/pages/notifications_screen.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoreTypography(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FD),
        body: Column(
          children: [
            AlwanPageHeader(
              title: 'من نحن',
              subtitle: 'تعرف على إذاعة ألوان ورؤيتنا ورسالتنا',
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 30),
                child: ResponsiveContent(
                  maxWidth: 820,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AboutAlwanCard(),
                      SizedBox(height: 16),
                      _AboutStats(),
                      SizedBox(height: 17),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _StatementCard(
                              icon: Icons.flag_rounded,
                              title: 'رسالتنا',
                              body:
                                  'تقديم محتوى ملهم، يرتقي بالذوق العام ويلهم الشباب ويواكب طموحاتهم.',
                              color: Color(0xFF8A2DA8),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _StatementCard(
                              icon: Icons.visibility_rounded,
                              title: 'رؤيتنا',
                              body:
                                  'أن نكون المنصة الأولى للشباب في الإعلام اليمني والعربي.',
                              color: Color(0xFF258FCF),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 22),
                      _ValuesTitle(),
                      SizedBox(height: 10),
                      _ValuesGrid(),
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

class _AboutAlwanCard extends StatelessWidget {
  const _AboutAlwanCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFD9E0EA)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11121C31),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF343A8D), Color(0xFF9E25AE)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.radio_rounded, color: Colors.white),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'عن ألوان',
                style: TextStyle(
                  color: Color(0xFF292F70),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const Text(
            'ألوان FM 88.7 هي إذاعة شبابية ومنصة رقمية تقدم محتوى عصريًا يجمع بين الترفيه الهادف والموسيقى والإبداع، لتكون صوت الجيل الملهم في اليمن والمنطقة.',
            style: TextStyle(
              color: Color(0xFF4E566D),
              fontSize: 14,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF4EFFB),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Text(
              'نبتكر برامج ومحتوى ومجتمعًا يعكس شغف الشباب ويعبّر عنهم.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF643990),
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutStats extends StatelessWidget {
  const _AboutStats();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _AboutStat(
            value: 'منذ 2012',
            label: 'منذ انطلاقنا',
            color: Color(0xFF8B2BA8),
          ),
        ),
        SizedBox(width: 9),
        Expanded(
          child: _AboutStat(
            value: 'FM 88.7',
            label: 'التردد',
            color: Color(0xFF258FD0),
          ),
        ),
        SizedBox(width: 9),
        Expanded(
          child: _AboutStat(
            value: '2.4M+',
            label: 'مستمع شهريًا',
            color: Color(0xFFE73469),
          ),
        ),
      ],
    );
  }
}

class _AboutStat extends StatelessWidget {
  const _AboutStat({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 103,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E4EB)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontFamily: 'MohammadBoldArt',
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _StatementCard extends StatelessWidget {
  const _StatementCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E4EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .11),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF292F70),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValuesTitle extends StatelessWidget {
  const _ValuesTitle();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.diamond_rounded, color: Color(0xFF8331A6), size: 22),
        SizedBox(width: 8),
        Text(
          'قيمنا',
          style: TextStyle(
            color: Color(0xFF292F70),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ValuesGrid extends StatelessWidget {
  const _ValuesGrid();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ValueCard(
                icon: Icons.workspace_premium_rounded,
                title: 'الجودة',
                body: 'نسعى لتقديم الأفضل في كل ما نقدمه.',
                color: Color(0xFFF0A018),
              ),
            ),
            SizedBox(width: 9),
            Expanded(
              child: _ValueCard(
                icon: Icons.diversity_3_rounded,
                title: 'المجتمع',
                body: 'نصغي لجمهورنا ونبني مجتمعًا متصلًا.',
                color: Color(0xFF42A85A),
              ),
            ),
          ],
        ),
        SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: _ValueCard(
                icon: Icons.lightbulb_rounded,
                title: 'الإبداع',
                body: 'نبتكر لنقدم محتوى مختلفًا وملهمًا.',
                color: Color(0xFF2997D8),
              ),
            ),
            SizedBox(width: 9),
            Expanded(
              child: _ValueCard(
                icon: Icons.favorite_rounded,
                title: 'المصداقية',
                body: 'نلتزم بالمهنية والوضوح والثقة.',
                color: Color(0xFFE33769),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ValueCard extends StatelessWidget {
  const _ValueCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 137),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0E4EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 7),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
