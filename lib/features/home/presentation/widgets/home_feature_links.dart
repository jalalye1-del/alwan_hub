import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:alwan_hub/core/widgets/adaptive_content_image.dart';
import 'package:alwan_hub/features/home/data/local_home_feature_link_repository.dart';
import 'package:alwan_hub/features/home/domain/home_feature_link.dart';
import 'package:alwan_hub/features/home/presentation/providers/home_feature_link_provider.dart';

class HomeFeatureLinks extends ConsumerWidget {
  const HomeFeatureLinks({
    super.key,
    required this.onTrendingNewsTap,
    required this.onDailyHoroscopesTap,
  });

  final VoidCallback onTrendingNewsTap;
  final VoidCallback onDailyHoroscopesTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(homeFeatureLinksProvider).maybeWhen(
      data: (value) => value,
      orElse: () => LocalHomeFeatureLinkRepository.defaults,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < links.length; index++) ...[
          _FeatureLinkCard(
            key: ValueKey('${links[index].id}-card'),
            link: links[index],
            icon: _iconFor(links[index].id),
            colors: _colorsFor(links[index].id),
            glowColor: _glowFor(links[index].id),
            onTap: _onTapFor(links[index].id),
          ),
          if (index != links.length - 1) const SizedBox(height: 14),
        ],
      ],
    );
  }

  VoidCallback _onTapFor(String id) =>
      id == HomeFeatureLink.dailyHoroscopesId
      ? onDailyHoroscopesTap
      : onTrendingNewsTap;

  IconData _iconFor(String id) => id == HomeFeatureLink.dailyHoroscopesId
      ? Icons.auto_awesome_rounded
      : Icons.trending_up_rounded;

  List<Color> _colorsFor(String id) =>
      id == HomeFeatureLink.dailyHoroscopesId
      ? const [Color(0xFF273B8F), Color(0xFF6D54CE)]
      : const [Color(0xFF7C2D92), Color(0xFFB24BC0)];

  Color _glowFor(String id) => id == HomeFeatureLink.dailyHoroscopesId
      ? const Color(0xFF493CA5)
      : const Color(0xFF8B2FA2);
}

class _FeatureLinkCard extends StatelessWidget {
  const _FeatureLinkCard({
    super.key,
    required this.link,
    required this.icon,
    required this.colors,
    required this.glowColor,
    required this.onTap,
  });

  final HomeFeatureLink link;
  final IconData icon;
  final List<Color> colors;
  final Color glowColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: .2),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: colors,
            ),
          ),
          child: InkWell(
            onTap: onTap,
            child: Stack(
              children: [
                PositionedDirectional(
                  end: -24,
                  top: -42,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: .08),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child: link.imageSource?.trim().isNotEmpty == true
                              ? AdaptiveContentImage(
                                  key: ValueKey('${link.id}-dashboard-image'),
                                  source: link.imageSource!,
                                  width: 58,
                                  height: 58,
                                  fit: BoxFit.cover,
                                  semanticLabel: link.title,
                                )
                              : Icon(icon, color: Colors.white, size: 31),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              link.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              link.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Semantics(
                        label: link.actionLabel,
                        button: true,
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: colors.first,
                            size: 22,
                          ),
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
