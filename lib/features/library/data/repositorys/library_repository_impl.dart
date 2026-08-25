import 'package:uuid/uuid.dart';

import '../../domain/repositories/library_repository.dart';
import '../../domain/entities/library_item.dart';
import '../../domain/entities/user_folder.dart';
import '../../domain/entities/folder_type.dart';

import '../datasources/library_local_data_source.dart';
import '../datasources/folder_local_data_source.dart';
import '../datasources/folder_item_local_data_source.dart';

import '../models/library_item_model.dart';
import '../models/user_folder_model.dart';
import '../models/folder_item_model.dart';

class LibraryRepositoryImpl implements LibraryRepository {
  final LibraryLocalDataSource libraryLocalDataSource;
  final FolderLocalDataSource folderLocalDataSource;
  final FolderItemLocalDataSource folderItemLocalDataSource;

  LibraryRepositoryImpl(
    this.libraryLocalDataSource,
    this.folderLocalDataSource,
    this.folderItemLocalDataSource,
  );

  // ==========================================
  // 1. عمليات العناصر (Library Items)
  // ==========================================

  @override
  Stream<List<LibraryItem>> watchItems() {
    return libraryLocalDataSource.watchItems().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<List<LibraryItem>> getItems() async {
    final models = await libraryLocalDataSource.getItems();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<LibraryItem?> getItem(String id) async {
    final model = await libraryLocalDataSource.getItem(id);
    return model?.toEntity();
  }

  @override
  Future<void> saveItem(LibraryItem item) async {
    final model = LibraryItemModel.fromEntity(item);
    await libraryLocalDataSource.saveItem(model);
  }

  @override
  Future<void> updateItem(LibraryItem item) async {
    final model = LibraryItemModel.fromEntity(item);
    await libraryLocalDataSource.updateItem(model);
  }

  @override
  Future<void> deleteItem(String id) async {
    await libraryLocalDataSource.deleteItem(id);
  }

  @override
  Future<void> clearItems() async {
    await libraryLocalDataSource.clearItems();
  }

  // ==========================================
  // 2. عمليات المجلدات (Folders)
  // ==========================================

  @override
  Stream<List<UserFolder>> watchFolders() {
    return folderLocalDataSource.watchFolders().map(
      (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<List<UserFolder>> getFolders() async {
    final models = await folderLocalDataSource.getFolders();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<UserFolder?> getFolder(String id) async {
    final model = await folderLocalDataSource.getFolderById(id);
    return model?.toEntity();
  }

  @override
  Future<UserFolder> createFolder({
    required String name,
    required FolderType type,
  }) async {
    final folder = UserFolder(
      id: const Uuid().v4(),
      name: name,
      type: type,
      createdAt: DateTime.now(),
    );

    await folderLocalDataSource.saveFolder(UserFolderModel.fromEntity(folder));

    return folder;
  }

  @override
  Future<void> renameFolder({
    required String folderId,
    required String newName,
  }) async {
    final folder = await folderLocalDataSource.getFolderById(folderId);

    if (folder == null) return;

    await folderLocalDataSource.updateFolder(folder.copyWith(name: newName));
  }

  @override
  Future<void> deleteFolder(String folderId) async {
    // حذف جميع العلاقات أولاً
    await folderItemLocalDataSource.clearFolder(folderId);
    // ثم حذف المجلد
    await folderLocalDataSource.deleteFolder(folderId);
  }

  @override
  Future<bool> folderExists(String id) async {
    return await folderLocalDataSource.folderExists(id);
  }

  // ==========================================
  // 3. عمليات العلاقات (Folder Items)
  // ==========================================

  @override
  Future<List<LibraryItem>> getFolderItems(String folderId) async {
    // جلب جميع العلاقات الخاصة بالمجلد
    final relations = await folderItemLocalDataSource.getFolderItems(folderId);
    final List<LibraryItem> items = [];

    // جلب تفاصيل كل عنصر بناءً على itemId
    for (final rel in relations) {
      final itemModel = await libraryLocalDataSource.getItem(rel.itemId);
      if (itemModel != null) {
        items.add(itemModel.toEntity());
      }
    }

    return items;
  }

  @override
  Stream<List<LibraryItem>> watchFolderItems(String folderId) {
    // استخدام asyncMap للتمكن من جلب تفاصيل العناصر مع كل تحديث للـ Stream
    return folderItemLocalDataSource.watchFolderItems(folderId).asyncMap((
      relations,
    ) async {
      final List<LibraryItem> items = [];
      for (final rel in relations) {
        final itemModel = await libraryLocalDataSource.getItem(rel.itemId);
        if (itemModel != null) {
          items.add(itemModel.toEntity());
        }
      }
      return items;
    });
  }

  @override
  Future<void> addItemToFolder({
    required String folderId,
    required String itemId,
  }) async {
    final alreadyExists = await folderItemLocalDataSource.exists(
      folderId: folderId,
      itemId: itemId,
    );

    if (alreadyExists) {
      return;
    }

    final relation = FolderItemModel(
      id: '${folderId}_$itemId',
      folderId: folderId,
      itemId: itemId,
      addedAt: DateTime.now(),
    );

    await folderItemLocalDataSource.addItem(relation);
  }

  @override
  Future<void> removeItemFromFolder({
    required String folderId,
    required String itemId,
  }) async {
    await folderItemLocalDataSource.removeItem(
      folderId: folderId,
      itemId: itemId,
    );
  }

  @override
  Future<void> moveItem({
    required String fromFolderId,
    required String toFolderId,
    required String itemId,
  }) async {
    await folderItemLocalDataSource.moveItem(
      fromFolderId: fromFolderId,
      toFolderId: toFolderId,
      itemId: itemId,
    );
  }
}
