import 'dart:async';

import 'recording_factory.dart';
import 'recording_platform.dart';
import 'recording_types.dart';

void registerDefaultRecordingPlatform() {
  registerRecordingPlatform(WebRecordingPlatform.new);
}

final class WebRecordingPlatform implements RecordingPlatform {
  @override
  bool get isRecording => false;

  @override
  Duration get currentDuration => Duration.zero;

  @override
  int get recordedBytes => 0;

  @override
  Stream<RecordingProgress> get progressStream => const Stream.empty();

  @override
  Future<RecordingResult<RecordingOutput>> startRecording({
    required String streamUrl,
    required String title,
    required String filePath,
  }) async {
    return const RecordingResult.failure(RecordingError.initialization);
  }

  @override
  Future<RecordingResult<RecordingOutput>> stopRecording() async {
    return const RecordingResult.failure(RecordingError.streamUnavailable);
  }

  @override
  Future<void> cancelRecording() async {}

  @override
  Future<void> dispose() async {}
}
