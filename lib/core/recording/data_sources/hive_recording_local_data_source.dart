// lib/core/recording/data_sources/hive_recording_local_data_source.dart

import 'package:hive/hive.dart';

import '../models/recording_file.dart';
import 'recording_local_data_source.dart'; // 🟢 استيراد الواجهة

// 🟢 تنفيذ الواجهة المجردة
class HiveRecordingLocalDataSource implements RecordingLocalDataSource {
  static const String boxName = 'recordings';

  final Box<RecordingFile> _box;

  HiveRecordingLocalDataSource(this._box);

  // ---------------------------------------------------------------------------
  // القراءة (تم توحيد الأسماء لتطابق الواجهة)
  // ---------------------------------------------------------------------------

  @override
  Future<List<RecordingFile>> getAll() async {
    final list = _box.values.toList();

    list.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    return list;
  }

  @override
  Future<RecordingFile?> getById(String id) async {
    try {
      return _box.get(id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<RecordingFile>> getFavorites() async {
    return _box.values
        .where((e) => e.isFavorite)
        .toList();
  }

  @override
  Future<List<RecordingFile>> getByCategory(String category) async {
    return _box.values
        .where((e) => e.category == category)
        .toList();
  }

  @override
  Future<List<RecordingFile>> getByFolder(String folderName) async {
    return _box.values
        .where((e) => e.folderName == folderName)
        .toList();
  }

  @override
  Future<List<RecordingFile>> search(String query) async {
    if (query.trim().isEmpty) {
      return getAll();
    }

    final q = query.toLowerCase();

    return _box.values.where((item) {
      return item.title.toLowerCase().contains(q) ||
          item.fileName.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.folderName.toLowerCase().contains(q) ||
          (item.stationName?.toLowerCase().contains(q) ?? false) ||
          (item.programName?.toLowerCase().contains(q) ?? false) ||
          item.tags.any(
            (e) => e.toLowerCase().contains(q),
          );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // الكتابة
  // ---------------------------------------------------------------------------

  @override
  Future<void> save(RecordingFile recording) async {
    await _box.put(
      recording.id,
      recording,
    );
  }

  @override
  Future<void> update(RecordingFile recording) async {
    await _box.put(
      recording.id,
      recording,
    );
  }

  @override
  Future<void> saveAll(List<RecordingFile> recordings) async {
    final map = {
      for (final item in recordings) item.id: item,
    };

    await _box.putAll(map);
  }

  // ---------------------------------------------------------------------------
  // الحذف
  // ---------------------------------------------------------------------------

  @override
  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> deleteAll(List<String> ids) async {
    await _box.deleteAll(ids);
  }

  @override
  Future<void> clear() async {
    await _box.clear();
  }

  // ---------------------------------------------------------------------------
  // الأدوات (تم إضافة compact و close)
  // ---------------------------------------------------------------------------

  @override
  Future<bool> exists(String id) async {
    return _box.containsKey(id);
  }

  @override
  Future<int> count() async {
    return _box.length;
  }

  @override
  Future<void> compact() async {
    await _box.compact();
  }

  @override
  Future<void> close() async {
    if (_box.isOpen) {
      await _box.flush(); // التأكد من كتابة كل شيء قبل الإغلاق
      await _box.close();
    }
  }

  // =========================================================================
  // دوال إضافية خاصة بـ Hive (غير موجودة في الواجهة ولكن يمكن الاحتفاظ بها)
  // =========================================================================

  Future<List<RecordingFile>> byStatus(RecordingStatus status) async {
    return _box.values
        .where((e) => e.status == status)
        .toList();
  }

  Future<List<RecordingFile>> bySource(RecordingSourceType type) async {
    return _box.values
        .where((e) => e.sourceType == type)
        .toList();
  }

  Future<int> favoriteCount() async {
    return _box.values
        .where((e) => e.isFavorite)
        .length;
  }

  Future<void> updateFavorite(String id, bool value) async {
    final item = _box.get(id);

    if (item == null) return;

    await _box.put(
      id,
      item.copyWith(
        isFavorite: value,
      ),
    );
  }

  Future<void> increasePlayCount(String id) async {
    final item = _box.get(id);

    if (item == null) return;

    await _box.put(
      id,
      item.copyWith(
        playCount: item.playCount + 1,
        lastPlayed: DateTime.now(),
      ),
    );
  }
}