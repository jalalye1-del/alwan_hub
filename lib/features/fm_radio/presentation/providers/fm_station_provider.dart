// lib/features/fm_radio/presentation/providers/fm_station_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/local_fm_station_repository.dart';
import '../../domain/models/fm_station.dart';
import '../../domain/models/fm_filter.dart';
import '../../domain/repositories/fm_station_repository.dart';

/// الاعتماد الصارم على الواجهة المجردة (Interface) للتحضير للـ API لاحقاً
final fmStationRepositoryProvider = Provider<FmStationRepository>((ref) {
  return LocalFmStationRepository();
});

/// جميع المحطات
final fmStationsProvider = FutureProvider<List<FmStation>>((ref) async {
  final repository = ref.watch(fmStationRepositoryProvider);
  return repository.getStations();
});

/// المحطات المفضلة
final favoriteFmStationsProvider = FutureProvider<List<FmStation>>((ref) async {
  final repository = ref.watch(fmStationRepositoryProvider);
  return repository.getFavoriteStations();
});

/// Provider للبحث المباشر عبر الـ Repository
final searchFmStationsProvider = FutureProvider.family<List<FmStation>, String>((ref, query) async {
  final repository = ref.watch(fmStationRepositoryProvider);
  return repository.searchStations(query);
});

/// Provider لجلب محطة واحدة بواسطة معرفها
final stationProvider = FutureProvider.family<FmStation?, String>((ref, id) async {
  final repository = ref.watch(fmStationRepositoryProvider);
  return repository.getStationById(id);
});

/// Notifier لتحديث المفضلة وإعادة جلب البيانات تلقائياً
class FavoriteNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggleFavorite(String stationId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(fmStationRepositoryProvider);
      await repository.toggleFavorite(stationId);
      
      // استدعاء الدالة المركزية لتحديث جميع المزودات المرتبطة
      _invalidateRelatedProviders(stationId);
    });
  }

  // تجميع دوال التحديث في مكان واحد لسهولة إدارتها
  void _invalidateRelatedProviders(String stationId) {
    ref.invalidate(favoriteFmStationsProvider);
    ref.invalidate(fmStationsProvider);
    ref.invalidate(stationProvider(stationId));
  }
}

final favoriteNotifierProvider = AsyncNotifierProvider<FavoriteNotifier, void>(FavoriteNotifier.new);

/// موجه نص البحث
final fmSearchQueryProvider = StateProvider<String>((ref) => '');

/// موجه حالة الفلتر الحالي
final fmFilterProvider = StateProvider<FmFilter>((ref) => FmFilter.all);

/// Notifier لإدارة المحطة النشطة
class ActiveStationNotifier extends Notifier<FmStation?> {
  @override
  FmStation? build() {
    // التطبيق يبدأ بدون محطة محددة افتراضياً
    return null; 
  }

  void setActiveStation(FmStation station) {
    state = station;
  }
}

final activeStationProvider = NotifierProvider<ActiveStationNotifier, FmStation?>(ActiveStationNotifier.new);

// ============================================================================
// دوال الفلترة والبحث المركزية (Centralized Filtering & Searching)
// ============================================================================

/// دالة مساعدة لتطبيق الفلتر والبحث على أي قائمة محطات لمنع تكرار الكود
List<FmStation> _applyFilterAndSearch(List<FmStation> stations, FmFilter filter, String query) {
  var result = stations;

  // أولاً: تطبيق الفلتر (التصنيف)
  switch (filter) {
    case FmFilter.all:
      break;
    case FmFilter.yemeni:
      result = result.where((e) => e.country == 'اليمن').toList();
      break;
    case FmFilter.arabic:
      result = result.where((e) => e.type == 'إذاعات عربية').toList();
      break;
    case FmFilter.world:
      result = result.where((e) => e.type == 'إذاعات عالمية' || e.type == 'World Radio').toList();
      break;
    case FmFilter.religious:
      result = result.where((e) => e.category == 'إذاعة دينية').toList();
      break;
  }

  // ثانياً: تطبيق البحث الذكي الشامل (مع دعم اسم البرنامج والوصف)
  if (query.isNotEmpty) {
    result = result.where((s) =>
        s.name.toLowerCase().contains(query) ||
        s.country.toLowerCase().contains(query) ||
        s.type.toLowerCase().contains(query) ||
        s.city.toLowerCase().contains(query) ||
        s.language.toLowerCase().contains(query) ||
        s.category.toLowerCase().contains(query) ||
        s.frequency.toLowerCase().contains(query) ||
        s.currentProgram.toLowerCase().contains(query) ||
        s.description.toLowerCase().contains(query)
    ).toList();
  }

  return result;
}

/// Provider القائمة النهائية للاستكشاف (يجمع كل المحطات + الفلتر + البحث)
final visibleStationsProvider = Provider<List<FmStation>>((ref) {
  final stationsAsync = ref.watch(fmStationsProvider);
  final query = ref.watch(fmSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(fmFilterProvider);

  return stationsAsync.maybeWhen(
    data: (stations) => _applyFilterAndSearch(stations, filter, query),
    orElse: () => [],
  );
});

/// Provider القائمة النهائية للمفضلة (يجمع المفضلة + الفلتر + البحث)
final visibleFavoriteStationsProvider = Provider<List<FmStation>>((ref) {
  final favoritesAsync = ref.watch(favoriteFmStationsProvider);
  final query = ref.watch(fmSearchQueryProvider).trim().toLowerCase();
  final filter = ref.watch(fmFilterProvider);

  return favoritesAsync.maybeWhen(
    data: (favorites) => _applyFilterAndSearch(favorites, filter, query),
    orElse: () => [],
  );
});