import 'daily_horoscope.dart';
import 'horoscope_banner.dart';

abstract interface class DailyHoroscopeRepository {
  Stream<List<DailyHoroscope>> watchHoroscopes();

  Stream<HoroscopeBanner?> watchBanner();
}
