import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/features/horoscopes/data/local_daily_horoscope_repository.dart';
import 'package:alwan_hub/features/horoscopes/domain/daily_horoscope.dart';
import 'package:alwan_hub/features/horoscopes/domain/daily_horoscope_repository.dart';
import 'package:alwan_hub/features/horoscopes/domain/horoscope_banner.dart';

/// Override with DashboardDailyHoroscopeRepository when the managed-content
/// API is configured at application bootstrap.
final dailyHoroscopeRepositoryProvider = Provider<DailyHoroscopeRepository>((
  ref,
) {
  return const LocalDailyHoroscopeRepository();
});

final dailyHoroscopesProvider = StreamProvider<List<DailyHoroscope>>((ref) {
  return ref.watch(dailyHoroscopeRepositoryProvider).watchHoroscopes();
});

final horoscopeBannerProvider = StreamProvider<HoroscopeBanner?>((ref) {
  return ref.watch(dailyHoroscopeRepositoryProvider).watchBanner();
});
