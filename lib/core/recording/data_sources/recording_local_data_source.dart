import 'package:alwan_hub/core/recording/models/recording_file.dart';

/// طبقة الوصول المحلية لقاعدة البيانات.
///
/// مسؤولة فقط عن القراءة والكتابة في Hive.
/// لا تحتوي على أي منطق أعمال ولا تتعامل مع الملفات.
abstract interface class RecordingLocalDataSource {
  // ---------------------------------------------------------------------------
  // القراءة
  // ---------------------------------------------------------------------------

  Future<List<RecordingFile>> getAll();

  Future<RecordingFile?> getById(String id);

  Future<List<RecordingFile>> getFavorites();

  Future<List<RecordingFile>> getByCategory(String category);

  Future<List<RecordingFile>> getByFolder(String folderName);

  Future<List<RecordingFile>> search(String query);

  // ---------------------------------------------------------------------------
  // الكتابة
  // ---------------------------------------------------------------------------

  Future<void> save(RecordingFile recording);

  Future<void> update(RecordingFile recording);

  Future<void> saveAll(List<RecordingFile> recordings);

  // ---------------------------------------------------------------------------
  // الحذف
  // ---------------------------------------------------------------------------

  Future<void> delete(String id);

  Future<void> deleteAll(List<String> ids);

  Future<void> clear();

  // ---------------------------------------------------------------------------
  // الأدوات
  // ---------------------------------------------------------------------------

  Future<bool> exists(String id);

  Future<int> count();

  Future<void> compact();

  Future<void> close();
}