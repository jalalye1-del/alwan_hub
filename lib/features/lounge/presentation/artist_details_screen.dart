import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/widgets/adaptive_content_image.dart';
import 'package:alwan_hub/features/lounge/data/audio_repository.dart';
import 'package:alwan_hub/features/lounge/domain/mappers/audio_item_mapper.dart';
import 'package:alwan_hub/features/lounge/domain/models/audio_item.dart';
import 'package:alwan_hub/features/lounge/presentation/widgets/artist_track_list.dart';

class ArtistDetailsScreen extends ConsumerWidget {
  const ArtistDetailsScreen({
    super.key,
    required this.artistId,
    required this.artistName,
    required this.artistImageUrl,
    required this.primaryColor,
    required this.categoryName,
    this.categoryId = 'alwan_lounge',
    this.trackItemLabel = 'أغنية',
  });

  final String artistId;
  final String artistName;
  final String artistImageUrl;
  final Color primaryColor;
  final String categoryName;
  final String categoryId;
  final String trackItemLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioRepository = ref.read(audioRepositoryProvider);
    final audioController = ref.read(audioControllerProvider);
    final List<AudioItem> artistTracks = audioRepository.getByCategoryItem(
      artistId,
      itemTitle: artistName,
      trackItemLabel: trackItemLabel,
    );
    final List<AudioTrack> playlist = artistTracks
        .map((item) => item.toAudioTrack(category: categoryName))
        .toList();
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: responsive.value(
              compact: 300,
              medium: 340,
              expanded: 380,
            ),
            pinned: true,
            stretch: true,
            backgroundColor: primaryColor,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: InkWell(
                onTap: () {
                  Navigator.maybePop(context);
                },
                borderRadius: BorderRadius.circular(14),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              titlePadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              title: Text(
                artistName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AdaptiveContentImage(
                    source: artistImageUrl,
                    fit: BoxFit.cover,
                    semanticLabel: artistName,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: .08),
                          Colors.transparent,
                          primaryColor.withValues(alpha: .92),
                        ],
                        stops: const [0, .48, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: responsive.pagePadding.copyWith(top: 20, bottom: 8),
              child: _ArtistControls(
                primaryColor: primaryColor,
                tracksCount: artistTracks.length,
                onPlayAll: playlist.isEmpty
                    ? null
                    : () => audioController.loadPlaylist(
                        playlist,
                        initialIndex: 0,
                      ),
              ),
            ),
          ),
          ArtistTrackList(
            artistTracks: artistTracks,
            playlist: playlist,
            artistImageUrl: artistImageUrl,
            primaryColor: primaryColor,
            categoryName: categoryName,
            categoryId: categoryId,
            trackItemLabel: trackItemLabel,
          ),
        ],
      ),
    );
  }
}

class _ArtistControls extends StatelessWidget {
  const _ArtistControls({
    required this.primaryColor,
    required this.tracksCount,
    required this.onPlayAll,
  });

  final Color primaryColor;
  final int tracksCount;
  final VoidCallback? onPlayAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: FilledButton.icon(
            onPressed: onPlayAll,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text(
              'تشغيل الكل',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(0, 58),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            height: 58,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primaryColor.withValues(alpha: .18)),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: .1),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.audio_file_rounded, color: primaryColor, size: 21),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    '$tracksCount ملفاً صوتياً',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF30334A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
