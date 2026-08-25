// lib/core/audio/audio_handler.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'models/audio_track.dart';

class AlwanAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  final List<AudioTrack> _tracks = [];
  final List<AudioSource> _sources = [];

  StreamSubscription<PlaybackEvent>? _playbackSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;
  StreamSubscription<SequenceState?>? _sequenceSubscription;

  AlwanAudioHandler() {
    _listenToPlayer();
  }

  AudioPlayer get player => _player;

  List<AudioTrack> get tracks => List.unmodifiable(_tracks);

  AudioTrack? get currentTrack {
    final index = _player.currentIndex;
    if (index == null || index >= _tracks.length) return null;
    return _tracks[index];
  }

  MediaItem _mediaItem(AudioTrack track) {
    final imageUri = Uri.tryParse(track.imageUrl ?? '');
    final artUri = imageUri != null &&
            (imageUri.scheme == 'http' ||
                imageUri.scheme == 'https' ||
                imageUri.scheme == 'file' ||
                imageUri.scheme == 'content')
        ? imageUri
        : null;

    return MediaItem(
      id: track.id,
      title: track.title,
      artist: track.presenterName ?? track.subtitle,
      album: track.category,
      playable: true,
      artUri: artUri,
      displayTitle: track.title,
      displaySubtitle: track.subtitle,
      displayDescription: track.category,
      extras: {
        'url': track.url,
        'live': track.isLiveStream,
        'programImage': track.programImage,
        'presenterImage': track.presenterImage,
      },
    );
  }

  AudioSource _audioSource(AudioTrack track) {
    final headers = kIsWeb
        ? null
        : {
            'User-Agent': 'Mozilla/5.0',
            'Icy-MetaData': '1',
            'Accept': '*/*',
            'Connection': 'keep-alive',
          };

    final uri = track.sourceType == AudioSourceType.local && !kIsWeb
        ? Uri.file(track.url)
        : Uri.parse(track.url);

    return AudioSource.uri(
      uri,
      headers: headers,
      tag: _mediaItem(track),
    );
  }

  void _listenToPlayer() {
    _playbackSubscription?.cancel();
    _currentIndexSubscription?.cancel();
    _sequenceSubscription?.cancel();

    _playbackSubscription = _player.playbackEventStream.listen((_) {
      _broadcastState();
    });

    _currentIndexSubscription = _player.currentIndexStream.listen((index) {
      if (index == null || index >= _tracks.length) return;
      mediaItem.add(_mediaItem(_tracks[index]));
    });

    _sequenceSubscription = _player.sequenceStateStream.listen((_) {
      queue.add(_tracks.map(_mediaItem).toList(growable: false));
    });
  }

  void _broadcastState() {
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (_player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: switch (_player.processingState) {
          ProcessingState.idle => AudioProcessingState.idle,
          ProcessingState.loading => AudioProcessingState.loading,
          ProcessingState.buffering => AudioProcessingState.buffering,
          ProcessingState.ready => AudioProcessingState.ready,
          ProcessingState.completed => AudioProcessingState.completed,
        },
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex ?? 0,
      ),
    );
  }

  Future<void> _refreshQueue() async {
    queue.add(_tracks.map(_mediaItem).toList(growable: false));
  }

  Future<void> _refreshCurrentMediaItem() async {
    final track = currentTrack;
    if (track == null) return;
    mediaItem.add(_mediaItem(track));
  }

  Future<void> setQueue(
    List<AudioTrack> tracks, {
    int initialIndex = 0,
    bool autoPlay = false,
  }) async {
    try {
      _tracks..clear()..addAll(tracks);
      _sources..clear()..addAll(tracks.map(_audioSource));

      if (_sources.isEmpty) {
        queue.add(const []);
        mediaItem.add(null);
        await stop();
        return;
      }

      final validIndex = initialIndex.clamp(0, _sources.length - 1);

      await _refreshQueue();
      mediaItem.add(_mediaItem(_tracks[validIndex]));

      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.loading,
      ));

      await _player.stop();

      await _player.setAudioSources(
        _sources,
        initialIndex: validIndex,
        initialPosition: Duration.zero,
      );

      if (autoPlay) {
        await play();
      }

    } catch (e) {
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
          errorMessage: 'رابط البث غير متاح حالياً',
        ),
      );
      debugPrint('Audio Connection Error: $e');
    }
  }

  Future<void> playTrack(AudioTrack track) async {
    await setQueue([track], autoPlay: true);
  }

  @override
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e, stackTrace) {
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
          errorMessage: e.toString(),
        ),
      );
      Zone.current.handleUncaughtError(e, stackTrace);
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
      _broadcastState();
    } catch (e, stackTrace) {
      Zone.current.handleUncaughtError(e, stackTrace);
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      _broadcastState();
    } catch (e, stackTrace) {
      Zone.current.handleUncaughtError(e, stackTrace);
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e, stackTrace) {
      Zone.current.handleUncaughtError(e, stackTrace);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _tracks.length) return;
    await _player.seek(Duration.zero, index: index);
    await _refreshCurrentMediaItem();
  }

  @override
  Future<void> skipToNext() async {
    if (!_player.hasNext) return;
    await _player.seekToNext();
    await _refreshCurrentMediaItem();
  }

  @override
  Future<void> skipToPrevious() async {
    if (!_player.hasPrevious) {
      await _player.seek(Duration.zero);
      return;
    }
    await _player.seekToPrevious();
    await _refreshCurrentMediaItem();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        await _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        await _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.all:
      case AudioServiceRepeatMode.group:
        await _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode != AudioServiceShuffleMode.none;
    await _player.setShuffleModeEnabled(enabled);
    if (enabled) await _player.shuffle();
  }

  Future<void> addTrackToQueue(AudioTrack track) async {
    try {
      final current = _player.currentIndex ?? 0;
      final position = _player.position;
      final playing = _player.playing;

      _tracks.add(track);
      _sources..clear()..addAll(_tracks.map(_audioSource));

      await _player.setAudioSources(
        _sources,
        initialIndex: current,
        initialPosition: position,
      );
      await _refreshQueue();
      if (playing) await _player.play();
    } catch (e, stackTrace) {
      Zone.current.handleUncaughtError(e, stackTrace);
    }
  }

  Future<void> removeTrackFromQueue(int index) async {
    try {
      if (index < 0 || index >= _tracks.length) return;

      final current = _player.currentIndex ?? 0;
      final position = _player.position;
      final playing = _player.playing;

      _tracks.removeAt(index);
      _sources..clear()..addAll(_tracks.map(_audioSource));

      if (_tracks.isEmpty) {
        await stop();
        queue.add(const []);
        mediaItem.add(null);
        return;
      }

      final newIndex = current >= _tracks.length ? _tracks.length - 1 : current;

      await _player.setAudioSources(
        _sources,
        initialIndex: newIndex,
        initialPosition: position,
      );

      await _refreshQueue();
      await _refreshCurrentMediaItem();

      if (playing) await _player.play();
    } catch (e, stackTrace) {
      Zone.current.handleUncaughtError(e, stackTrace);
    }
  }

  Future<void> clearQueue() async {
    try {
      _tracks.clear();
      _sources.clear();
      await stop();
      queue.add(const []);
      mediaItem.add(null);
    } catch (e, stackTrace) {
      Zone.current.handleUncaughtError(e, stackTrace);
    }
  }

  Future<void> restoreQueue(
    List<AudioTrack> tracks, {
    int index = 0,
    Duration position = Duration.zero,
  }) async {
    try {
      if (tracks.isEmpty) return;

      _tracks..clear()..addAll(tracks);
      _sources..clear()..addAll(_tracks.map(_audioSource));

      await _player.setAudioSources(
        _sources,
        initialIndex: index.clamp(0, _tracks.length - 1),
        initialPosition: position,
      );

      await _refreshQueue();
      await _refreshCurrentMediaItem();
    } catch (e, stackTrace) {
      Zone.current.handleUncaughtError(e, stackTrace);
    }
  }

  Future<void> setVolume(double value) async {
    await _player.setVolume(value.clamp(0.0, 1.0));
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future<void> replay() async {
    await _player.seek(Duration.zero);
    await _player.play();
  }

  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration get bufferedPosition => _player.bufferedPosition;
  Duration? get duration => _player.duration;
  int get currentIndex => _player.currentIndex ?? 0;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<SequenceState?> get sequenceStateStream => _player.sequenceStateStream;
  Stream<LoopMode> get loopModeStream => _player.loopModeStream;
  Stream<bool> get shuffleModeStream => _player.shuffleModeEnabledStream;

  Future<void> dispose() async {
    await _playbackSubscription?.cancel();
    await _currentIndexSubscription?.cancel();
    await _sequenceSubscription?.cancel();
    _sources.clear();
    await _player.dispose();
  }
}
