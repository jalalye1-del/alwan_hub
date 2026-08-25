import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/features/audiobooks/data/repositories/local_audiobook_playback_catalog_repository.dart';
import 'package:alwan_hub/features/audiobooks/domain/repositories/audiobook_playback_catalog_repository.dart';

/// يُستبدل هذا المزود في نقطة تشغيل التطبيق بمستودع لوحة التحكم عند توفره.
final audiobookPlaybackCatalogRepositoryProvider =
    Provider<AudiobookPlaybackCatalogRepository>((ref) {
      return const LocalAudiobookPlaybackCatalogRepository();
    });

final audiobookTracksProvider = StreamProvider<List<AudioTrack>>((ref) {
  return ref.watch(audiobookPlaybackCatalogRepositoryProvider).watchBooks();
});
