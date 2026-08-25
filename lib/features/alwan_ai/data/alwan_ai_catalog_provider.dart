import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/audio/providers/audio_provider.dart';
import 'package:alwan_hub/core/models/favorite_item.dart';
import 'package:alwan_hub/core/providers/favorites_provider.dart';
import 'package:alwan_hub/core/recording/models/recording_file.dart';
import 'package:alwan_hub/core/recording/providers/recording_provider.dart';
import 'package:alwan_hub/core/storage/favorite_storage_service.dart';
import 'package:alwan_hub/features/alwan_ai/application/alwan_ai_command_service.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item_type.dart';
import 'package:alwan_hub/features/library/presentation/providers/library_provider.dart';
import 'package:alwan_hub/features/programs/domain/entities/fm_program.dart';
import 'package:alwan_hub/features/programs/presentation/providers/fm_program_provider.dart';

final alwanAiCommandServiceProvider = Provider<AlwanAiCommandService>((ref) {
  return AlwanAiCommandService(
    loadMediaCatalog: () => _loadUnifiedMediaCatalog(ref),
  );
});

Future<List<AudioTrack>> _loadUnifiedMediaCatalog(Ref ref) async {
  final tracks = <AudioTrack>[];
  final builtIn = await AlwanAiCommandService.loadBuiltInMediaCatalog();
  tracks.addAll(builtIn);

  try {
    final items = await ref.read(libraryRepositoryProvider).getItems();
    for (final item in items) {
      final related = _relatedBuiltInTrack(item, builtIn);
      final track = libraryItemToAudioTrack(item, relatedTrack: related);
      if (track != null) tracks.add(track);
    }
  } catch (_) {
    // لا يمنع تعذر التخزين المحلي بقية فهرس المساعد من العمل.
  }

  try {
    final recordings = await ref
        .read(recordingRepositoryProvider)
        .getAllRecordings();
    tracks.addAll(
      recordings
          .where((item) => item.status == RecordingStatus.completed)
          .map(recordingToAudioTrack),
    );
  } catch (_) {
    // قد لا تكون خدمة التسجيل متاحة على بعض منصات الويب.
  }

  try {
    final programs = await ref.read(fmProgramRepositoryProvider).fetchPrograms();
    tracks.addAll(
      programs
          .where((program) => program.isPublished)
          .map(programToAudioTrack),
    );
  } catch (_) {
    // تبقى المصادر الأخرى متاحة إذا تعذر مصدر برامج FM.
  }

  try {
    final state = ref.read(audioPlayerProvider);
    if (state.currentTrack != null) tracks.add(state.currentTrack!);
    tracks.addAll(state.queue);
    for (final favorites in state.favoritesByCategory.values) {
      tracks.addAll(favorites);
    }
  } catch (_) {
    // حالة المشغل مصدر إضافي وليست شرطًا لعمل البحث.
  }

  try {
    final favorites = <FavoriteItem>{
      ...ref.read(favoritesProvider),
      ...await FavoriteStorageService.loadFavorites(),
    };
    tracks.addAll(favorites.map(favoriteItemToAudioTrack));
  } catch (_) {
    // تبقى بقية الملفات قابلة للبحث عند تعذر المفضلة القديمة.
  }

  return mergeAlwanAiTracks(tracks);
}

AudioTrack? libraryItemToAudioTrack(
  LibraryItem item, {
  AudioTrack? relatedTrack,
}) {
  final remoteUrl = item.audioUrl?.trim() ?? '';
  final localPath = item.localPath.trim();
  final source = localPath.isNotEmpty ? localPath : remoteUrl;
  if (source.isEmpty) return null;

  return AudioTrack(
    id: 'library-${item.id}',
    title: item.title,
    subtitle: relatedTrack?.subtitle ?? _libraryTypeLabel(item.type),
    description: relatedTrack?.description,
    url: source,
    imageUrl: item.coverUrl ?? relatedTrack?.imageUrl,
    coverUrl: relatedTrack?.coverUrl,
    presenterName: relatedTrack?.presenterName,
    sourceType: _isRemoteUrl(source)
        ? _librarySourceType(item.type)
        : AudioSourceType.local,
    category: item.categoryId ?? relatedTrack?.category ?? 'مكتبتي',
    duration: relatedTrack?.duration,
  );
}

