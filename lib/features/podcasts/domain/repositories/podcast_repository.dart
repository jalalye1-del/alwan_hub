import '../entities/podcast_episode.dart';

abstract interface class PodcastRepository {
  Future<List<PodcastEpisode>> fetchEpisodes();
}
