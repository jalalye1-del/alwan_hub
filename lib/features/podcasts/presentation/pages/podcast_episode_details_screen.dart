import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/audio/providers/audio_provider.dart';
import 'package:alwan_hub/core/audio/widgets/mini_player.dart';
import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item_type.dart';
import 'package:alwan_hub/features/library/presentation/providers/library_provider.dart';
import 'package:alwan_hub/features/podcasts/domain/entities/podcast_episode.dart';
import 'package:alwan_hub/features/podcasts/domain/mappers/podcast_episode_mapper.dart';
import 'package:alwan_hub/features/podcasts/presentation/widgets/podcast_typography.dart';

import 'podcast_video_player_screen.dart';

class PodcastEpisodeDetailsScreen extends ConsumerWidget {
  const PodcastEpisodeDetailsScreen({
    super.key,
    required this.episode,
    required this.playlist,
  });

  final PodcastEpisode episode;
  final List<PodcastEpisode> playlist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = episode.toAudioTrack();
    final audioState = ref.watch(audioPlayerProvider);
    final savedItems = ref.watch(libraryItemsProvider).valueOrNull ?? const [];
    final isSaved = savedItems.any((item) => item.sourceId == episode.id);
    final isPlaying =
        audioState.currentTrack?.id == episode.id && audioState.isPlaying;
    final isFavorite = audioState.isFavorite(episode.id);

    return PodcastTypography(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FD),
        bottomNavigationBar: const MiniPlayer(),
        body: Column(
          children: [
            const AlwanPageHeader(
              title: 'تفاصيل الحلقة',
              subtitle: 'بودكاست ألوان',
              trailing: SizedBox(width: 48, height: 48),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 28),
                child: ResponsiveContent(
                  maxWidth: 760,
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _EpisodeHero(
                        episode: episode,
                        onVideo: () => _openVideo(context, ref),
                      ),
                      Padding(
                        padding: context.responsive.pagePadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 18),
                            Text(
                              episode.title,
                              style: const TextStyle(
                                color: Color(0xFF292F70),
                                fontFamily: 'MohammadBoldArt',
                                fontSize: 22,
                                height: 1.3,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              episode.description,
                              style: const TextStyle(
                                color: Color(0xFF697287),
                                fontFamily: 'MohammadBoldArt',
                                fontSize: 12,
                                height: 1.65,
                              ),
                            ),
                            const SizedBox(height: 15),
                            _EpisodeMeta(episode: episode),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: _VideoPlayButton(
                                    onPressed: () => _openVideo(context, ref),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _PrimaryPlayButton(
                                    isPlaying: isPlaying,
                                    onPressed: () => _togglePlay(ref, track),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _DetailAction(
                                  tooltip: 'إضافة إلى المفضلة',
                                  icon: isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  active: isFavorite,
                                  color: const Color(0xFFE5446D),
                                  onTap: () => ref
                                      .read(audioControllerProvider)
                                      .toggleFavorite(track),
                                ),
                                const SizedBox(width: 10),
                                _DetailAction(
                                  tooltip: 'تحميل إلى مكتبتي',
                                  icon: isSaved
                                      ? Icons.library_add_check_rounded
                                      : Icons.download_rounded,
                                  active: isSaved,
                                  color: const Color(0xFF178FC5),
                                  onTap: () => _saveToLibrary(context, ref),
                                ),
                                const SizedBox(width: 10),
                                _DetailAction(
                                  tooltip: 'مشاركة الحلقة',
                                  icon: Icons.ios_share_rounded,
                                  active: false,
                                  color: const Color(0xFF7438AA),
                                  onTap: _shareEpisode,
                                ),
                              ],
                            ),
                            const SizedBox(height: 23),
                            const Text(
                              'حلقات أخرى من بودكاست ألوان',
                              style: TextStyle(
                                color: Color(0xFF292F70),
                                fontFamily: 'MohammadBoldArt',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 9),
                            for (final related in playlist.where(
                              (item) => item.id != episode.id,
                            )) ...[
                              _RelatedEpisodeTile(
                                episode: related,
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PodcastEpisodeDetailsScreen(
                                      episode: related,
                                      playlist: playlist,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
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

  Future<void> _togglePlay(WidgetRef ref, AudioTrack track) async {
    final audioState = ref.read(audioPlayerProvider);
    final controller = ref.read(audioControllerProvider);
    if (audioState.currentTrack?.id == episode.id) {
      await controller.togglePlayPause();
      return;
    }
    final tracks = playlist.map((item) => item.toAudioTrack()).toList();
    await controller.loadPlaylist(
      tracks,
      initialIndex: playlist.indexOf(episode),
    );
  }

  void _openVideo(BuildContext context, WidgetRef ref) {
    ref.read(audioControllerProvider).pause();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PodcastVideoPlayerScreen(episode: episode, playlist: playlist),
      ),
    );
  }

  Future<void> _saveToLibrary(BuildContext context, WidgetRef ref) async {
    final repository = ref.read(libraryRepositoryProvider);
    final itemId = 'podcast-library-${episode.id}';
    final existing = await repository.getItem(itemId);
    if (existing == null) {
      await repository.saveItem(
        LibraryItem(
          id: itemId,
          title: episode.title,
          type: LibraryItemType.podcast,
          categoryId: 'podcasts',
          sourceId: episode.id,
          localPath: episode.audioUrl,
          audioUrl: episode.audioUrl,
          videoUrl: episode.videoUrl,
          coverUrl: episode.imageAsset,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      await repository.updateItem(
        existing.copyWith(
          title: episode.title,
          localPath: episode.audioUrl,
          audioUrl: episode.audioUrl,
          videoUrl: episode.videoUrl,
          coverUrl: episode.imageAsset,
        ),
      );
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existing == null
              ? 'تم تحميل الحلقة وإضافتها إلى مكتبتي'
              : 'تم تحديث الحلقة في مكتبتي بنسختي الفيديو وMP3',
        ),
        backgroundColor: const Color(0xFF493B91),
      ),
    );
  }

  Future<void> _shareEpisode() async {
    await SharePlus.instance.share(
      ShareParams(
        subject: episode.title,
        text:
            'شاهد أو استمع إلى "${episode.title}" من ${episode.seriesName} على تطبيق ألوان. ${episode.videoUrl}',
      ),
    );
  }
}

class _EpisodeHero extends StatelessWidget {
  const _EpisodeHero({required this.episode, required this.onVideo});

  final PodcastEpisode episode;
  final VoidCallback onVideo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: AspectRatio(
          aspectRatio: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(episode.imageAsset, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x08000000), Color(0xC91A102B)],
                    ),
                  ),
                ),
                Center(
                  child: InkWell(
                    onTap: onVideo,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .94),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 14),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFF7131A1),
                        size: 42,
                      ),
                    ),
                  ),
                ),
                const PositionedDirectional(
                  top: 12,
                  start: 12,
                  child: _MediaAvailabilityBadge(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EpisodeMeta extends StatelessWidget {
  const _EpisodeMeta({required this.episode});

  final PodcastEpisode episode;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetaChip(icon: Icons.mic_rounded, label: episode.hostName),
        _MetaChip(icon: Icons.schedule_rounded, label: episode.durationLabel),
        _MetaChip(
          icon: Icons.headphones_rounded,
          label: '${episode.listeners} مستمع',
        ),
        const _MetaChip(
          icon: Icons.ondemand_video_rounded,
          label: 'فيديو + MP3',
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE2EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF7131A1), size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF596176),
              fontFamily: 'MohammadBoldArt',
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryPlayButton extends StatelessWidget {
  const _PrimaryPlayButton({required this.isPlaying, required this.onPressed});

  final bool isPlaying;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF7131A1),
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
      label: Text(isPlaying ? 'إيقاف مؤقت' : 'استمع الآن'),
    );
  }
}

