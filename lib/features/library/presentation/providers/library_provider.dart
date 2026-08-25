import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../core/library_initializer.dart';
import '../../data/datasources/library_local_data_source.dart';
import '../../data/datasources/library_local_data_source_impl.dart';
import '../../data/datasources/folder_local_data_source.dart';
import '../../data/datasources/folder_local_data_source_impl.dart';
import '../../data/datasources/folder_item_local_data_source.dart';
import '../../data/datasources/folder_item_local_data_source_impl.dart';
import '../../data/datasources/category_local_data_source.dart';
import '../../data/datasources/category_local_data_source_impl.dart';

import '../../data/models/library_item_model.dart';
import '../../data/models/user_folder_model.dart';
import '../../data/models/folder_item_model.dart';
import '../../data/models/library_category_model.dart';

// استخدام مسارات نسبية لتقليل التعارضات وتجنب Ambiguous Import
import '../../data/repositorys/library_repository_impl.dart';
import '../../data/repositorys/category_repository_impl.dart';

import '../../domain/repositories/library_repository.dart';
import '../../domain/repositories/library_category_repository.dart';
import '../../domain/entities/library_item.dart';
import '../../domain/entities/library_category.dart';
import '../../domain/entities/folder_type.dart'; // تمت الإضافة لدعم FolderType
import '../../domain/entities/user_folder.dart'; // التنفيذ (2): إضافة استيراد المجلد

final libraryLocalDataSourceProvider = Provider<LibraryLocalDataSource>((ref) {
  return LibraryLocalDataSourceImpl(
    itemBox: Hive.box<LibraryItemModel>(LibraryLocalDataSourceImpl.boxName),
  );
});

final folderLocalDataSourceProvider = Provider<FolderLocalDataSource>((ref) {
  return FolderLocalDataSourceImpl(
    folderBox: Hive.box<UserFolderModel>(FolderLocalDataSourceImpl.boxName),
  );
});

final folderItemLocalDataSourceProvider = Provider<FolderItemLocalDataSource>((
  ref,
) {
  return FolderItemLocalDataSourceImpl(
    folderItemBox: Hive.box<FolderItemModel>(
      FolderItemLocalDataSourceImpl.boxName,
    ),
  );
});

final categoryLocalDataSourceProvider =
    Provider<LibraryCategoryLocalDataSource>((ref) {
      return CategoryLocalDataSourceImpl(
        categoryBox: Hive.box<LibraryCategoryModel>(
          CategoryLocalDataSourceImpl.boxName,
        ),
      );
    });

final libraryCategoryRepositoryProvider = Provider<LibraryCategoryRepository>((
  ref,
) {
  final dataSource = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(dataSource);
});

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  // تمرير المعاملات بالترتيب (Positional) لحل خطأ not_enough_positional_arguments
  return LibraryRepositoryImpl(
    ref.watch(libraryLocalDataSourceProvider),
    ref.watch(folderLocalDataSourceProvider),
    ref.watch(folderItemLocalDataSourceProvider),
  );
});

final libraryInitializerProvider = Provider<LibraryInitializer>((ref) {
  final categoryRepository = ref.watch(libraryCategoryRepositoryProvider);
  return LibraryInitializer(categoryRepository);
});

// التنفيذ (1): تحديد النوع بدقة للـ StreamProvider
final libraryItemsProvider = StreamProvider<List<LibraryItem>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchItems();
});

// التنفيذ (1): تحديد النوع بدقة للـ StreamProvider
final libraryFoldersProvider = StreamProvider<List<UserFolder>>((ref) {
  return ref.watch(libraryRepositoryProvider).watchFolders();
});

final libraryCategoriesProvider = StreamProvider<List<LibraryCategory>>((ref) {
  final repository = ref.watch(libraryCategoryRepositoryProvider);
  return repository.watchCategories();
});

final libraryActionsProvider = Provider((ref) {
  final repository = ref.watch(libraryRepositoryProvider);
  return LibraryActions(repository);
});

class LibraryActions {
  final LibraryRepository _repository;

  LibraryActions(this._repository);

  // التنفيذ (3): جعل الدالة تعيد قيمة المجلد
  Future<UserFolder> createFolder({
    required String name,
    required FolderType type,
  }) async {
    return await _repository.createFolder(name: name, type: type);
  }

  Future<void> saveItem(LibraryItem item) async {
    await _repository.saveItem(item);
  }

  Future<void> addItemToFolder({
    required String folderId,
    required String itemId,
  }) async {
    await _repository.addItemToFolder(folderId: folderId, itemId: itemId);
  }
}
