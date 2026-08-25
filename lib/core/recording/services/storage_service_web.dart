import 'package:alwan_hub/core/recording/models/recording_file.dart';
import 'package:alwan_hub/core/recording/services/storage_service.dart';

final class WebStorageService implements StorageService {
  @override
  Future<void> initialize() async {}

  @override
  Future<String> generateRecordingFilePath({
    required String category,
    required String folderName,
    String extension = 'mp3',
  }) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'web-recording-$timestamp.$extension';
  }

  @override
  Future<bool> fileExists(String path) async => false;

  @override
  Future<int> fileSize(String path) async => 0;

  @override
  Future<void> deleteRecording(String filePath) async {}

  @override
  Future<String> renameRecording(RecordingFile recording, String newTitle) async {
    throw UnsupportedError('إدارة ملفات التسجيل غير متاحة على الويب حالياً.');
  }

  @override
  Future<String> moveRecording({
    required RecordingFile recording,
    required String destinationFolder,
  }) async {
    throw UnsupportedError('إدارة ملفات التسجيل غير متاحة على الويب حالياً.');
  }

  @override
  Future<String> copyRecording({
    required RecordingFile recording,
    required String destinationFolder,
  }) async {
    throw UnsupportedError('إدارة ملفات التسجيل غير متاحة على الويب حالياً.');
  }

  @override
  Future<void> createFolder(String path) async {}

  @override
  Future<void> deleteFolder(String path) async {}

  @override
  Future<List<String>> getFolders() async => const [];

  @override
  Future<void> refreshLibrary() async {}

  @override
  Future<void> scanFile(String filePath) async {}

  @override
  Future<void> shareRecording(RecordingFile recording) async {
    throw UnsupportedError('مشاركة التسجيلات غير متاحة على الويب حالياً.');
  }

  @override
  Future<int> totalStorageUsed() async => 0;

  @override
  Future<int> availableStorage() async => 0;

  @override
  Future<void> cleanOrphanFiles() async {}

  @override
  Future<void> rebuildIndex() async {}
}
