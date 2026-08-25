import '../entities/library_category.dart';

abstract class LibraryCategoryRepository {
  /// جميع التصنيفات
  Stream<List<LibraryCategory>> watchCategories();

  Future<List<LibraryCategory>> getCategories();

  /// تصنيف واحد
  Future<LibraryCategory?> getCategory(String id);

  /// التصنيفات الرئيسية
  Future<List<LibraryCategory>> getRootCategories();

  /// التصنيفات الفرعية
  Future<List<LibraryCategory>> getChildren(String parentId);

  /// حفظ
  Future<void> saveCategory(LibraryCategory category);

  /// تحديث
  Future<void> updateCategory(LibraryCategory category);

  /// حذف
  Future<void> deleteCategory(String id);

  /// التحقق من وجود التصنيف
  Future<bool> exists(String id);

  /// حذف جميع التصنيفات
  Future<void> clear();
}
