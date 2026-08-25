import '../entities/library_item.dart';
import '../entities/user_folder.dart';
import '../entities/folder_type.dart';

abstract class LibraryRepository {
  // =========================
  // Library Items
  // =========================

  Stream<List<LibraryItem>> watchItems();

  Future<List<LibraryItem>> getItems();

  Future<LibraryItem?> getItem(String id);

  Future<void> saveItem(LibraryItem item);

  Future<void> updateItem(LibraryItem item);

  Future<void> deleteItem(String id);

  Future<void> clearItems();

  // =========================
  // User Folders
  // =========================

  Stream<List<UserFolder>> watchFolders();

  Future<List<UserFolder>> getFolders();

  Future<UserFolder?> getFolder(String id);

  Future<UserFolder> createFolder({
    required String name,
    required FolderType type,
  });

  Future<void> renameFolder({
    required String folderId,
    required String newName,
  });

  Future<void> deleteFolder(String folderId);

  Future<bool> folderExists(String id);

  // =========================
  // Folder Items
  // =========================

  // تم التعديل لإرجاع LibraryItem بدلاً من FolderItem
  Future<List<LibraryItem>> getFolderItems(String folderId);

  // تم التعديل لإرجاع LibraryItem بدلاً من FolderItem
  Stream<List<LibraryItem>> watchFolderItems(String folderId);

  Future<void> addItemToFolder({
    required String folderId,
    required String itemId,
  });

  Future<void> removeItemFromFolder({
    required String folderId,
    required String itemId,
  });

  Future<void> moveItem({
    required String fromFolderId,
    required String toFolderId,
    required String itemId,
  });
}
