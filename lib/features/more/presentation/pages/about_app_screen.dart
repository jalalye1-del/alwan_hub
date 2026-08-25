import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/more/presentation/pages/contact_us_screen.dart';
import 'package:alwan_hub/features/more/presentation/widgets/more_typography.dart';
import 'package:alwan_hub/features/notifications/presentation/pages/notifications_screen.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MoreTypography(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FD),
        body: Column(
          children: [
            AlwanPageHeader(
              title: 'منصة ألوان',
              subtitle: 'تعرف على التطبيق والشركة المطورة للمنصة',
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _DeveloperCard(),
                      const SizedBox(height: 14),
                      const _PlatformStrip(),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: ContactMethodCard(
                              icon: Icons.call_rounded,
                              title: 'اتصل بنا',
                              value: '+966 11 234 5678',
                              color: const Color(0xFF5A4A9C),
                              onTap: () => launchUrl(
                                Uri.parse('tel:+966112345678'),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ContactMethodCard(
                              icon: Icons.chat_rounded,
                              title: 'واتساب',
                              value: '+966 55 123 4567',
                              color: const Color(0xFF40A95A),
                              onTap: () => launchUrl(
                                Uri.parse('https://wa.me/966551234567'),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ContactMethodCard(
                              icon: Icons.email_outlined,
                              title: 'البريد الإلكتروني',
                              value: 'support@alwanfm.sa',
                              color: const Color(0xFF298FCE),
                              onTap: () => launchUrl(
                                Uri.parse('mailto:support@alwanfm.sa'),
                                mode: LaunchMode.externalApplication,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const ContactMessageForm(title: 'راسل فريق المنصة'),
                      const SizedBox(height: 15),
                      const _AppLegalNote(),
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

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard();

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
            color: Color(0x11131C30),
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
                  width: 48,
                  height: 48,
                  child: Icon(Icons.code_rounded, color: Colors.white),
                ),
              ),
              SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الشركة المطورة',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      'شركة تطوير المنصات الرقمية',
                      style: TextStyle(
                        color: Color(0xFF292F70),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 13),
          Text(
            'نحن الفريق التقني المسؤول عن تطوير تطبيق ومنصة ألوان لإذاعة ألوان FM 88.7. نعمل بشغف لتقديم تجربة رقمية متكاملة وفعّالة تدعم رسالتكم وتواكب تطلعات مستمعيكم.',
            style: TextStyle(
              color: Color(0xFF4E566D),
              fontSize: 13,
              height: 1.75,
            ),
          ),
          SizedBox(height: 13),
          _VersionPill(),
        ],
      ),
    );
  }
}

class _VersionPill extends StatelessWidget {
  const _VersionPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EDFA),
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: Color(0xFF7636A0), size: 17),
          SizedBox(width: 6),
          Text(
            'منصة ألوان • الإصدار 1.0.0',
            style: TextStyle(
              color: Color(0xFF61378D),
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformStrip extends StatelessWidget {
  const _PlatformStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0ECFA), Color(0xFFEAF5FF)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDADBEA)),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _PlatformItem(
              icon: Icons.android_rounded,
              label: 'Android',
              color: Color(0xFF45A659),
            ),
          ),
          Expanded(
            child: _PlatformItem(
              icon: Icons.phone_iphone_rounded,
              label: 'iPhone',
              color: Color(0xFF323A67),
            ),
          ),
          Expanded(
            child: _PlatformItem(
              icon: Icons.language_rounded,
              label: 'Web',
              color: Color(0xFF298FCE),
            ),
          ),
          Expanded(
            child: _PlatformItem(
              icon: Icons.headphones_rounded,
              label: 'Audio',
              color: Color(0xFF8B2CA8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformItem extends StatelessWidget {
  const _PlatformItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontFamily: 'MohammadBoldArt',
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _AppLegalNote extends StatelessWidget {
  const _AppLegalNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.copyright_rounded, color: Color(0xFF7F8798), size: 15),
        SizedBox(width: 5),
        Flexible(
          child: Text(
            'جميع الحقوق محفوظة لمنصة ألوان 2026',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 9),
          ),
        ),
      ],
    );
  }
}
