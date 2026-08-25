class AudioItem {
  final String id;

  /// اسم المادة
  final String title;

  /// اسم الفنان أو القارئ أو مقدم البرنامج
  final String artist;

  /// رابط الملف الصوتي
  final String audioUrl;

  /// صورة الغلاف
  final String artworkUrl;

  /// مدة المادة
  final Duration? duration;

  /// هل المادة مفضلة؟
  final bool isFavorite;

  /// هل تم تحميلها؟
  final bool isDownloaded;

  const AudioItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.artworkUrl,
    this.duration,
    this.isFavorite = false,
    this.isDownloaded = false,
  });
}