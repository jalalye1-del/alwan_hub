import 'package:hive/hive.dart';
import '../models/folder_item_model.dart';
import 'folder_item_local_data_source.dart';

class FolderItemLocalDataSourceImpl implements FolderItemLocalDataSource {
  static const String boxName = 'folder_items_box';
  final Box<FolderItemModel> folderItemBox;

  FolderItemLocalDataSourceImpl({required this.folderItemBox});

  @override
  Future<List<FolderItemModel>> getFolderItems(String folderId) async {
    return folderItemBox.values
        .where((item) => item.folderId == folderId)
        .toList();
  }

  @override
  Stream<List<FolderItemModel>> watchFolderItems(String folderId) async* {
    yield folderItemBox.values
        .where((item) => item.folderId == folderId)
        .toList();

    yield* folderItemBox.watch().map(
      (_) => folderItemBox.values
          .where((item) => item.folderId == folderId)
          .toList(),
    );
  }

  @override
  Future<void> addItem(FolderItemModel item) async {
    await folderItemBox.put(item.id, item);
  }

  @override
  Future<void> removeItem({
    required String folderId,
    required String itemId,
  }) async {
    final relation = folderItemBox.values.firstWhere(
      (e) => e.folderId == folderId && e.itemId == itemId,
    );

    await relation.delete();
  }

  @override
  Future<void> moveItem({
    required String fromFolderId,
    required String toFolderId,
    required String itemId,
  }) async {
    final relation = folderItemBox.values.firstWhere(
      (e) => e.folderId == fromFolderId && e.itemId == itemId,
    );

    // إنشاء نسخة جديدة بالبيانات المحدثة لتجاوز خطأ التعديل على حقل Final
    final updatedRelation = FolderItemModel(
      id: relation.id,
      folderId: toFolderId,
      itemId: relation.itemId,
      addedAt: relation.addedAt,
    );

    await folderItemBox.put(updatedRelation.id, updatedRelation);
  }

  @override
  Future<bool> exists({
    required String folderId,
    required String itemId,
  }) async {
    return folderItemBox.values.any(
      (e) => e.folderId == folderId && e.itemId == itemId,
    );
  }

  @override
  Future<void> clearFolder(String folderId) async {
    final items = folderItemBox.values
        .where((e) => e.folderId == folderId)
        .toList();

    for (final item in items) {
      await item.delete();
    }
  }

  @override
  Future<void> clear() async {
    await folderItemBox.clear();
  }
}
