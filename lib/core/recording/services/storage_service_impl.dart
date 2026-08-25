// lib/core/recording/services/storage_service_impl.dart

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:alwan_hub/core/recording/models/recording_file.dart';
import 'package:alwan_hub/core/recording/services/storage_service.dart';

final class StorageServiceImpl implements StorageService {
  static const _rootFolder = 'Alwan Hub';
  static const _recordingsFolder = 'Recordings';

  @override
  Future<void> initialize() async {
    final root = await _rootDirectory();

    if (!await root.exists()) {
      await root.create(recursive: true);
    }
  }

  //==========================================================================
  // إنشاء المسارات
  //==========================================================================

  @override
  Future<String> generateRecordingFilePath({
    required String category,
    required String folderName,
    String extension = 'mp3',
  }) async {
    final root = await _rootDirectory();

    final directory = Directory(
      p.join(
        root.path,
        _recordingsFolder,
        _sanitize(category),
        _sanitize(folderName),
      ),
    );

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final now = DateTime.now();

    final fileName =
        '${_sanitize(folderName)} - '
        '${now.year}-${_two(now.month)}-${_two(now.day)} '
        '${_two(now.hour)}-${_two(now.minute)}-${_two(now.second)}.'
        '$extension';

    return p.join(directory.path, fileName);
  }

  //==========================================================================
  // الملفات
  //==========================================================================

  @override
  Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  @override
  Future<int> fileSize(String path) async {
    final file = File(path);

    if (!await file.exists()) {
      return 0;
    }

    return file.length();
  }

  @override
  Future<void> deleteRecording(String filePath) async {
    final file = File(filePath);

    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<String> renameRecording(
    RecordingFile recording,
    String newTitle,
  ) async {
    final file = File(recording.filePath);

    if (!await file.exists()) return recording.filePath;

    // استخراج الامتداد الأصلي للملف
    final extension = p.extension(recording.fileName);
    
    final newPath = p.join(
      file.parent.path,
      '${_sanitize(newTitle)}$extension', // إضافة الامتداد الأصلي وتنقيه الاسم
    );

    final renamed = await file.rename(newPath);
    return renamed.path;
  }

  @override
  Future<String> moveRecording({
    required RecordingFile recording,
    required String destinationFolder,
  }) async {
    final source = File(recording.filePath);

    final root = await _rootDirectory();

    final targetDirectory = Directory(
      p.join(
        root.path,
        _recordingsFolder,
        _sanitize(recording.category), // تنقية اسم التصنيف
        _sanitize(destinationFolder), // تنقية اسم المجلد
      ),
    );

    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }

    final newPath = p.join(
      targetDirectory.path,
      recording.fileName,
    );

    final moved = await source.rename(newPath);

    return moved.path;
  }

  @override
  Future<String> copyRecording({
    required RecordingFile recording,
    required String destinationFolder,
  }) async {
    final source = File(recording.filePath);

    final root = await _rootDirectory();

    final targetDirectory = Directory(
      p.join(
        root.path,
        _recordingsFolder,
        _sanitize(recording.category), // تنقية اسم التصنيف
        _sanitize(destinationFolder), // تنقية اسم المجلد
      ),
    );

    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }

    final newPath = p.join(
      targetDirectory.path,
      recording.fileName,
    );

    final copied = await source.copy(newPath);

    return copied.path;
  }

  //==========================================================================
  // المجلدات
  //==========================================================================

  @override
  Future<void> createFolder(String path) async {
    final directory = Directory(path);

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  @override
  Future<void> deleteFolder(String path) async {
    final directory = Directory(path);

    if (await directory.exists()) {
      // السماح بحذف المجلد ومحتوياته
      await directory.delete(recursive: true);
    }
  }

  @override
  Future<List<String>> getFolders() async {
    final root = await _rootDirectory();

    if (!await root.exists()) {
      return [];
    }

    return root
        .listSync()
        .whereType<Directory>()
        // استخراج اسم المجلد فقط
        .map((e) => p.basename(e.path))
        .toList();
  }

  //==========================================================================
  // Media
  //==========================================================================

  @override
  Future<void> refreshLibrary() async {
    // مستقبلاً: سيتم ربطها بـ MediaStore
  }

  @override
  Future<void> scanFile(String filePath) async {
    // مستقبلاً: Android MediaScanner
  }

  //==========================================================================
  // المشاركة
  //==========================================================================

  @override
  Future<void> shareRecording(
    RecordingFile recording,
  ) async {
    final file = XFile(recording.filePath);
    
    // ignore: deprecated_member_use
    await Share.shareXFiles([file], text: 'استمع إلى تسجيلي: ${recording.title}');
  }

  //==========================================================================
  // الإحصائيات
  //==========================================================================

  @override
  Future<int> totalStorageUsed() async {
    final root = await _rootDirectory();

    if (!await root.exists()) {
      return 0;
    }

    var total = 0;

    await for (final entity in root.list(recursive: true)) {
      if (entity is File) {
        total += await entity.length();
      }
    }

    return total;
  }

  @override
  Future<int> availableStorage() async {
    // مستقبلاً: سيتم استبدالها بحساب المساحة المتوفرة فعلياً 
    return 0;
  }

  //==========================================================================
  // الصيانة
  //==========================================================================

  @override
  Future<void> cleanOrphanFiles() async {
    // مستقبلاً: إضافة منطق للبحث عن الملفات المتبقية التي ليس لها قيود في قاعدة البيانات
  }

  @override
  Future<void> rebuildIndex() async {
    // مستقبلاً: إضافة منطق لإعادة بناء قاعدة البيانات بناءً على الملفات الموجودة في التخزين
  }

  //==========================================================================
  // Helpers
  //==========================================================================

  Future<Directory> _rootDirectory() async {
    final directory = await getApplicationDocumentsDirectory();

    return Directory(
      p.join(
        directory.path,
        _rootFolder,
      ),
    );
  }

  String _sanitize(String value) {
    return value
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .trim();
  }

  String _two(int value) {
    return value.toString().padLeft(2, '0');
  }
}
