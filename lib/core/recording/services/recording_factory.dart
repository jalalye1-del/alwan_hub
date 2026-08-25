// lib/core/recording/services/recording_factory.dart

import 'recording_platform.dart';

typedef RecordingPlatformBuilder = RecordingPlatform Function();

RecordingPlatformBuilder? _builder;

/// تسجيل تنفيذ المنصة مرة واحدة عند بدء التطبيق.
void registerRecordingPlatform(RecordingPlatformBuilder builder) {
  _builder = builder;
}

/// إنشاء تنفيذ المنصة.
RecordingPlatform createRecordingPlatform() {
  final builder = _builder;

  if (builder == null) {
    throw StateError(
      'RecordingPlatform has not been registered. '
      'Call registerRecordingPlatform() before using RecordingService.',
    );
  }

  return builder();
}