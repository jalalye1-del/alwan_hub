import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import 'package:alwan_hub/features/podcasts/presentation/providers/podcast_provider.dart';
import 'package:alwan_hub/features/podcasts/presentation/widgets/podcast_episode_card.dart';
import 'package:alwan_hub/features/podcasts/presentation/widgets/podcast_featured_hero_card.dart';
import 'package:alwan_hub/features/podcasts/presentation/widgets/podcast_typography.dart';

import 'podcast_episode_details_screen.dart';
import 'podcast_video_player_screen.dart';

class PodcastsScreen extends ConsumerStatefulWidget {
  const PodcastsScreen({super.key});

  @override
  ConsumerState<PodcastsScreen> createState() => _PodcastsScreenState();
}

class _PodcastsScreenState extends ConsumerState<PodcastsScreen> {
  static const _accentColors = [
    Color(0xFF7B35AD),
    Color(0xFF188FC5),
    Color(0xFFE44870),
  ];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(libraryInitializerProvider).initialize(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final episodesAsync = ref.watch(podcastEpisodesProvider);

    return PodcastTypography(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FD),
        bottomNavigationBar: const MiniPlayer(),
        body: Column(
          children: [
            AlwanPageHeader(
              title: 'بودكاست ألوان',
              subtitle: 'حكايات وأفكار يمنية بصوت أقرب إليك',
              trailing: IconButton.filledTonal(
                tooltip: context.translateInterface('البحث'),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF343A8D),
                  side: const BorderSide(color: Color(0xFFDDE2EB)),
                ),
                onPressed: () => _showSearchReadyMessage(context),
                icon: const Icon(Icons.search_rounded),
              ),
            ),
            Expanded(
              child: episodesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => _PodcastError(
                  onRetry: () => ref.invalidate(podcastEpisodesProvider),
                ),
                data: (episodes) => _buildContent(context, episodes),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<PodcastEpisode> episodes) {
    if (episodes.isEmpty) {
      return const Center(child: Text('لا توجد حلقات متاحة حاليًا'));
    }

    final featured = episodes.firstWhere(
      (episode) => episode.isFeatured,
      orElse: () => episodes.first,
    );
    final playlist = episodes.map((episode) => episode.toAudioTrack()).toList();
    final audioState = ref.watch(audioPlayerProvider);
    final savedItems = ref.watch(libraryItemsProvider).valueOrNull ?? const [];
    final savedSourceIds = savedItems.map((item) => item.sourceId).toSet();
    final featuredTrack = featured.toAudioTrack();
    final featuredIndex = episodes.indexOf(featured);
    final featuredIsPlaying =
        audioState.currentTrack?.id == featuredTrack.id && audioState.isPlaying;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 28),
      child: ResponsiveContent(
        maxWidth: 760,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _PodcastAdBanner(),
            Padding(
              padding: context.responsive.pagePadding,
              child: const Column(
                children: [
                  SizedBox(height: 20),
                  _PodcastIntro(),
                  SizedBox(height: 15),
                ],
              ),
            ),
            PodcastFeaturedHeroCard(
              episode: featured,
              isFavorite: audioState.isFavorite(featuredTrack.id),
              isSaved: savedSourceIds.contains(featured.id),
              isPlaying: featuredIsPlaying,
              onTap: () => _openEpisode(featured, episodes),
              onVideoPressed: () => _openVideo(featured, episodes),
              onAudioPressed: () => _togglePlay(
                playlist: playlist,
                index: featuredIndex,
                track: featuredTrack,
              ),
              onFavoritePressed: () => _toggleFavorite(featuredTrack),
              onLibraryPressed: () => _saveToLibrary(featured),
            ),
            Padding(
              padding: context.responsive.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 22),
                  const _SectionHeader(
                    icon: Icons.podcasts_rounded,
                    title: 'حلقات بودكاست ألوان',
                    subtitle: 'شاهد الفيديو أو استمع إلى نسخة MP3',
                  ),
                  const SizedBox(height: 11),
                  _EpisodeCardsRow(
                    episodes: episodes.take(3).toList(growable: false),
                    accentColors: _accentColors,
                    audioState: audioState,
                    savedSourceIds: savedSourceIds,
                    onOpen: (episode) => _openEpisode(episode, episodes),
                    onVideo: (episode) => _openVideo(episode, episodes),
                    onPlay: (episode) {
                      final index = episodes.indexOf(episode);
                      _togglePlay(
                        playlist: playlist,
                        index: index,
                        track: playlist[index],
                      );
                    },
                    onFavorite: (episode) =>
                        _toggleFavorite(episode.toAudioTrack()),
                    onLibrary: _saveToLibrary,
                  ),
                  const SizedBox(height: 18),
                  _DashboardReadyCard(episodesCount: episodes.length),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePlay({
    required List<AudioTrack> playlist,
    required int index,
    required AudioTrack track,
  }) async {
    final audioController = ref.read(audioControllerProvider);
    final audioState = ref.read(audioPlayerProvider);
    if (audioState.currentTrack?.id == track.id) {
      await audioController.togglePlayPause();
      return;
    }
    await audioController.loadPlaylist(playlist, initialIndex: index);
  }

  Future<void> _toggleFavorite(AudioTrack track) async {
    await ref.read(audioControllerProvider).toggleFavorite(track);
    if (!mounted) return;
    final isFavorite = ref.read(audioPlayerProvider).isFavorite(track.id);
    _showMessage(
      isFavorite
          ? 'تمت إضافة الحلقة إلى المفضلة'
          : 'تمت إزالة الحلقة من المفضلة',
      color: isFavorite ? const Color(0xFFE5446D) : const Color(0xFF657087),
    );
  }

  Future<void> _saveToLibrary(PodcastEpisode episode) async {
    final repository = ref.read(libraryRepositoryProvider);
    final existing = await repository.getItem('podcast-library-${episode.id}');
    if (existing != null) {
      await repository.updateItem(
        existing.copyWith(
          title: episode.title,
          localPath: episode.audioUrl,
          audioUrl: episode.audioUrl,
          videoUrl: episode.videoUrl,
          coverUrl: episode.imageAsset,
        ),
      );
      if (mounted) {
        _showMessage('تم تحديث الحلقة في مكتبتي بنسختي الفيديو وMP3');
      }
      return;
    }

    await repository.saveItem(
      LibraryItem(
        id: 'podcast-library-${episode.id}',
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
    if (!mounted) return;
    _showMessage('تم تحميل الحلقة وإضافتها إلى مكتبتي');
  }

  void _openEpisode(PodcastEpisode episode, List<PodcastEpisode> episodes) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PodcastEpisodeDetailsScreen(episode: episode, playlist: episodes),
      ),
    );
  }

  void _openVideo(PodcastEpisode episode, List<PodcastEpisode> episodes) {
    ref.read(audioControllerProvider).pause();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PodcastVideoPlayerScreen(episode: episode, playlist: episodes),
      ),
    );
  }

  void _showMessage(String message, {Color color = const Color(0xFF493B91)}) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _showSearchReadyMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('البحث جاهز للربط بمدخلات لوحة التحكم')),
    );
  }
}

