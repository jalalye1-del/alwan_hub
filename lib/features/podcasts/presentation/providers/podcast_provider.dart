import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/features/podcasts/data/repositories/local_podcast_repository.dart';
import 'package:alwan_hub/features/podcasts/domain/entities/podcast_episode.dart';
import 'package:alwan_hub/features/podcasts/domain/repositories/podcast_repository.dart';

final podcastRepositoryProvider = Provider<PodcastRepository>((ref) {
  return const LocalPodcastRepository();
});

final podcastEpisodesProvider = FutureProvider<List<PodcastEpisode>>((ref) {
  return ref.watch(podcastRepositoryProvider).fetchEpisodes();
});
