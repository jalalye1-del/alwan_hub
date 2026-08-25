import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:alwan_hub/features/profile/presentation/widgets/profile_typography.dart';
import 'package:alwan_hub/features/profile/presentation/widgets/profile_ad_banner.dart';

class ShareAppScreen extends StatefulWidget {
  const ShareAppScreen({super.key});

  @override
  State<ShareAppScreen> createState() => _ShareAppScreenState();
}

class _ShareAppScreenState extends State<ShareAppScreen> {
  static const _appLink =
      'https://play.google.com/store/apps/details?id=fm.alwan.alwan_hub';
  static const _shareText =
      'حمّل تطبيق منصة ألوان واستمتع بالبث والبرامج والمسابقات والفن اليمني الأصيل.';

  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ProfileTypography(
      child: Scaffold(
        backgroundColor: dark
            ? const Color(0xFF091A34)
            : const Color(0xFFF7F8FD),
        body: Column(
          children: [
            AlwanPageHeader(
              title: 'مشاركة التطبيق',
              subtitle: 'شارك ألوان راديو مع من تحب',
              dark: dark,
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 28),
                child: ResponsiveContent(
                  maxWidth: 760,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const _ShareAdBanner(),
                      Padding(
                        padding: context.responsive.pagePadding,
                        child: Column(
                          children: [
                            const SizedBox(height: 18),
                            _ShareHero(dark: dark),
                            const SizedBox(height: 16),
                            _CopyLinkButton(
                              copied: _copied,
                              onPressed: _copyAppLink,
                            ),
                            const SizedBox(height: 12),
                            _AppLinkPreview(dark: dark),
                            const SizedBox(height: 22),
                            _ShareSectionTitle(dark: dark),
                            const SizedBox(height: 11),
                            _SocialShareGrid(
                              dark: dark,
                              onWhatsApp: () => _shareTo(
                                Uri.https('wa.me', '/', {
                                  'text': '$_shareText\n$_appLink',
                                }),
                              ),
                              onTelegram: () => _shareTo(
                                Uri.https('t.me', '/share/url', {
                                  'url': _appLink,
                                  'text': _shareText,
                                }),
                              ),
                              onX: () => _shareTo(
                                Uri.https('twitter.com', '/intent/tweet', {
                                  'text': _shareText,
                                  'url': _appLink,
                                }),
                              ),
                              onInstagram: () => _shareThroughSheet(
                                suggestedPlatform: 'إنستغرام',
                              ),
                            ),
                            const SizedBox(height: 18),
                            _MoreShareButton(
                              dark: dark,
                              onPressed: _shareThroughSheet,
                            ),
                            const SizedBox(height: 14),
                            _ShareImpactNote(dark: dark),
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

  Future<void> _copyAppLink() async {
    await Clipboard.setData(const ClipboardData(text: _appLink));
    await HapticFeedback.selectionClick();
    if (!mounted) return;
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ رابط التطبيق إلى الحافظة')),
    );
  }

  Future<void> _shareTo(Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) await _shareThroughSheet();
  }

  Future<void> _shareThroughSheet({String? suggestedPlatform}) async {
    if (suggestedPlatform != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('اختر $suggestedPlatform من قائمة المشاركة')),
      );
    }
    await SharePlus.instance.share(
      ShareParams(subject: 'تطبيق منصة ألوان', text: '$_shareText\n$_appLink'),
    );
  }
}

class _ShareAdBanner extends StatelessWidget {
  const _ShareAdBanner();

  @override
  Widget build(BuildContext context) {
    return const ProfileAdBanner(
      imageAsset: 'assets/images/banners/banner2.jpg',
      headline: 'عروض مختارة من شركاء منصة ألوان',
    );
  }
}

class _ShareHero extends StatelessWidget {
  const _ShareHero({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'شارك ألوان وانشر الفرح',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? Colors.white : const Color(0xFF242B6D),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'دع أصدقاءك يكتشفون صوت اليمن ومحتواه الجميل',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: dark ? Colors.white60 : AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 230,
          height: 146,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: dark
                      ? const Color(0xFF112A4E)
                      : const Color(0xFFF0EFF8),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 116,
                height: 116,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFFB15CC5), Color(0xFF25398A)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3A4B2A8C),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: Colors.white,
                  size: 65,
                ),
              ),
              const Positioned(
                top: 2,
                right: 32,
                child: _ReactionBubble(
                  emoji: '❤️',
                  background: Color(0xFFFFE0E7),
                ),
              ),
              const Positioned(
                top: 22,
                left: 21,
                child: _ReactionBubble(
                  emoji: '✨',
                  background: Color(0xFFF4E7FF),
                ),
              ),
              const Positioned(
                bottom: 7,
                right: 26,
                child: _ReactionBubble(
                  emoji: '👍',
                  background: Color(0xFFE2F5FF),
                ),
              ),
              const Positioned(
                bottom: 0,
                left: 43,
                child: _ReactionBubble(
                  emoji: '🎧',
                  background: Color(0xFFE5FBE8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReactionBubble extends StatelessWidget {
  const _ReactionBubble({required this.emoji, required this.background});

  final String emoji;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x1F111827), blurRadius: 8)],
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }
}

class _CopyLinkButton extends StatelessWidget {
  const _CopyLinkButton({required this.copied, required this.onPressed});

  final bool copied;
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
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: Icon(copied ? Icons.check_rounded : Icons.link_rounded),
          label: Text(
            copied ? 'تم نسخ رابط التطبيق' : 'نسخ رابط التطبيق',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

class _AppLinkPreview extends StatelessWidget {
  const _AppLinkPreview({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF10294D) : const Color(0xFFF0F4FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: dark ? const Color(0xFF29476D) : const Color(0xFFD9E1EB),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.public_rounded,
              color: Color(0xFF7150A8),
              size: 19,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _ShareAppScreenState._appLink,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: dark ? Colors.white70 : const Color(0xFF56627A),
                  fontFamily: 'MohammadBoldArt',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(
              Icons.verified_rounded,
              color: Color(0xFF2E9F69),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareSectionTitle extends StatelessWidget {
  const _ShareSectionTitle({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'مشاركة عبر',
            style: TextStyle(
              color: dark ? Colors.white : const Color(0xFF292F70),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Text(
          'اختر المنصة المناسبة',
          style: TextStyle(
            color: dark ? Colors.white54 : AppColors.textSecondary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _SocialShareGrid extends StatelessWidget {
  const _SocialShareGrid({
    required this.dark,
    required this.onWhatsApp,
    required this.onTelegram,
    required this.onX,
    required this.onInstagram,
  });

  final bool dark;
  final VoidCallback onWhatsApp;
  final VoidCallback onTelegram;
  final VoidCallback onX;
  final VoidCallback onInstagram;

  @override
  Widget build(BuildContext context) {
    final items = <_SocialShareItem>[
      _SocialShareItem(
        label: 'واتساب',
        icon: Icons.call_rounded,
        foreground: const Color(0xFF208C3D),
        background: const Color(0xFFDDF8D7),
        onTap: onWhatsApp,
      ),
      _SocialShareItem(
        label: 'تيليجرام',
        icon: Icons.send_rounded,
        foreground: const Color(0xFF1889BA),
        background: const Color(0xFFDDF3FD),
        onTap: onTelegram,
      ),
      _SocialShareItem(
        label: 'X',
        icon: Icons.close_rounded,
        foreground: const Color(0xFF111827),
        background: const Color(0xFFE8EDF3),
        onTap: onX,
      ),
      _SocialShareItem(
        label: 'إنستغرام',
        icon: Icons.favorite_rounded,
        foreground: const Color(0xFFD82F7C),
        background: const Color(0xFFFFE3F0),
        onTap: onInstagram,
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          Expanded(
            child: _SocialShareCard(item: items[index], dark: dark),
          ),
          if (index != items.length - 1) const SizedBox(width: 7),
        ],
      ],
    );
  }
}

class _SocialShareItem {
  const _SocialShareItem({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
  final VoidCallback onTap;
}

class _SocialShareCard extends StatelessWidget {
  const _SocialShareCard({required this.item, required this.dark});

  final _SocialShareItem item;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          height: 94,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF10294D) : Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: dark ? const Color(0xFF29476D) : const Color(0xFFD9E0E9),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: item.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.foreground, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: dark ? Colors.white70 : const Color(0xFF30395F),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoreShareButton extends StatelessWidget {
  const _MoreShareButton({required this.dark, required this.onPressed});

  final bool dark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: dark ? Colors.white : const Color(0xFF4B3C8F),
          side: BorderSide(
            color: dark ? const Color(0xFF36557A) : const Color(0xFFCFCDE4),
          ),
          backgroundColor: dark ? const Color(0xFF10294D) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: const Icon(Icons.ios_share_rounded, size: 19),
        label: const Text(
          'خيارات مشاركة أخرى',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _ShareImpactNote extends StatelessWidget {
  const _ShareImpactNote({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('💜', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'كل مشاركة تساعد صوت الفن اليمني على الوصول أبعد',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dark ? Colors.white54 : AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}
