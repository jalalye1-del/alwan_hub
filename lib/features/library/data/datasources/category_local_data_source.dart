import '../models/library_category_model.dart';

abstract class LibraryCategoryLocalDataSource {
  /// مراقبة جميع التصنيفات
  Stream<List<LibraryCategoryModel>> watchCategories();

  /// قراءة جميع التصنيفات
  Future<List<LibraryCategoryModel>> getCategories();

  /// حفظ تصنيف
  Future<void> saveCategory(LibraryCategoryModel category);

  /// حذف تصنيف
  Future<void> deleteCategory(String id);

  /// حذف جميع التصنيفات
  Future<void> clearCategories();

  /// التحقق من وجود تصنيف
  Future<bool> categoryExists(String id);
}
