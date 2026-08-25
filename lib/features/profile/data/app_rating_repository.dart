import 'package:shared_preferences/shared_preferences.dart';

class AppRatingDraft {
  const AppRatingDraft({
    required this.overallRating,
    required this.speedRating,
    required this.designRating,
    required this.contentRating,
    required this.streamingRating,
    required this.recommendation,
    required this.comment,
  });

  const AppRatingDraft.initial()
    : overallRating = 5,
      speedRating = 5,
      designRating = 5,
      contentRating = 5,
      streamingRating = 5,
      recommendation = null,
      comment = '';

  final int overallRating;
  final int speedRating;
  final int designRating;
  final int contentRating;
  final int streamingRating;
  final String? recommendation;
  final String comment;
}

class AppRatingRepository {
  static const _overallKey = 'alwan_rating_overall';
  static const _speedKey = 'alwan_rating_speed';
  static const _designKey = 'alwan_rating_design';
  static const _contentKey = 'alwan_rating_content';
  static const _streamingKey = 'alwan_rating_streaming';
  static const _recommendationKey = 'alwan_rating_recommendation';
  static const _commentKey = 'alwan_rating_comment';

  Future<AppRatingDraft> load() async {
    final preferences = await SharedPreferences.getInstance();
    const fallback = AppRatingDraft.initial();
    return AppRatingDraft(
      overallRating: preferences.getInt(_overallKey) ?? fallback.overallRating,
      speedRating: preferences.getInt(_speedKey) ?? fallback.speedRating,
      designRating: preferences.getInt(_designKey) ?? fallback.designRating,
      contentRating: preferences.getInt(_contentKey) ?? fallback.contentRating,
      streamingRating:
          preferences.getInt(_streamingKey) ?? fallback.streamingRating,
      recommendation: preferences.getString(_recommendationKey),
      comment: preferences.getString(_commentKey) ?? fallback.comment,
    );
  }

  Future<void> save(AppRatingDraft rating) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setInt(_overallKey, rating.overallRating),
      preferences.setInt(_speedKey, rating.speedRating),
      preferences.setInt(_designKey, rating.designRating),
      preferences.setInt(_contentKey, rating.contentRating),
      preferences.setInt(_streamingKey, rating.streamingRating),
      if (rating.recommendation == null)
        preferences.remove(_recommendationKey)
      else
        preferences.setString(_recommendationKey, rating.recommendation!),
      preferences.setString(_commentKey, rating.comment),
    ]);
  }
}
