import 'android_recording_platform.dart';
import 'recording_factory.dart';

void registerDefaultRecordingPlatform() {
  registerRecordingPlatform(AndroidRecordingPlatform.new);
}
