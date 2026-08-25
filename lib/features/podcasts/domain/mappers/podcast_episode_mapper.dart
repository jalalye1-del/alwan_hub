import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/features/podcasts/domain/entities/podcast_episode.dart';

extension PodcastEpisodeMapper on PodcastEpisode {
  AudioTrack toAudioTrack() {
    return AudioTrack(
      id: id,
      title: title,
      subtitle: seriesName,
      description: description,
      url: audioUrl,
      imageUrl: imageAsset,
      coverUrl: imageAsset,
      presenterName: hostName,
      programImage: imageAsset,
      sourceType: AudioSourceType.podcast,
      category: 'بودكاست ألوان',
      durationText: durationLabel,
      duration: duration,
    );
  }
}
