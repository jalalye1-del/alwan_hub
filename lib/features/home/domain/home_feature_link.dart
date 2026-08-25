import 'package:alwan_hub/core/content/models/managed_content.dart';
import 'package:alwan_hub/core/content/models/managed_media.dart';

class HomeFeatureLink {
  const HomeFeatureLink({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.imageSource,
    this.sortOrder = 0,
    this.isPublished = true,
  });

  static const String trendingNewsId = 'trending_news';
  static const String dailyHoroscopesId = 'daily_horoscopes';

  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final String? imageSource;
  final int sortOrder;
  final bool isPublished;

  factory HomeFeatureLink.fromManagedContent(ManagedContent content) {
    final image = content.mediaOfType(ManagedMediaType.image);
    return HomeFeatureLink(
      id: content.id,
      title: content.title,
      subtitle: content.subtitle ?? content.description ?? '',
      actionLabel: content.metadata['actionLabel']?.toString() ?? '',
      imageSource: image?.url,
      sortOrder: content.sortOrder,
      isPublished: content.isPublished,
    );
  }
}
