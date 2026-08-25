// lib/core/recording/services/android_recording_platform.dart

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'recording_platform.dart';
import 'recording_types.dart';

final class AndroidRecordingPlatform implements RecordingPlatform {
  final StreamController<RecordingProgress> _progressController =
      StreamController<RecordingProgress>.broadcast();

  HttpClient? _client;
  HttpClientRequest? _request;
  HttpClientResponse? _response;

  IOSink? _sink;
  File? _recordingFile;

  StreamSubscription<List<int>>? _subscription;
  Timer? _timer;

  bool _isRecording = false;

  Duration _currentDuration = Duration.zero;

  int _recordedBytes = 0;

  DateTime? _startTime;

  @override
  bool get isRecording => _isRecording;

  @override
  Duration get currentDuration => _currentDuration;

  @override
  int get recordedBytes => _recordedBytes;

  @override
  Stream<RecordingProgress> get progressStream =>
      _progressController.stream;

  void _resetState() {
    _timer?.cancel();
    _timer = null;

    _subscription?.cancel();
    _subscription = null;

    _sink = null;

    _response = null;
    _request = null;

    _client?.close(force: true);
    _client = null;

    _recordingFile = null;

    _startTime = null;

    _currentDuration = Duration.zero;
    _recordedBytes = 0;

    _isRecording = false;
  }

  void _startProgressTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!_isRecording) return;

        if (_startTime != null) {
          _currentDuration =
              DateTime.now().difference(_startTime!);
        }

        _progressController.add(
          RecordingProgress(
            duration: _currentDuration,
            recordedBytes: _recordedBytes,
          ),
        );
      },
    );
  }

  @override
  Future<RecordingResult<RecordingOutput>> startRecording({
    required String streamUrl,
    required String title,
    required String filePath,
  }) async {
    if (_isRecording) {
      return const RecordingResult.failure(
        RecordingError.streamUnavailable,
      );
    }

    try {
      _recordingFile = File(filePath);

      if (!await _recordingFile!.parent.exists()) {
        await _recordingFile!.parent.create(recursive: true);
      }

      if (await _recordingFile!.exists()) {
        await _recordingFile!.delete();
      }

      await _recordingFile!.create(recursive: true);

      _sink = _recordingFile!.openWrite(mode: FileMode.writeOnly);

      _client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 15)
        ..userAgent = 'AlwanHub/1.0';

      final uri = Uri.parse(streamUrl);

      _request = await _client!.getUrl(uri);

      _request!.headers.set(
        HttpHeaders.acceptHeader,
        '*/*',
      );

      _request!.headers.set(
        'Icy-MetaData',
        '1',
      );

      _request!.headers.set(
        HttpHeaders.connectionHeader,
        'keep-alive',
      );

      _response = await _request!.close();

      if (_response!.statusCode != HttpStatus.ok) {
        await _sink?.close();

        return const RecordingResult.failure(
          RecordingError.streamUnavailable,
        );
      }

      _isRecording = true;

      _recordedBytes = 0;

      _currentDuration = Duration.zero;

      _startTime = DateTime.now();

      _startProgressTimer();

      _subscription = _response!.listen(
        (chunk) {
          if (!_isRecording) return;

          _sink?.add(chunk);

          _recordedBytes += chunk.length;
        },
        onDone: () async {
          if (_isRecording) {
            await stopRecording();
          }
        },
        onError: (error, stack) async {
          debugPrint('Recording stream error: $error');
          debugPrintStack(stackTrace: stack);

          if (_isRecording) {
            await cancelRecording();
          }
        },
        cancelOnError: true,
      );

      return RecordingResult.success(
        RecordingOutput(
          filePath: filePath,
          duration: Duration.zero,
          fileSize: 0,
        ),
      );
    } catch (e, stack) {
      debugPrint('Start recording failed: $e');
      debugPrintStack(stackTrace: stack);

      await cancelRecording();

      return const RecordingResult.failure(
        RecordingError.initialization,
      );
    }
  }

  @override
  Future<RecordingResult<RecordingOutput>> stopRecording() async {
    if (!_isRecording || _recordingFile == null) {
      return const RecordingResult.failure(
        RecordingError.streamUnavailable,
      );
    }

    try {
      _isRecording = false;

      _timer?.cancel();
      _timer = null;

      await _subscription?.cancel();
      _subscription = null;

      await _sink?.flush();
      await _sink?.close();
      _sink = null;

      _client?.close(force: true);
      _client = null;

      final fileSize = await _recordingFile!.length();

      final output = RecordingOutput(
        filePath: _recordingFile!.path,
        duration: _currentDuration,
        fileSize: fileSize,
      );

      _resetState();
      
      return RecordingResult.success(output);
    } catch (e, stack) {
      debugPrint('Stop recording failed: $e');
      debugPrintStack(stackTrace: stack);

      return const RecordingResult.failure(
        RecordingError.storage,
      );
    }
  }

  @override
  Future<void> cancelRecording() async {
    final file = _recordingFile;

    _isRecording = false;

    _timer?.cancel();
    _timer = null;

    await _subscription?.cancel();
    _subscription = null;

    try {
      await _sink?.flush();
    } catch (_) {}

    try {
      await _sink?.close();
    } catch (_) {}

    _sink = null;

    _client?.close(force: true);
    _client = null;

    _request = null;
    _response = null;

    if (file != null && await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }

    _resetState();
  }

  @override
  Future<void> dispose() async {
    await cancelRecording();

    await _progressController.close();
  }
}