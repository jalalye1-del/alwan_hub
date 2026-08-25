import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:alwan_hub/features/podcasts/domain/entities/podcast_episode.dart';

class PodcastFeaturedHeroCard extends StatelessWidget {
  const PodcastFeaturedHeroCard({
    super.key,
    required this.episode,
    required this.isFavorite,
    required this.isSaved,
    required this.isPlaying,
    required this.onTap,
    required this.onVideoPressed,
    required this.onAudioPressed,
    required this.onFavoritePressed,
    required this.onLibraryPressed,
  });

  final PodcastEpisode episode;
  final bool isFavorite;
  final bool isSaved;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onVideoPressed;
  final VoidCallback onAudioPressed;
  final VoidCallback onFavoritePressed;
  final VoidCallback onLibraryPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: AspectRatio(
          aspectRatio: 2,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x332E347B),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        episode.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Color(0xFF2D246B),
                          child: Icon(
                            Icons.podcasts_rounded,
                            color: Colors.white54,
                            size: 58,
                          ),
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0x14000000), Color(0xE31A102B)],
                            stops: [0.15, 1],
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        top: 12,
                        start: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE93B75), Color(0xFFA429B1)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'أحدث حلقة • VIDEO + MP3',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'MohammadBoldArt',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        top: 10,
                        end: 10,
                        child: Row(
                          children: [
                            _HeroAction(
                              tooltip: 'إضافة إلى المفضلة',
                              icon: isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              active: isFavorite,
                              onTap: onFavoritePressed,
                            ),
                            const SizedBox(width: 6),
                            _HeroAction(
                              tooltip: 'تحميل إلى مكتبتي',
                              icon: isSaved
                                  ? Icons.library_add_check_rounded
                                  : Icons.download_rounded,
                              active: isSaved,
                              onTap: onLibraryPressed,
                            ),
                          ],
                        ),
                      ),
                      PositionedDirectional(
                        start: 16,
                        end: 16,
                        bottom: 14,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    episode.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'MohammadBoldArt',
                                      fontSize: 17,
                                      height: 1.25,
                                      fontWeight: FontWeight.w700,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black54,
                                          blurRadius: 7,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.mic_rounded,
                                        color: Colors.white70,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          '${episode.hostName} • ${episode.durationLabel}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontFamily: 'MohammadBoldArt',
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            InkWell(
                              onTap: onAudioPressed,
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: .42),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white38),
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.headphones_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            InkWell(
                              onTap: onVideoPressed,
                              customBorder: const CircleBorder(),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.ondemand_video_rounded,
                                  color: Color(0xFF7131A1),
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
          ),
        ),
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({
    required this.tooltip,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.translateInterface(tooltip),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFFE84273)
                : Colors.black.withValues(alpha: .38),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white38),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
