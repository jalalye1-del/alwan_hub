// lib/core/recording/repositories/recording_repository.dart

import 'package:alwan_hub/core/recording/models/recording_file.dart';

/// واجهة إدارة التسجيلات.[cite: 15]
///
/// هذه الطبقة مسؤولة عن:[cite: 15]
/// - إدارة قاعدة البيانات (Hive / Isar / SQLite)[cite: 15]
/// - التنسيق مع StorageService لإدارة الملفات[cite: 15]
/// - فهرسة التسجيلات[cite: 15]
/// - البحث والتصفية[cite: 15]
abstract interface class RecordingRepository {
  // ---------------------------------------------------------------------------
  // القراءة
  // ---------------------------------------------------------------------------

  /// جميع التسجيلات.[cite: 15]
  Future<List<RecordingFile>> getAllRecordings();

  /// تسجيل بواسطة المعرف.[cite: 15]
  Future<RecordingFile?> getRecordingById(String id);

  /// التسجيلات الأخيرة.[cite: 15]
  Future<List<RecordingFile>> getRecentRecordings({
    int limit = 20,
  });

  /// المفضلة.[cite: 15]
  Future<List<RecordingFile>> getFavoriteRecordings();

  /// حسب التصنيف.[cite: 15]
  Future<List<RecordingFile>> getRecordingsByCategory(
    String category,
  );

  /// حسب المجلد.[cite: 15]
  Future<List<RecordingFile>> getRecordingsByFolder(
    String folderName,
  );

  /// البحث.[cite: 15]
  Future<List<RecordingFile>> searchRecordings(
    String query,
  );

  // ---------------------------------------------------------------------------
  // الكتابة
  // ---------------------------------------------------------------------------

  /// إضافة تسجيل جديد.[cite: 15]
  Future<void> saveRecording(
    RecordingFile recording,
  );

  /// تحديث بيانات تسجيل.[cite: 15]
  Future<void> updateRecording(
    RecordingFile recording,
  );

  /// إعادة التسمية.[cite: 15]
  Future<void> renameRecording(
    String id,
    String newTitle,
  );

  /// نقل التسجيل إلى مجلد آخر.[cite: 15]
  Future<void> moveRecording({
    required String id,
    required String destinationFolder,
  });

  /// تفعيل أو إلغاء المفضلة.[cite: 15]
  Future<void> toggleFavorite(
    String id,
  );

  // ---------------------------------------------------------------------------
  // الحذف
  // ---------------------------------------------------------------------------

  /// حذف تسجيل واحد.[cite: 15]
  ///
  /// يجب حذف:[cite: 15]
  /// - الملف من التخزين.[cite: 15]
  /// - السجل من قاعدة البيانات.[cite: 15]
  Future<void> deleteRecording(
    String id,
  );

  /// حذف عدة تسجيلات.[cite: 15]
  Future<void> deleteRecordings(
    List<String> ids,
  );

  /// حذف جميع التسجيلات.[cite: 15]
  ///
  /// يجب حذف الملفات وقاعدة البيانات معًا.[cite: 15]
  Future<void> clearAll();

  // ---------------------------------------------------------------------------
  // أدوات
  // ---------------------------------------------------------------------------

  /// إعادة فهرسة التسجيلات الموجودة على الجهاز.[cite: 15]
  Future<void> refreshLibrary();

  /// عدد التسجيلات.[cite: 15]
  Future<int> count();

  /// الحجم الكلي لجميع التسجيلات.[cite: 15]
  Future<int> totalSize();
}