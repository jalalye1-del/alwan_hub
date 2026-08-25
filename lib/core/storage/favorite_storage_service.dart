// lib/core/storage/favorite_storage_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_item.dart';

class FavoriteStorageService {
  static const String _key = 'global_favorites_data';

  // حفظ قائمة المفضلات بالكامل في ذاكرة الجهاز
  static Future<void> saveFavorites(List<FavoriteItem> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    // تحويل قائمة الكائنات إلى قائمة JSON ثم إلى نص (String)
    final String encodedData = jsonEncode(
      favorites.map((item) => item.toJson()).toList(),
    );
    await prefs.setString(_key, encodedData);
  }

  // استرجاع المفضلات عند فتح التطبيق
  static Future<List<FavoriteItem>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_key);
    
    if (encodedData != null && encodedData.isNotEmpty) {
      try {
        // تحويل النص إلى بيانات، ثم إلى قائمة من الكائنات (Objects)
        final List<dynamic> decodedData = jsonDecode(encodedData);
        return decodedData.map((json) => FavoriteItem.fromJson(json)).toList();
      } catch (e) {
        // في حال حدوث خطأ في قراءة البيانات القديمة
        return [];
      }
    }
    return [];
  }
}