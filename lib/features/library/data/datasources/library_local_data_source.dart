import '../models/library_item_model.dart';

abstract class LibraryLocalDataSource {
  /// جميع العناصر
  Future<List<LibraryItemModel>> getItems();

  /// عنصر واحد
  Future<LibraryItemModel?> getItem(String id);

  /// مراقبة العناصر
  Stream<List<LibraryItemModel>> watchItems();

  /// حفظ عنصر
  Future<void> saveItem(LibraryItemModel item);

  /// تحديث عنصر
  Future<void> updateItem(LibraryItemModel item);

  /// حذف عنصر
  Future<void> deleteItem(String itemId);

  /// التحقق من وجود العنصر
  Future<bool> exists(String id);

  /// حذف جميع العناصر
  Future<void> clearItems();
}
