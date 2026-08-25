import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/audio/providers/audio_provider.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/features/library/domain/entities/library_category.dart';
import 'package:alwan_hub/features/library/domain/repositories/library_repository.dart';
import 'package:alwan_hub/features/library/presentation/providers/library_provider.dart';
import 'package:alwan_hub/features/lounge/domain/models/audio_item.dart';
import 'package:alwan_hub/features/lounge/presentation/widgets/audio_list_item.dart';
import 'package:alwan_hub/features/lounge/presentation/widgets/library_actions.dart';

class ArtistTrackList extends ConsumerStatefulWidget {
  const ArtistTrackList({
    super.key,
    required this.artistTracks,
    required this.playlist,
    required this.artistImageUrl,
    required this.primaryColor,
    required this.categoryName,
    required this.categoryId,
    this.trackItemLabel = 'أغنية',
  });

  final List<AudioItem> artistTracks;
  final List<AudioTrack> playlist;
  final String artistImageUrl;
  final Color primaryColor;
  final String categoryName;
  final String categoryId;
  final String trackItemLabel;

  @override
  ConsumerState<ArtistTrackList> createState() => _ArtistTrackListState();
}

class _ArtistTrackListState extends ConsumerState<ArtistTrackList> {
  final Set<String> _downloadedIds = {};

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(libraryInitializerProvider).initialize(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final libraryRepository = ref.read(libraryRepositoryProvider);
    final audioController = ref.read(audioControllerProvider);
    final audioState = ref.watch(audioPlayerProvider);
    final categories = ref
        .watch(libraryCategoriesProvider)
        .when(
          data: (items) => items,
          loading: () => const <LibraryCategory>[],
          error: (_, _) => const <LibraryCategory>[],
        );

    if (widget.artistTracks.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
          child: Center(
            child: Text(
              'لا توجد ملفات صوتية متوفرة حالياً',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: context.responsive.pagePadding.copyWith(
              top: 18,
              bottom: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 5,
                  height: 27,
                  decoration: BoxDecoration(
                    color: widget.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'الملفات الصوتية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: context.responsive.pagePadding,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final track = widget.artistTracks[index];
              final audioTrack = widget.playlist[index];
              final isCurrent = audioState.currentTrack?.id == audioTrack.id;

              return AudioListItem(
                index: index + 1,
                title: track.title,
                duration: track.duration ?? Duration.zero,
                isFavorite: audioState.isFavorite(audioTrack.id),
                isDownloaded:
                    track.isDownloaded || _downloadedIds.contains(track.id),
                isPlaying: isCurrent && audioState.isPlaying,
                accentColor: widget.primaryColor,
                moreItemLabel: widget.trackItemLabel,
                onTap: () => audioController.loadPlaylist(
                  widget.playlist,
                  initialIndex: index,
                ),
                onPlay: () {
                  if (isCurrent) {
                    audioController.togglePlayPause();
                  } else {
                    audioController.loadPlaylist(
                      widget.playlist,
                      initialIndex: index,
                    );
                  }
                },
                onFavorite: () => audioController.toggleFavorite(audioTrack),
                onDownload: () => _downloadTrack(track, libraryRepository),
                onShare: () => shareAudioTrack(track),
                onLibrary: () => showLibraryCategoriesDialog(
                  context,
                  libraryRepository,
                  track,
                  categories,
                  widget.primaryColor,
                  sourceCategoryId: widget.categoryId,
                ),
                onFolders: () => showSelectFolderDialog(
                  context,
                  libraryRepository,
                  track,
                  widget.categoryId,
                  widget.primaryColor,
                ),
                onCreateFolder: () => showCreateFolderDialog(
                  context,
                  libraryRepository,
                  track,
                  widget.categoryId,
                  widget.primaryColor,
                ),
              );
            }, childCount: widget.artistTracks.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Future<void> _downloadTrack(
    AudioItem track,
    LibraryRepository libraryRepository,
  ) async {
    final uri = Uri.tryParse(track.audioUrl.trim());
    if (uri == null || !uri.hasScheme) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رابط تحميل هذا الملف غير متوفر حالياً.')),
      );
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (opened) {
      await libraryRepository.saveItem(
        createLibraryItem(track, widget.categoryId),
      );
      if (!mounted) return;
      setState(() => _downloadedIds.add(track.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم فتح تحميل "${track.title}" وإضافته إلى مكتبتي.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح رابط التحميل.')));
    }
  }
}