class _VideoPlayButton extends StatelessWidget {
  const _VideoPlayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFFE64273),
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.ondemand_video_rounded),
      label: const Text('شاهد الفيديو'),
    );
  }
}

class _MediaAvailabilityBadge extends StatelessWidget {
  const _MediaAvailabilityBadge();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE61A102B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_rounded, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text(
              'VIDEO',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'MohammadBoldArt',
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 7),
            Icon(Icons.headphones_rounded, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text(
              'MP3',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'MohammadBoldArt',
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailAction extends StatelessWidget {
  const _DetailAction({
    required this.tooltip,
    required this.icon,
    required this.active,
    required this.color,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: context.translateInterface(tooltip),
      child: IconButton.filledTonal(
        onPressed: onTap,
        style: IconButton.styleFrom(
          minimumSize: const Size(52, 52),
          backgroundColor: active ? color : color.withValues(alpha: .10),
          foregroundColor: active ? Colors.white : color,
        ),
        icon: Icon(icon),
      ),
    );
  }
}

class _RelatedEpisodeTile extends StatelessWidget {
  const _RelatedEpisodeTile({required this.episode, required this.onTap});

  final PodcastEpisode episode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFDDE2EB)),
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          episode.imageAsset,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        episode.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF292F70),
          fontFamily: 'MohammadBoldArt',
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        '${episode.seriesName} • ${episode.durationLabel}',
        style: const TextStyle(
          color: Color(0xFF7B8498),
          fontFamily: 'MohammadBoldArt',
          fontSize: 10,
        ),
      ),
      trailing: Icon(
        Directionality.of(context) == TextDirection.rtl
            ? Icons.chevron_left_rounded
            : Icons.chevron_right_rounded,
      ),
    );
  }
}
