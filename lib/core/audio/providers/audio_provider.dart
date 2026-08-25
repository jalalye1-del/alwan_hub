// lib/core/audio/providers/audio_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'package:alwan_hub/core/audio/audio_manager.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';

class AudioPlayerState {
  final AudioTrack? currentTrack;

  final bool isPlaying;
  final bool isLoading;
  final bool isBuffering;
  final bool hasError;

  final Duration position;
  final Duration duration;

  final double volume;
  final double speed;

  final bool shuffleEnabled;
  final LoopMode loopMode;

  final bool hasPrevious;
  final bool hasNext;

  final Duration sleepTimerRemaining;

  final List<AudioTrack> queue;
  final int currentIndex;
  final List<String> favoriteIds;
  final Map<String, List<AudioTrack>> favoritesByCategory;

  const AudioPlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.isLoading = false,
    this.isBuffering = false,
    this.hasError = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.speed = 1.0,
    this.shuffleEnabled = false,
    this.loopMode = LoopMode.off,
    this.hasPrevious = false,
    this.hasNext = false,
    this.sleepTimerRemaining = Duration.zero,
    this.queue = const [],
    this.currentIndex = 0,
    this.favoriteIds = const [],
    this.favoritesByCategory = const {},
  });

  bool get isLive => currentTrack?.isLiveStream ?? false;
  bool get repeatEnabled => loopMode == LoopMode.one;
  bool isFavorite(String id) => favoriteIds.contains(id);

  AudioPlayerState copyWith({
    AudioTrack? currentTrack,
    bool? isPlaying,
    bool? isLoading,
    bool? isBuffering,
    bool? hasError,
    Duration? position,
    Duration? duration,
    double? volume,
    double? speed,
    bool? shuffleEnabled,
    LoopMode? loopMode,
    bool? hasPrevious,
    bool? hasNext,
    Duration? sleepTimerRemaining,
    List<AudioTrack>? queue,
    int? currentIndex,
    List<String>? favoriteIds,
    Map<String, List<AudioTrack>>? favoritesByCategory,
  }) {
    return AudioPlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      isBuffering: isBuffering ?? this.isBuffering,
      hasError: hasError ?? this.hasError,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      loopMode: loopMode ?? this.loopMode,
      hasPrevious: hasPrevious ?? this.hasPrevious,
      hasNext: hasNext ?? this.hasNext,
      sleepTimerRemaining: sleepTimerRemaining ?? this.sleepTimerRemaining,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      favoritesByCategory: favoritesByCategory ?? this.favoritesByCategory,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  AudioPlayerNotifier()
    : _audioManager = AudioManager.instance,
      super(const AudioPlayerState()) {
    _initialize();
  }

  final AudioManager _audioManager;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;
  StreamSubscription<bool>? _shuffleSubscription;
  StreamSubscription<LoopMode>? _loopModeSubscription;
  StreamSubscription<Duration>? _sleepTimerSubscription;

  DateTime? _lastPlaybackSave;

  Future<void> _initialize() async {
    await _audioManager.initialize();
    await _refreshFavorites();

    state = state.copyWith(
      currentTrack: _audioManager.currentTrack,
      isPlaying: _audioManager.isPlaying,
      position: _audioManager.position,
      duration: _audioManager.duration,
      volume: _audioManager.volume,
      speed: _audioManager.speed,
      shuffleEnabled: _audioManager.shuffleEnabled,
      loopMode: _audioManager.loopMode,
      hasPrevious: _audioManager.hasPrevious,
      hasNext: _audioManager.hasNext,
      sleepTimerRemaining: _audioManager.sleepTimerRemaining,
      queue: List<AudioTrack>.from(_audioManager.queue),
      currentIndex: _audioManager.currentIndex,
    );

    _listenToStreams();
  }

  Future<void> _refreshFavorites() async {
    final favorites = await _audioManager.loadFavorites();
    final ids = <String>[];
    for (final tracks in favorites.values) {
      ids.addAll(tracks.map((e) => e.id));
    }
    state = state.copyWith(
      favoriteIds: ids,
      favoritesByCategory: {
        for (final entry in favorites.entries)
          entry.key: List<AudioTrack>.from(entry.value),
      },
    );
  }

  void _listenToStreams() {
    _playerStateSubscription = _audioManager.playerStateStream.listen((
      playerState,
    ) {
      final processing = playerState.processingState;

      state = state.copyWith(
        currentTrack: _audioManager.currentTrack,
        isPlaying: playerState.playing,
        isLoading: processing == ProcessingState.loading,
        isBuffering: processing == ProcessingState.buffering,
        hasError: false,
        hasPrevious: _audioManager.hasPrevious,
        hasNext: _audioManager.hasNext,
      );
    });

    _positionSubscription = _audioManager.positionStream.listen((
      position,
    ) async {
      state = state.copyWith(position: position);

      final now = DateTime.now();
      if (_lastPlaybackSave == null ||
          now.difference(_lastPlaybackSave!) > const Duration(seconds: 10)) {
        _lastPlaybackSave = now;
        await _audioManager.savePlaybackState();
      }
    });

    _durationSubscription = _audioManager.durationStream.listen((duration) {
      state = state.copyWith(duration: duration ?? Duration.zero);
    });

    _currentIndexSubscription = _audioManager.currentIndexStream.listen((
      index,
    ) {
      state = state.copyWith(
        currentTrack: _audioManager.currentTrack,
        queue: List<AudioTrack>.from(_audioManager.queue),
        currentIndex: _audioManager.currentIndex,
        hasPrevious: _audioManager.hasPrevious,
        hasNext: _audioManager.hasNext,
      );
    });

    _shuffleSubscription = _audioManager.shuffleModeStream.listen((enabled) {
      state = state.copyWith(shuffleEnabled: enabled);
    });

    _loopModeSubscription = _audioManager.loopModeStream.listen((mode) {
      state = state.copyWith(loopMode: mode);
    });

    _sleepTimerSubscription = _audioManager.sleepTimerStream.listen((
      remaining,
    ) {
      state = state.copyWith(sleepTimerRemaining: remaining);
    });
  }

  Future<void> play(AudioTrack track) async {
    // 🟢 الحل الجذري لواجهة المشغل الرئيسية:
    // إجبار الواجهة على عرض بيانات المسار فوراً قبل بدء الاتصال
    state = state.copyWith(currentTrack: track, isLoading: true);

    try {
      await _audioManager.playTrack(track);

      state = state.copyWith(
        currentTrack: _audioManager.currentTrack ?? track,
        queue: List<AudioTrack>.from(_audioManager.queue),
        currentIndex: _audioManager.currentIndex,
        hasPrevious: _audioManager.hasPrevious,
        hasNext: _audioManager.hasNext,
      );
    } catch (_) {
      state = state.copyWith(
        currentTrack: track,
        isPlaying: false,
        isLoading: false,
        hasError: true,
      );
    }
  }

  Future<void> loadPlaylist(
    List<AudioTrack> tracks, {
    int initialIndex = 0,
  }) async {
    if (tracks.isEmpty) return;

    // 🟢 تحديث فوري هنا أيضاً
    state = state.copyWith(currentTrack: tracks[initialIndex], isLoading: true);

    await _audioManager.loadPlaylist(tracks, initialIndex: initialIndex);

    state = state.copyWith(
      currentTrack: _audioManager.currentTrack ?? tracks[initialIndex],
      queue: List<AudioTrack>.from(_audioManager.queue),
      currentIndex: _audioManager.currentIndex,
      hasPrevious: _audioManager.hasPrevious,
      hasNext: _audioManager.hasNext,
    );
  }

  Future<void> restoreLastSession(List<AudioTrack> library) async {
    await _audioManager.restorePlaybackState(library);
    state = state.copyWith(
      currentTrack: _audioManager.currentTrack,
      queue: List<AudioTrack>.from(_audioManager.queue),
      currentIndex: _audioManager.currentIndex,
      position: _audioManager.position,
      duration: _audioManager.duration,
      hasPrevious: _audioManager.hasPrevious,
      hasNext: _audioManager.hasNext,
    );
  }

  Future<void> pause() async => await _audioManager.pause();
  Future<void> resume() async => await _audioManager.resume();
  Future<void> stop() async => await _audioManager.stop();
  Future<void> togglePlayPause() async => await _audioManager.togglePlayPause();
  Future<void> seek(Duration position) async =>
      await _audioManager.seek(position);
  Future<void> seekForward() async => await _audioManager.seekForward();
  Future<void> seekBackward() async => await _audioManager.seekBackward();
  Future<void> next() async => await _audioManager.next();
  Future<void> previous() async => await _audioManager.previous();
  Future<void> replay() async => await _audioManager.replay();
  Future<void> restart() async => await _audioManager.restart();

  Future<void> setVolume(double value) async {
    await _audioManager.setVolume(value);
    state = state.copyWith(volume: value);
  }

  Future<void> setSpeed(double value) async {
    await _audioManager.setSpeed(value);
    state = state.copyWith(speed: value);
  }

  Future<void> toggleShuffle() async => await _audioManager.toggleShuffle();
  Future<void> toggleRepeatMode() async =>
      await _audioManager.toggleRepeatMode();
  Future<void> startSleepTimer(Duration duration) async =>
      await _audioManager.startSleepTimer(duration);
  void cancelSleepTimer() => _audioManager.cancelSleepTimer();

  Future<void> toggleFavorite(AudioTrack track) async {
    final category = track.category;
    if (_audioManager.isFavorite(category, track.id)) {
      await _audioManager.removeFromFavorites(category, track.id);
    } else {
      await _audioManager.addToFavorites(category, track);
    }
    await _refreshFavorites();
  }

  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < state.queue.length) {
      await _audioManager.skipTo(index);
      state = state.copyWith(currentIndex: index);
    }
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _shuffleSubscription?.cancel();
    _loopModeSubscription?.cancel();
    _sleepTimerSubscription?.cancel();
    super.dispose();
  }
}

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
      return AudioPlayerNotifier();
    });
