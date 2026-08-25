import 'package:alwan_hub/features/home/domain/home_feature_link.dart';
import 'package:alwan_hub/features/home/domain/home_feature_link_repository.dart';

class LocalHomeFeatureLinkRepository implements HomeFeatureLinkRepository {
  const LocalHomeFeatureLinkRepository();

  static const List<HomeFeatureLink> defaults = [
    HomeFeatureLink(
      id: HomeFeatureLink.trendingNewsId,
      title: 'الأخبار الرائجة',
      subtitle: 'تابع أبرز الأخبار والموضوعات الأكثر تداولًا الآن',
      actionLabel: 'استكشف الأخبار',
      sortOrder: 0,
    ),
    HomeFeatureLink(
      id: HomeFeatureLink.dailyHoroscopesId,
      title: 'الأبراج اليومية',
      subtitle: 'اكتشف توقعات برجك في الحب والعمل والصحة اليوم',
      actionLabel: 'اعرف حظك اليوم',
      sortOrder: 1,
    ),
  ];

  @override
  Stream<List<HomeFeatureLink>> watchLinks() => Stream.value(defaults);
}
