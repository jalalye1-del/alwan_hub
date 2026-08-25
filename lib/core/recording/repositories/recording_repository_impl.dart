// lib/core/recording/repositories/recording_repository_impl.dart

import 'package:path/path.dart' as path;

import 'package:alwan_hub/core/recording/data_sources/recording_local_data_source.dart';
import 'package:alwan_hub/core/recording/models/recording_file.dart';
import 'package:alwan_hub/core/recording/repositories/recording_repository.dart';
import 'package:alwan_hub/core/recording/services/storage_service.dart';

final class RecordingRepositoryImpl implements RecordingRepository {
  final RecordingLocalDataSource localDataSource;
  final StorageService storageService;

  RecordingRepositoryImpl({
    required this.localDataSource,
    required this.storageService,
  });

  // ---------------------------------------------------------------------------
  // القراءة
  // ---------------------------------------------------------------------------

  @override
  Future<List<RecordingFile>> getAllRecordings() async {
    return localDataSource.getAll();
  }

  @override
  Future<RecordingFile?> getRecordingById(String id) {
    return localDataSource.getById(id);
  }

  @override
  Future<List<RecordingFile>> getRecentRecordings({
    int limit = 20,
  }) async {
    final recordings = await localDataSource.getAll();
    return recordings.take(limit).toList();
  }

  @override
  Future<List<RecordingFile>> getFavoriteRecordings() {
    return localDataSource.getFavorites();
  }

  @override
  Future<List<RecordingFile>> getRecordingsByCategory(
    String category,
  ) {
    return localDataSource.getByCategory(category);
  }

  @override
  Future<List<RecordingFile>> getRecordingsByFolder(
    String folderName,
  ) {
    return localDataSource.getByFolder(folderName);
  }

  @override
  Future<List<RecordingFile>> searchRecordings(
    String query,
  ) {
    return localDataSource.search(query);
  }

  // ---------------------------------------------------------------------------
  // الكتابة
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveRecording(
    RecordingFile recording,
  ) {
    return localDataSource.save(recording);
  }

  @override
  Future<void> updateRecording(
    RecordingFile recording,
  ) {
    return localDataSource.update(recording);
  }

  @override
  Future<void> renameRecording(
    String id,
    String newTitle,
  ) async {
    final recording = await getRecordingById(id);

    if (recording == null) {
      return;
    }

    final newPath = await storageService.renameRecording(
      recording,
      newTitle,
    );

    final updated = recording.copyWith(
      title: newTitle,
      filePath: newPath,
      fileName: path.basename(newPath),
    );

    await localDataSource.update(updated);
  }

  @override
  Future<void> moveRecording({
    required String id,
    required String destinationFolder,
  }) async {
    final recording = await getRecordingById(id);

    if (recording == null) {
      return;
    }

    final newPath = await storageService.moveRecording(
      recording: recording,
      destinationFolder: destinationFolder,
    );

    final updated = recording.copyWith(
      folderName: destinationFolder,
      filePath: newPath,
      fileName: path.basename(newPath),
    );

    await localDataSource.update(updated);
  }

  @override
  Future<void> toggleFavorite(
    String id,
  ) async {
    final recording = await getRecordingById(id);

    if (recording == null) {
      return;
    }

    final updated = recording.copyWith(
      isFavorite: !recording.isFavorite,
    );

    await localDataSource.update(updated);
  }

  // ---------------------------------------------------------------------------
  // الحذف
  // ---------------------------------------------------------------------------

  @override
  Future<void> deleteRecording(
    String id,
  ) async {
    final recording = await getRecordingById(id);

    if (recording == null) {
      return;
    }

    await storageService.deleteRecording(
      recording.filePath,
    );

    await localDataSource.delete(id);
  }

  @override
  Future<void> deleteRecordings(
    List<String> ids,
  ) async {
    await Future.wait(ids.map(deleteRecording));
  }

  @override
  Future<void> clearAll() async {
    final recordings = await localDataSource.getAll();

    await Future.wait(
      recordings.map((r) => storageService.deleteRecording(r.filePath))
    );

    await localDataSource.clear();
  }

  // ---------------------------------------------------------------------------
  // أدوات
  // ---------------------------------------------------------------------------

  @override
  Future<void> refreshLibrary() async {
    await storageService.refreshLibrary();
  }

  @override
  Future<int> count() {
    return localDataSource.count();
  }

  @override
  Future<int> totalSize() async {
    final recordings = await localDataSource.getAll();

    var total = 0;

    for (final recording in recordings) {
      total += recording.fileSize;
    }

    return total;
  }
}
