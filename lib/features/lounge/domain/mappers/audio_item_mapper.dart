import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/features/lounge/domain/models/audio_item.dart';

extension AudioItemMapper on AudioItem {
  // 🟢 استقبال التصنيف كمعامل إجباري (Required Parameter) لتجنب نسيانه
  AudioTrack toAudioTrack({required String category}) {
    return AudioTrack(
      id: id,
      title: title,
      subtitle: artist,
      url: audioUrl,
      imageUrl: artworkUrl,
      duration: duration,
      category: category, // 🟢 الاعتماد على القيمة الممررة ديناميكياً
      sourceType: AudioSourceType.music,
      isLiveStream: false,
    );
  }
}