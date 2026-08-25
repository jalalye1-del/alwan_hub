import 'package:alwan_hub/core/content/repositories/content_repository.dart';
import 'package:alwan_hub/features/horoscopes/domain/daily_horoscope.dart';
import 'package:alwan_hub/features/horoscopes/domain/daily_horoscope_repository.dart';
import 'package:alwan_hub/features/horoscopes/domain/horoscope_banner.dart';

class DashboardDailyHoroscopeRepository
    implements DailyHoroscopeRepository {
  const DashboardDailyHoroscopeRepository(this.contentRepository);

  final ContentRepository contentRepository;

  @override
  Stream<List<DailyHoroscope>> watchHoroscopes() {
    return contentRepository.watchPublished(type: 'daily_horoscope').map((
      content,
    ) {
      final sorted = [...content]
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return sorted
          .where((item) => item.isPublished)
          .map(DailyHoroscope.fromManagedContent)
          .toList(growable: false);
    });
  }

  @override
  Stream<HoroscopeBanner?> watchBanner() {
    return contentRepository.watchPublished(type: 'horoscope_banner').map((
      content,
    ) {
      final published = content.where((item) => item.isPublished).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return published.isEmpty
          ? null
          : HoroscopeBanner.fromManagedContent(published.first);
    });
  }
}
