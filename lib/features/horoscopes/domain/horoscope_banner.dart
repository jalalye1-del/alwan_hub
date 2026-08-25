import 'package:alwan_hub/core/content/models/managed_content.dart';
import 'package:alwan_hub/core/content/models/managed_media.dart';

class HoroscopeBanner {
  const HoroscopeBanner({
    required this.title,
    required this.subtitle,
    this.imageSource,
  });

  final String title;
  final String subtitle;
  final String? imageSource;

  factory HoroscopeBanner.fromManagedContent(ManagedContent content) {
    return HoroscopeBanner(
      title: content.title,
      subtitle: content.subtitle ?? content.description ?? '',
      imageSource: content.mediaOfType(ManagedMediaType.image)?.url,
    );
  }
}
