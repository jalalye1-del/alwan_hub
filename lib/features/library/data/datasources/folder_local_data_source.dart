import '../models/user_folder_model.dart';

abstract class FolderLocalDataSource {
  Future<List<UserFolderModel>> getFolders();
  Future<UserFolderModel?> getFolderById(String id);
  Stream<List<UserFolderModel>> watchFolders();
  Future<void> saveFolder(UserFolderModel folder);
  Future<void> updateFolder(UserFolderModel folder);
  Future<void> deleteFolder(String folderId);
  Future<bool> folderExists(String id);
  Future<void> clearFolders();
}