class _PodcastAdBanner extends StatelessWidget {
  const _PodcastAdBanner();

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
                Image.asset(
                  'assets/images/banners/banner3.jpg',
                  fit: BoxFit.cover,
                  semanticLabel: context.translateInterface(
                    'بنر إعلاني بمقاس 400 في 200',
                  ),
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
                const PositionedDirectional(
                  top: 12,
                  start: 12,
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
                          fontFamily: 'MohammadBoldArt',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const PositionedDirectional(
                  start: 16,
                  end: 16,
                  bottom: 14,
                  child: Text(
                    'عروض مختارة لمستمعي بودكاست ألوان',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'MohammadBoldArt',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
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

class _PodcastIntro extends StatelessWidget {
  const _PodcastIntro();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'استمع، اكتشف واحتفظ بما تحب',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF292F70),
            fontFamily: 'MohammadBoldArt',
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 3),
        Text(
          'تشغيل مباشر ومفضلة وتحميل إلى مكتبتك من كل بطاقة',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF788196),
            fontFamily: 'MohammadBoldArt',
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
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
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF292F70),
                  fontFamily: 'MohammadBoldArt',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF7B8498),
                  fontFamily: 'MohammadBoldArt',
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EpisodeCardsRow extends StatelessWidget {
  const _EpisodeCardsRow({
    required this.episodes,
    required this.accentColors,
    required this.audioState,
    required this.savedSourceIds,
    required this.onOpen,
    required this.onVideo,
    required this.onPlay,
    required this.onFavorite,
    required this.onLibrary,
  });

  final List<PodcastEpisode> episodes;
  final List<Color> accentColors;
  final AudioPlayerState audioState;
  final Set<String> savedSourceIds;
  final ValueChanged<PodcastEpisode> onOpen;
  final ValueChanged<PodcastEpisode> onVideo;
  final ValueChanged<PodcastEpisode> onPlay;
  final ValueChanged<PodcastEpisode> onFavorite;
  final ValueChanged<PodcastEpisode> onLibrary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < episodes.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          Expanded(
            child: PodcastEpisodeCard(
              episode: episodes[index],
              accentColor: accentColors[index % accentColors.length],
              isFavorite: audioState.isFavorite(episodes[index].id),
              isSaved: savedSourceIds.contains(episodes[index].id),
              isPlaying:
                  audioState.currentTrack?.id == episodes[index].id &&
                  audioState.isPlaying,
              onTap: () => onOpen(episodes[index]),
              onVideoTap: () => onVideo(episodes[index]),
              onPlayTap: () => onPlay(episodes[index]),
              onFavoriteTap: () => onFavorite(episodes[index]),
              onLibraryTap: () => onLibrary(episodes[index]),
            ),
          ),
        ],
      ],
    );
  }
}

class _DashboardReadyCard extends StatelessWidget {
  const _DashboardReadyCard({required this.episodesCount});

  final int episodesCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0D4F1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hub_rounded, color: Color(0xFF7A35A4), size: 21),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '$episodesCount حلقات فيديو وMP3 جاهزة للربط بمدخلات لوحة التحكم',
              style: const TextStyle(
                color: Color(0xFF57456C),
                fontFamily: 'MohammadBoldArt',
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PodcastError extends StatelessWidget {
  const _PodcastError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.podcasts_rounded,
            size: 48,
            color: Color(0xFF7B35AD),
          ),
          const SizedBox(height: 10),
          const Text('تعذر تحميل حلقات البودكاست'),
          const SizedBox(height: 10),
          FilledButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }
}
