class PodcastEpisode {
  const PodcastEpisode({
    required this.id,
    required this.title,
    required this.description,
    required this.hostName,
    required this.seriesName,
    required this.audioUrl,
    required this.videoUrl,
    required this.videoQualityUrls,
    required this.imageAsset,
    required this.duration,
    required this.publishedAt,
    required this.listeners,
    this.subtitlesUrl,
    this.isFeatured = false,
  });

  final String id;
  final String title;
  final String description;
  final String hostName;
  final String seriesName;
  final String audioUrl;
  final String videoUrl;
  final Map<String, String> videoQualityUrls;
  final String imageAsset;
  final Duration duration;
  final DateTime publishedAt;
  final int listeners;
  final String? subtitlesUrl;
  final bool isFeatured;

  bool get hasAudio => audioUrl.trim().isNotEmpty;
  bool get hasVideo => videoUrl.trim().isNotEmpty;

  String get durationLabel {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Schema-compatible parser for a future CMS/dashboard response.
  factory PodcastEpisode.fromDashboardMap(Map<String, dynamic> map) {
    return PodcastEpisode(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      hostName: map['hostName']?.toString() ?? '',
      seriesName: map['seriesName']?.toString() ?? 'بودكاست ألوان',
      audioUrl: map['audioUrl']?.toString() ?? '',
      videoUrl: map['videoUrl']?.toString() ?? '',
      videoQualityUrls: _parseQualityUrls(map['videoQualityUrls']),
      imageAsset: map['imageUrl']?.toString() ?? '',
      duration: Duration(
        seconds: int.tryParse(map['durationSeconds']?.toString() ?? '') ?? 0,
      ),
      publishedAt:
          DateTime.tryParse(map['publishedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      listeners: int.tryParse(map['listeners']?.toString() ?? '') ?? 0,
      subtitlesUrl: map['subtitlesUrl']?.toString(),
      isFeatured: map['isFeatured'] == true,
    );
  }

  Map<String, dynamic> toDashboardMap() => {
    'id': id,
    'title': title,
    'description': description,
    'hostName': hostName,
    'seriesName': seriesName,
    'audioUrl': audioUrl,
    'videoUrl': videoUrl,
    'videoQualityUrls': videoQualityUrls,
    'subtitlesUrl': subtitlesUrl,
    'imageUrl': imageAsset,
    'durationSeconds': duration.inSeconds,
    'publishedAt': publishedAt.toIso8601String(),
    'listeners': listeners,
    'isFeatured': isFeatured,
  };

  static Map<String, String> _parseQualityUrls(dynamic value) {
    if (value is! Map) return const {};
    return value.map(
      (key, item) => MapEntry(key.toString(), item?.toString() ?? ''),
    );
  }
}