AudioTrack recordingToAudioTrack(RecordingFile recording) {
  return AudioTrack(
    id: 'recording-${recording.id}',
    title: recording.title,
    subtitle:
        recording.programName ?? recording.stationName ?? recording.folderName,
    description: recording.notes,
    url: recording.filePath,
    imageUrl: recording.imageUrl,
    presenterName: recording.programName ?? recording.stationName,
    sourceType: AudioSourceType.local,
    category: recording.category.trim().isEmpty
        ? 'التسجيلات'
        : recording.category,
    duration: recording.duration,
  );
}

AudioTrack programToAudioTrack(FmProgram program) {
  return AudioTrack(
    id: 'program-${program.id}',
    title: program.title,
    subtitle: program.presenterName,
    description: program.description,
    url: program.streamUrl,
    imageUrl: program.imageUrl,
    presenterName: program.presenterName,
    isLiveStream: program.isLive,
    isFm: true,
    sourceType: AudioSourceType.program,
    category: 'برامج FM',
  );
}

AudioTrack favoriteItemToAudioTrack(FavoriteItem item) {
  return AudioTrack(
    id: 'favorite-${item.id}',
    title: item.title,
    subtitle: item.subtitle ?? item.subCategory ?? 'المفضلة',
    url: item.audioUrl,
    imageUrl: item.imageUrl,
    sourceType: _favoriteSourceType(item.type),
    category: item.subCategory ?? 'المفضلة',
  );
}

List<AudioTrack> mergeAlwanAiTracks(Iterable<AudioTrack> tracks) {
  final unique = <String, AudioTrack>{};
  for (final track in tracks) {
    final key = track.id.trim().isEmpty
        ? '${track.title}|${track.subtitle}|${track.url}'
        : track.id;
    final current = unique[key];
    if (current == null ||
        (current.url.trim().isEmpty && track.url.trim().isNotEmpty)) {
      unique[key] = track;
    }
  }
  return unique.values.toList(growable: false);
}

AudioTrack? _relatedBuiltInTrack(
  LibraryItem item,
  List<AudioTrack> builtIn,
) {
  for (final track in builtIn) {
    if (track.id == item.sourceId || track.id == item.id) return track;
  }
  return null;
}

AudioSourceType _librarySourceType(LibraryItemType type) {
  return switch (type) {
    LibraryItemType.audiobook => AudioSourceType.audiobook,
    LibraryItemType.podcast => AudioSourceType.podcast,
    LibraryItemType.recording => AudioSourceType.local,
    LibraryItemType.music => AudioSourceType.music,
  };
}

AudioSourceType _favoriteSourceType(FavoriteType type) {
  return switch (type) {
    FavoriteType.audioBooks => AudioSourceType.audiobook,
    FavoriteType.podcasts => AudioSourceType.podcast,
    FavoriteType.programs => AudioSourceType.program,
    _ => AudioSourceType.music,
  };
}

String _libraryTypeLabel(LibraryItemType type) {
  return switch (type) {
    LibraryItemType.audiobook => 'كتاب صوتي محفوظ',
    LibraryItemType.podcast => 'بودكاست محفوظ',
    LibraryItemType.recording => 'تسجيل محفوظ',
    LibraryItemType.music => 'مقطع موسيقي محفوظ',
  };
}

bool _isRemoteUrl(String value) {
  final normalized = value.toLowerCase();
  return normalized.startsWith('http://') || normalized.startsWith('https://');
}
