import 'package:hive_flutter/hive_flutter.dart';

class FavoriteStationStorage {
  FavoriteStationStorage._();

  static const String _boxName = 'favorite_stations';
  static const String _key = 'ids';

  static Future<Box> _box() async {
    return await Hive.openBox(_boxName);
  }

  static Future<Set<String>> getFavorites() async {
    final box = await _box();

    final List<dynamic>? ids = box.get(_key);

    if (ids == null) {
      return <String>{};
    }

    return ids.cast<String>().toSet();
  }

  static Future<void> saveFavorites(Set<String> ids) async {
    final box = await _box();
    await box.put(_key, ids.toList());
  }

  static Future<bool> isFavorite(String id) async {
    final favorites = await getFavorites();
    return favorites.contains(id);
  }

  static Future<void> add(String id) async {
    final favorites = await getFavorites();
    favorites.add(id);
    await saveFavorites(favorites);
  }

  static Future<void> remove(String id) async {
    final favorites = await getFavorites();
    favorites.remove(id);
    await saveFavorites(favorites);
  }

  static Future<void> toggle(String id) async {
    final favorites = await getFavorites();

    if (favorites.contains(id)) {
      favorites.remove(id);
    } else {
      favorites.add(id);
    }

    await saveFavorites(favorites);
  }

  static Future<void> clear() async {
    final box = await _box();
    await box.delete(_key);
  }
}