import 'package:hive_flutter/hive_flutter.dart';

import 'package:alwan_hub/features/library/data/datasources/library_local_data_source_impl.dart';
import 'package:alwan_hub/features/library/data/datasources/folder_local_data_source_impl.dart';
import 'package:alwan_hub/features/library/data/datasources/folder_item_local_data_source_impl.dart';
import 'package:alwan_hub/features/library/data/datasources/category_local_data_source_impl.dart';

import 'package:alwan_hub/features/library/data/models/library_item_model.dart';
import 'package:alwan_hub/features/library/data/models/user_folder_model.dart';
import 'package:alwan_hub/features/library/data/models/folder_item_model.dart';
import 'package:alwan_hub/features/library/data/models/library_category_model.dart';
import 'package:alwan_hub/core/recording/data_sources/hive_recording_local_data_source.dart';
import 'package:alwan_hub/core/recording/models/recording_file.dart';

class HiveService {
  static const recordingFoldersBoxName = 'recording_folders';

  static Future<void> init() async {
    await Hive.initFlutter();
    
    _registerAdapters();
    await _openBoxes();
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(LibraryItemModelAdapter());
    }

    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(UserFolderModelAdapter());
    }

    if (!Hive.isAdapterRegistered(22)) {
      Hive.registerAdapter(FolderItemModelAdapter());
    }

    if (!Hive.isAdapterRegistered(23)) {
      Hive.registerAdapter(LibraryCategoryModelAdapter());
    }

    if (!Hive.isAdapterRegistered(RecordingSourceTypeAdapter().typeId)) {
      Hive.registerAdapter(RecordingSourceTypeAdapter());
    }

    if (!Hive.isAdapterRegistered(RecordingStatusAdapter().typeId)) {
      Hive.registerAdapter(RecordingStatusAdapter());
    }

    if (!Hive.isAdapterRegistered(RecordingFileAdapter().typeId)) {
      Hive.registerAdapter(RecordingFileAdapter());
    }
  }

  static Future<void> _openBoxes() async {
    // تم استخدام الثوابت من الـ DataSources مباشرة لفتح الصناديق
    await Hive.openBox<LibraryItemModel>(LibraryLocalDataSourceImpl.boxName);
    await Hive.openBox<UserFolderModel>(FolderLocalDataSourceImpl.boxName);
    await Hive.openBox<FolderItemModel>(FolderItemLocalDataSourceImpl.boxName);
    await Hive.openBox<LibraryCategoryModel>(CategoryLocalDataSourceImpl.boxName);
    await Hive.openBox<RecordingFile>(HiveRecordingLocalDataSource.boxName);
    await Hive.openBox<String>(recordingFoldersBoxName);
  }

  static Future<void> clearAll() async {
    await Hive.box<LibraryItemModel>(LibraryLocalDataSourceImpl.boxName).clear();
    await Hive.box<UserFolderModel>(FolderLocalDataSourceImpl.boxName).clear();
    await Hive.box<FolderItemModel>(FolderItemLocalDataSourceImpl.boxName).clear();
    await Hive.box<LibraryCategoryModel>(CategoryLocalDataSourceImpl.boxName).clear();
    await Hive.box<RecordingFile>(HiveRecordingLocalDataSource.boxName).clear();
    await Hive.box<String>(recordingFoldersBoxName).clear();
  }
}
