import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/models/favorite_item.dart';
import 'package:alwan_hub/core/recording/models/recording_file.dart';
import 'package:alwan_hub/features/alwan_ai/data/alwan_ai_catalog_provider.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item_type.dart';
import 'package:alwan_hub/features/programs/domain/entities/fm_program.dart';

void main() {
  test('maps saved library files and keeps their artist metadata', () {
    const related = AudioTrack(
      id: 'song-1',
      title: 'الأصل',
      subtitle: 'الفنان الأول',
      url: '',
      presenterName: 'الفنان الأول',
      category: 'الأغاني اليمنية',
    );
    final item = LibraryItem(
      id: 'saved-song',
      title: 'أغنيتي المحفوظة',
      type: LibraryItemType.music,
      sourceId: 'song-1',
      localPath: 'C:/Music/song.mp3',
      createdAt: DateTime(2026),
    );

    final track = libraryItemToAudioTrack(item, relatedTrack: related);

    expect(track?.title, 'أغنيتي المحفوظة');
    expect(track?.subtitle, 'الفنان الأول');
    expect(track?.sourceType, AudioSourceType.local);
    expect(track?.url, 'C:/Music/song.mp3');
  });

  test('maps recordings, dashboard programs, and legacy favorites', () {
    final recording = RecordingFile(
      id: 'rec-1',
      title: 'لقاء الصباح',
      fileName: 'morning.m4a',
      filePath: 'C:/Recordings/morning.m4a',
      sourceType: RecordingSourceType.program,
      category: 'برامج FM',
      folderName: 'تسجيلاتي',
      programName: 'صباح ألوان',
      fileSize: 1024,
      createdAt: DateTime(2026),
      status: RecordingStatus.completed,
    );
    const program = FmProgram(
      id: 'doctor',
      title: 'طبيب ألوان',
      description: 'برنامج طبي',
      presenterName: 'د. مرام',
      liveTime: '04:00 PM',
      replayTimes: [],
      imageUrl: 'doctor.png',
      streamUrl: 'https://example.com/live.mp3',
      accentColor: Colors.blue,
      broadcastDays: {1},
    );
    final favorite = FavoriteItem(
      id: 'fav-1',
      title: 'حلقة مفضلة',
      subtitle: 'بودكاست ألوان',
      imageUrl: 'podcast.png',
      audioUrl: 'https://example.com/podcast.mp3',
      type: FavoriteType.podcasts,
      addedAt: DateTime(2026),
    );

    expect(recordingToAudioTrack(recording).sourceType, AudioSourceType.local);
    expect(programToAudioTrack(program).sourceType, AudioSourceType.program);
    expect(
      favoriteItemToAudioTrack(favorite).sourceType,
      AudioSourceType.podcast,
    );
  });

  test('prefers a playable copy when duplicate identifiers are merged', () {
    const unavailable = AudioTrack(
      id: 'same',
      title: 'المقطع',
      subtitle: 'الفنان',
      url: '',
    );
    const playable = AudioTrack(
      id: 'same',
      title: 'المقطع',
      subtitle: 'الفنان',
      url: 'https://example.com/song.mp3',
    );

    final merged = mergeAlwanAiTracks([unavailable, playable]);

    expect(merged, hasLength(1));
    expect(merged.single.url, playable.url);
  });
}
