// lib/core/providers/favorites_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/favorite_item.dart';
import '../storage/favorite_storage_service.dart';

class FavoritesNotifier extends StateNotifier<List<FavoriteItem>> {
  FavoritesNotifier() : super([]) {
    _initLoad(); // استدعاء البيانات من الذاكرة فور تشغيل التطبيق
  }

  // تحميل البيانات الحقيقية
  Future<void> _initLoad() async {
    final savedFavorites = await FavoriteStorageService.loadFavorites();
    state = savedFavorites;
  }

  // إضافة أو إزالة من المفضلة + حفظ تلقائي
  Future<void> toggleFavorite(FavoriteItem item) async {
    final exists = state.any((element) => element.id == item.id);
    
    if (exists) {
      // إزالة إذا كان موجوداً
      state = state.where((element) => element.id != item.id).toList();
    } else {
      // إضافة إذا لم يكن موجوداً
      state = [...state, item];
    }
    
    // حفظ التحديث الجديد في ذاكرة الهاتف/الويب مباشرة
    await FavoriteStorageService.saveFavorites(state);
  }

  // دالة مساعدة للتحقق مما إذا كان العنصر في المفضلة (لتغيير لون أيقونة القلب)
  bool isFavorite(String id) {
    return state.any((element) => element.id == id);
  }
}

// إنشاء الـ Provider العام
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<FavoriteItem>>((ref) {
  return FavoritesNotifier();
});