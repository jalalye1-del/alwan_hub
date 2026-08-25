// lib/features/fm_radio/domain/repositories/fm_station_repository.dart

import '../models/fm_station.dart';

abstract class FmStationRepository {
  /// جلب كافة المحطات الإذاعية
  Future<List<FmStation>> getStations();

  /// جلب المحطات المفضلة فقط
  Future<List<FmStation>> getFavoriteStations();

  /// تبديل حالة المفضلة لمحطة معينة (إضافة / إزالة)
  Future<void> toggleFavorite(String stationId);

  /// البحث عن محطات بناءً على نص البحث
  Future<List<FmStation>> searchStations(String query);

  /// جلب تفاصيل محطة واحدة محددة بواسطة معرفها
  Future<FmStation?> getStationById(String id);

  /// تحديث البيانات من المصدر الخارجي (توسع مستقبلي للـ API)
  Future<void> refreshStations();

  /// جلب المحطات حسب التصنيف
  Future<List<FmStation>> getStationsByCategory(String category);

  /// جلب المحطات حسب الدولة
  Future<List<FmStation>> getStationsByCountry(String country);
}