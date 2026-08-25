import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:alwan_hub/features/podcasts/domain/entities/podcast_episode.dart';

class PodcastEpisodeCard extends StatelessWidget {
  const PodcastEpisodeCard({
    super.key,
    required this.episode,
    required this.accentColor,
    required this.isFavorite,
    required this.isSaved,
    required this.isPlaying,
    required this.onTap,
    required this.onVideoTap,
    required this.onPlayTap,
    required this.onFavoriteTap,
    required this.onLibraryTap,
  });

  final PodcastEpisode episode;
  final Color accentColor;
  final bool isFavorite;
  final bool isSaved;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onVideoTap;
  final VoidCallback onPlayTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback onLibraryTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 226,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE0E4EC)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: .12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 88,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        episode.imageAsset,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              accentColor.withValues(alpha: .78),
                            ],
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        start: 7,
                        bottom: 7,
                        child: _MetaPill(
                          icon: Icons.schedule_rounded,
                          label: episode.durationLabel,
                        ),
                      ),
                      const PositionedDirectional(
                        start: 7,
                        top: 7,
                        child: _MediaBadge(),
                      ),
                      PositionedDirectional(
                        end: 7,
                        bottom: 6,
                        child: InkWell(
                          onTap: onVideoTap,
                          customBorder: const CircleBorder(),
                          child: DecoratedBox(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: SizedBox(
                              width: 27,
                              height: 27,
                              child: Icon(
                                Icons.ondemand_video_rounded,
                                color: accentColor,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          episode.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF292F70),
                            fontFamily: 'MohammadBoldArt',
                            fontSize: 11,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          episode.seriesName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF7B8498),
                            fontFamily: 'MohammadBoldArt',
                            fontSize: 8.5,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _CardAction(
                              tooltip: 'الاستماع MP3',
                              icon: isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.headphones_rounded,
                              color: accentColor,
                              active: isPlaying,
                              onTap: onPlayTap,
                            ),
                            _CardAction(
                              tooltip: 'إضافة إلى المفضلة',
                              icon: isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: const Color(0xFFE5446D),
                              active: isFavorite,
                              onTap: onFavoriteTap,
                            ),
                            _CardAction(
                              tooltip: 'تحميل إلى مكتبتي',
                              icon: isSaved
                                  ? Icons.library_add_check_rounded
                                  : Icons.download_rounded,
                              color: const Color(0xFF178FC5),
                              active: isSaved,
                              onTap: onLibraryTap,
                            ),
                          ],
                        ),
                      ],
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

  Widget _placeholder() {
    return ColoredBox(
      color: const Color(0xFFEDEBFA),
      child: Icon(Icons.podcasts_rounded, color: accentColor, size: 34),
    );
  }
}

class _MediaBadge extends StatelessWidget {
  const _MediaBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xD91D1831),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'VIDEO + MP3',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'MohammadBoldArt',
          fontSize: 7,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.active,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final Color color;
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
          width: 27,
          height: 27,
          decoration: BoxDecoration(
            color: active ? color : color.withValues(alpha: .10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 15, color: active ? Colors.white : color),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xD91D1831),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'MohammadBoldArt',
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
