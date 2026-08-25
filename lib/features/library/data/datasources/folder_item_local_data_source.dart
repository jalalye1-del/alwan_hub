import '../models/folder_item_model.dart';

abstract class FolderItemLocalDataSource {
  /// جميع عناصر مجلد معين
  Future<List<FolderItemModel>> getFolderItems(String folderId);

  /// مراقبة عناصر مجلد معين
  Stream<List<FolderItemModel>> watchFolderItems(String folderId);

  /// إضافة عنصر إلى مجلد
  Future<void> addItem(FolderItemModel item);

  /// حذف عنصر من مجلد
  Future<void> removeItem({required String folderId, required String itemId});

  /// نقل عنصر بين مجلدين
  Future<void> moveItem({
    required String fromFolderId,
    required String toFolderId,
    required String itemId,
  });

  /// التحقق من وجود الربط
  Future<bool> exists({required String folderId, required String itemId});

  /// حذف جميع عناصر مجلد
  Future<void> clearFolder(String folderId);

  /// حذف جميع العلاقات
  Future<void> clear();
}
