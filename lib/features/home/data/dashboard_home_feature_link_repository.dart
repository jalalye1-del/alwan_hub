import 'package:alwan_hub/core/content/repositories/content_repository.dart';
import 'package:alwan_hub/features/home/domain/home_feature_link.dart';
import 'package:alwan_hub/features/home/domain/home_feature_link_repository.dart';

class DashboardHomeFeatureLinkRepository
    implements HomeFeatureLinkRepository {
  const DashboardHomeFeatureLinkRepository(this.contentRepository);

  final ContentRepository contentRepository;

  @override
  Stream<List<HomeFeatureLink>> watchLinks() {
    return contentRepository.watchPublished(type: 'home_feature_link').map((
      content,
    ) {
      final links = content
          .map(HomeFeatureLink.fromManagedContent)
          .where(
            (link) =>
                link.isPublished &&
                (link.id == HomeFeatureLink.trendingNewsId ||
                    link.id == HomeFeatureLink.dailyHoroscopesId),
          )
          .toList(growable: false);
      return [...links]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    });
  }
}
