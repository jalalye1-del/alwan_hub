import '../../domain/entities/library_category.dart';
import '../../domain/repositories/library_category_repository.dart';

import '../datasources/category_local_data_source.dart';
import '../models/library_category_model.dart';

class CategoryRepositoryImpl implements LibraryCategoryRepository {
  final LibraryCategoryLocalDataSource _localDataSource;
  CategoryRepositoryImpl(this._localDataSource);

  @override
  Stream<List<LibraryCategory>> watchCategories() {
    return _localDataSource.watchCategories().map(
      (models) => models.map((e) => e.toEntity()).toList(),
    );
  }

  @override
  Future<List<LibraryCategory>> getCategories() async {
    final models = await _localDataSource.getCategories();

    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<LibraryCategory?> getCategory(String id) async {
    final categories = await getCategories();

    try {
      return categories.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LibraryCategory>> getRootCategories() async {
    final categories = await getCategories();

    return categories.where((e) => e.parentId == null).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Future<List<LibraryCategory>> getChildren(String parentId) async {
    final categories = await getCategories();

    return categories.where((e) => e.parentId == parentId).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Future<void> saveCategory(LibraryCategory category) async {
    await _localDataSource.saveCategory(
      LibraryCategoryModel.fromEntity(category),
    );
  }

  @override
  Future<void> updateCategory(LibraryCategory category) async {
    await saveCategory(category);
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _localDataSource.deleteCategory(id);
  }

  @override
  Future<bool> exists(String id) {
    return _localDataSource.categoryExists(id);
  }

  @override
  Future<void> clear() async {
    await _localDataSource.clearCategories();
  }
}
