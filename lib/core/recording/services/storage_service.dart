import 'package:alwan_hub/core/recording/models/recording_file.dart';

/// خدمة مسؤولة عن إدارة الملفات والمجلدات.
///
/// لا تتعامل مع قاعدة البيانات.
/// مسؤوليتها الوحيدة هي الملفات الموجودة على الجهاز.
abstract interface class StorageService {
  // ---------------------------------------------------------------------------
  // إنشاء المسارات
  // ---------------------------------------------------------------------------

  /// إنشاء مجلد التسجيلات إذا لم يكن موجوداً.
  Future<void> initialize();

  /// إنشاء مسار كامل لتسجيل جديد.
  Future<String> generateRecordingFilePath({
    required String category,
    required String folderName,
    String extension = 'mp3',
  });

  // ---------------------------------------------------------------------------
  // الملفات
  // ---------------------------------------------------------------------------

  /// التحقق من وجود ملف.
  Future<bool> fileExists(String path);

  /// حجم الملف.
  Future<int> fileSize(String path);

  /// حذف ملف.
  Future<void> deleteRecording(
    String filePath,
  );

  /// إعادة تسمية ملف.
  Future<String> renameRecording(
    RecordingFile recording,
    String newTitle,
  );

  /// نقل ملف إلى مجلد آخر.
  Future<String> moveRecording({
    required RecordingFile recording,
    required String destinationFolder,
  });

  /// نسخ ملف.
  Future<String> copyRecording({
    required RecordingFile recording,
    required String destinationFolder,
  });

  // ---------------------------------------------------------------------------
  // المجلدات
  // ---------------------------------------------------------------------------

  /// إنشاء مجلد.
  Future<void> createFolder(
    String path,
  );

  /// حذف مجلد فارغ.
  Future<void> deleteFolder(
    String path,
  );

  /// جميع المجلدات.
  Future<List<String>> getFolders();

  // ---------------------------------------------------------------------------
  // Media Store
  // ---------------------------------------------------------------------------

  /// تحديث مكتبة الوسائط.
  Future<void> refreshLibrary();

  /// إعلام النظام بوجود ملف جديد.
  Future<void> scanFile(
    String filePath,
  );

  // ---------------------------------------------------------------------------
  // المشاركة
  // ---------------------------------------------------------------------------

  /// مشاركة تسجيل.
  Future<void> shareRecording(
    RecordingFile recording,
  );

  // ---------------------------------------------------------------------------
  // الإحصائيات
  // ---------------------------------------------------------------------------

  /// الحجم الكلي لمجلد التسجيلات.
  Future<int> totalStorageUsed();

  /// المساحة المتبقية.
  Future<int> availableStorage();

  // ---------------------------------------------------------------------------
  // الصيانة
  // ---------------------------------------------------------------------------

  /// حذف الملفات المفقودة من قاعدة البيانات.
  Future<void> cleanOrphanFiles();

  /// إعادة فهرسة مجلد التسجيلات.
  Future<void> rebuildIndex();
}
