// lib/core/recording/services/recording_types.dart

sealed class RecordingResult<T> {
  const RecordingResult();

  const factory RecordingResult.success(T data) = RecordingSuccess<T>;

  const factory RecordingResult.failure(RecordingError error) =
      RecordingFailure<T>;

  bool get isSuccess => this is RecordingSuccess<T>;

  bool get isFailure => this is RecordingFailure<T>;
}

final class RecordingSuccess<T> extends RecordingResult<T> {
  final T data;

  const RecordingSuccess(this.data);
}

final class RecordingFailure<T> extends RecordingResult<T> {
  final RecordingError error;

  const RecordingFailure(this.error);
}

enum RecordingError {
  streamUnavailable,
  permissionDenied,
  network,
  storage,
  cancelled,
  alreadyRecording,
  initialization,
  unknown,
}

final class RecordingOutput {
  final String filePath;
  final Duration duration;
  final int fileSize;

  const RecordingOutput({
    required this.filePath,
    required this.duration,
    required this.fileSize,
  });
}

final class RecordingProgress {
  final Duration duration;
  final int recordedBytes;

  const RecordingProgress({
    required this.duration,
    required this.recordedBytes,
  });
}