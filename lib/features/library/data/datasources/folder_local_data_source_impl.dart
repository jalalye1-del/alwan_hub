import 'package:hive/hive.dart';
import '../models/user_folder_model.dart';
import 'folder_local_data_source.dart'; // هذا الاستيراد مهم جداً الآن

class FolderLocalDataSourceImpl implements FolderLocalDataSource {
  static const String boxName = 'user_folders_box';

  final Box<UserFolderModel> folderBox;

  FolderLocalDataSourceImpl({required this.folderBox});

  @override
  Future<List<UserFolderModel>> getFolders() async {
    return folderBox.values.toList();
  }

  @override
  Future<UserFolderModel?> getFolderById(String id) async {
    return folderBox.get(id);
  }

  @override
  Stream<List<UserFolderModel>> watchFolders() async* {
    yield folderBox.values.toList();
    yield* folderBox.watch().map((_) => folderBox.values.toList());
  }

  @override
  Future<void> saveFolder(UserFolderModel folder) async {
    await folderBox.put(folder.id, folder);
  }

  @override
  Future<void> updateFolder(UserFolderModel folder) async {
    await folderBox.put(folder.id, folder);
  }

  @override
  Future<void> deleteFolder(String folderId) async {
    await folderBox.delete(folderId);
  }

  @override
  Future<bool> folderExists(String id) async {
    return folderBox.containsKey(id);
  }

  @override
  Future<void> clearFolders() async {
    await folderBox.clear();
  }
}
