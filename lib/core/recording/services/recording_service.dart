// lib/core/recording/services/recording_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import 'package:alwan_hub/core/recording/models/recording_file.dart';
import 'package:alwan_hub/core/recording/repositories/recording_repository.dart';
import 'package:alwan_hub/core/recording/services/recording_platform.dart';
import 'package:alwan_hub/core/recording/services/recording_types.dart';
import 'package:alwan_hub/core/recording/services/storage_service.dart';

// =========================================================================
// نموذج بيانات الجلسة (Recording Session)
// =========================================================================
class RecordingSession {
  final String title;
  final String folderName;
  final String category;
  final RecordingSourceType sourceType;
  final String? programName;
  final String? imagePath;

  RecordingSession({
    required this.title,
    required this.folderName,
    required this.category,
    required this.sourceType,
    this.programName,
    this.imagePath,
  });
}

// =========================================================================
// واجهة الخدمة
// =========================================================================
abstract interface class RecordingService {
  Future<RecordingResult<RecordingOutput>> startRecording({
    required String streamUrl,
    required String title,
    required String folderName,
    required String category,
    required RecordingSourceType sourceType,
    String? programName,
    String? imagePath,
  });

  Future<RecordingResult<RecordingOutput>> stopRecording();

  Future<void> cancelRecording();

  bool get isRecording;

  Duration get currentDuration;

  int get recordedBytes;

  Stream<RecordingProgress> get progressStream;

  Future<void> dispose();
}

// =========================================================================
// تنفيذ الخدمة (Implementation)
// =========================================================================
final class RecordingServiceImpl implements RecordingService {
  final RecordingRepository repository;
  final StorageService storageService;
  final RecordingPlatform _platform = buildRecordingPlatform();
  
  late final StreamSubscription _progressSubscription;
  final StreamController<RecordingProgress> _progressController =
      StreamController<RecordingProgress>.broadcast();

  int _recordedBytes = 0;
  RecordingSession? _currentSession;

  RecordingServiceImpl({
    required this.repository,
    required this.storageService,
  }) {
    _progressSubscription = _platform.progressStream.listen(
      (event) {
        _recordedBytes = event.recordedBytes;
        _progressController.add(
          RecordingProgress(
            duration: event.duration,
            recordedBytes: event.recordedBytes,
          ),
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Error in progress stream: $error');
        debugPrintStack(stackTrace: stackTrace);
      },
    );
  }

  @override
  bool get isRecording => _platform.isRecording;

  @override
  Duration get currentDuration => _platform.currentDuration;

  @override
  int get recordedBytes => _recordedBytes;

  @override
  Stream<RecordingProgress> get progressStream => _progressController.stream;

  @override
  Future<RecordingResult<RecordingOutput>> startRecording({
    required String streamUrl,
    required String title,
    required String folderName,
    required String category,
    required RecordingSourceType sourceType,
    String? programName,
    String? imagePath,
  }) async {
    if (isRecording) {
      return const RecordingResult.failure(RecordingError.streamUnavailable);
    }

    _recordedBytes = 0;

    try {
      final filePath = await storageService.generateRecordingFilePath(
        category: category,
        folderName: folderName,
      );

      _currentSession = RecordingSession(
        title: title,
        folderName: folderName,
        category: category,
        sourceType: sourceType,
        programName: programName,
        imagePath: imagePath,
      );

      final result = await _platform.startRecording(
        streamUrl: streamUrl,
        title: _currentSession!.title,
        filePath: filePath,
      );

      return switch (result) {
        RecordingSuccess(:final data) => RecordingResult.success(data),
        RecordingFailure(:final error) => RecordingResult.failure(error),
      };
    } catch (e, stack) {
      debugPrint('Exception in startRecording: $e');
      debugPrintStack(stackTrace: stack);
      
      await cancelRecording();
      return const RecordingResult.failure(RecordingError.unknown);
    }
  }

  @override
  Future<RecordingResult<RecordingOutput>> stopRecording() async {
    if (!isRecording || _currentSession == null) {
      return const RecordingResult.failure(RecordingError.streamUnavailable);
    }

    try {
      final result = await _platform.stopRecording();

      switch (result) {
        case RecordingSuccess(:final data):
          if (data.fileSize > 0) {
            try {
              final recording = RecordingFile(
                id: const Uuid().v4(),
                title: _currentSession!.title,
                fileName: path.basename(data.filePath),
                filePath: data.filePath,
                sourceType: _currentSession!.sourceType,
                category: _currentSession!.category,
                folderName: _currentSession!.folderName,
                duration: data.duration,
                fileSize: data.fileSize,
                createdAt: DateTime.now(),
                status: RecordingStatus.completed,
                programName: _currentSession!.programName,
                imageUrl: _currentSession!.imagePath,
              );

              await repository.saveRecording(recording);
            } catch (e, stack) {
              debugPrint('Error saving recording: $e');
              debugPrintStack(stackTrace: stack);
              
              await storageService.deleteRecording(data.filePath);
              debugPrint('Orphaned file deleted to maintain consistency.');
              
              _clearSession();
              return const RecordingResult.failure(RecordingError.storage);
            }
          }

          _clearSession();
          return RecordingResult.success(data);

        case RecordingFailure(:final error):
          _clearSession();
          return RecordingResult.failure(error);
      }
    } catch (e, stack) {
      debugPrint('Exception in stopRecording: $e');
      debugPrintStack(stackTrace: stack);
      _clearSession();
      return const RecordingResult.failure(RecordingError.storage);
    }
  }

  @override
  Future<void> cancelRecording() async {
    if (!isRecording) return;

    try {
      await _platform.cancelRecording();
    } catch (e, stack) {
      debugPrint('Exception in cancelRecording: $e');
      debugPrintStack(stackTrace: stack);
    } finally {
      _clearSession();
    }
  }

  @override
  Future<void> dispose() async {
    await _progressSubscription.cancel();
    await _platform.dispose();
    await _progressController.close();
  }

  // =========================================================================
  // دوال مساعدة (Helper Methods)
  // =========================================================================

  void _clearSession() {
    _currentSession = null;
    _recordedBytes = 0;
  }
}
