import 'package:alwan_hub/features/horoscopes/data/daily_horoscope_catalog.dart';
import 'package:alwan_hub/features/horoscopes/domain/daily_horoscope.dart';
import 'package:alwan_hub/features/horoscopes/domain/daily_horoscope_repository.dart';
import 'package:alwan_hub/features/horoscopes/domain/horoscope_banner.dart';

class LocalDailyHoroscopeRepository implements DailyHoroscopeRepository {
  const LocalDailyHoroscopeRepository();

  static const HoroscopeBanner defaultBanner = HoroscopeBanner(
    title: 'رسالتك من النجوم اليوم',
    subtitle: 'توقعات يومية للأبراج الاثني عشر',
  );

  @override
  Stream<List<DailyHoroscope>> watchHoroscopes() {
    return Stream.value(DailyHoroscopeCatalog.items);
  }

  @override
  Stream<HoroscopeBanner?> watchBanner() => Stream.value(defaultBanner);
}
