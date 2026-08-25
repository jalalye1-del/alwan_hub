import 'package:hive/hive.dart'; //[cite: 5]
import '../models/library_category_model.dart'; //[cite: 5]
import 'category_local_data_source.dart'; //[cite: 5]

class CategoryLocalDataSourceImpl implements LibraryCategoryLocalDataSource {
  //[cite: 5]
  static const boxName = 'library_categories'; //[cite: 5]
  final Box<LibraryCategoryModel> categoryBox; //[cite: 5]

  CategoryLocalDataSourceImpl({required this.categoryBox}); //[cite: 5]

  @override
  Stream<List<LibraryCategoryModel>> watchCategories() {
    return categoryBox.watch().map((_) {
      final list = categoryBox.values.toList();

      list.sort((a, b) => a.order.compareTo(b.order));

      return list;
    });
  } //[cite: 5]

  @override
  Future<List<LibraryCategoryModel>> getCategories() async {
    final list = categoryBox.values.toList(); //[cite: 5]

    list.sort((a, b) => a.order.compareTo(b.order)); //[cite: 5]

    return list; //[cite: 5]
  }

  @override
  Future<void> saveCategory(LibraryCategoryModel category) async {
    await categoryBox.put(category.id, category); //[cite: 5]
  }

  @override
  Future<void> deleteCategory(String id) async {
    await categoryBox.delete(id); //[cite: 5]
  }

  @override
  Future<void> clearCategories() async {
    await categoryBox.clear(); //[cite: 5]
  }

  @override
  Future<bool> categoryExists(String id) async {
    return categoryBox.containsKey(id); //[cite: 5]
  }
}
