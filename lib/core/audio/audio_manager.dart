// lib/core/audio/audio_manager.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/audio/audio_handler.dart';

class AudioManager {
  AudioManager._internal();
  static final AudioManager _instance = AudioManager._internal();
  static AudioManager get instance => _instance;

  late final AlwanAudioHandler _audioHandler;
  bool _isHandlerSet = false;
  
  void setAudioHandler(AlwanAudioHandler handler) {
    if (_isHandlerSet) return;
    _audioHandler = handler;
    _isHandlerSet = true;
  }

  AudioPlayer get player => _audioHandler.player;

  bool _initialized = false;
  final List<AudioTrack> _queue = [];
  int _currentIndex = 0;

  List<AudioTrack> get queue => List.unmodifiable(_queue);

  AudioTrack? get currentTrack {
    if (_queue.isEmpty || _currentIndex < 0 || _currentIndex >= _queue.length) {
      return null;
    }
    return _queue[_currentIndex];
  }

  int get currentIndex => _currentIndex;
  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  double _volume = 1.0;
  double _speed = 1.0;

  double get volume => _volume;
  double get speed => _speed;

  bool get isPlaying => _audioHandler.isPlaying;
  Duration get position => _audioHandler.position;
  Duration get duration => _audioHandler.duration ?? Duration.zero;
  bool get shuffleEnabled => player.shuffleModeEnabled;
  LoopMode get loopMode => player.loopMode;

  Timer? _sleepTimer;
  Timer? _sleepCountdownTimer;
  DateTime? _sleepTimerEndTime;
  Duration _sleepTimerRemaining = Duration.zero;

  DateTime? get sleepTimerEndTime => _sleepTimerEndTime;
  Duration get sleepTimerRemaining => _sleepTimerRemaining;
  bool get hasSleepTimer => _sleepTimer != null;

  final Map<String, List<AudioTrack>> _favorites = {};
  final Map<String, List<AudioTrack>> _downloads = {};

  Map<String, List<AudioTrack>> get favorites => _favorites;
  Map<String, List<AudioTrack>> get downloads => _downloads;

  static const String _lastTrackIdKey = 'last_track_id';
  static const String _lastPositionKey = 'last_position';

  Future<Map<String, List<AudioTrack>>> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('favorites');
      if (data != null) {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        _favorites.clear();
        decoded.forEach((key, value) {
          final list = (value as List)
              .map((e) => AudioTrack.fromJson(e as Map<String, dynamic>))
              .toList();
          _favorites[key] = list;
        });
      }
    } catch (_) {}
    return _favorites;
  }

  final _shuffleController = StreamController<bool>.broadcast();
  final _loopModeController = StreamController<LoopMode>.broadcast();
  final _sleepTimerController = StreamController<Duration>.broadcast();

  Stream<PlayerState> get playerStateStream => _audioHandler.playerStateStream;
  Stream<Duration> get positionStream => _audioHandler.positionStream;
  Stream<Duration?> get durationStream => _audioHandler.durationStream;
  Stream<int?> get currentIndexStream => _audioHandler.currentIndexStream;
  Stream<PlaybackEvent> get playbackEventStream => player.playbackEventStream;
  Stream<SequenceState?> get sequenceStateStream => _audioHandler.sequenceStateStream;
  Stream<bool> get shuffleModeStream => _shuffleController.stream;
  Stream<LoopMode> get loopModeStream => _loopModeController.stream;
  Stream<Duration> get sleepTimerStream => _sleepTimerController.stream;

  StreamSubscription<int?>? _currentIndexSubscription;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await _audioHandler.setVolume(_volume);
      await _audioHandler.setSpeed(_speed);
    } catch (_) {}

    await loadFavorites();
    _attachListeners();
  }

  void _attachListeners() {
    _currentIndexSubscription?.cancel();
    _currentIndexSubscription = _audioHandler.currentIndexStream.listen((index) {
      if (index == null) return;
      _currentIndex = index;
    });
  }

  Future<void> loadPlaylist(
    List<AudioTrack> tracks, {
    int initialIndex = 0,
    bool autoPlay = true,
  }) async {
    if (tracks.isEmpty) return;
    await initialize();

    _queue..clear()..addAll(tracks);
    _currentIndex = initialIndex.clamp(0, _queue.length - 1);

    try {
      await _audioHandler.setQueue(
        _queue,
        initialIndex: _currentIndex,
        autoPlay: autoPlay,
      );
    } catch (e) {
      debugPrint("❌ خطأ قاتل في تشغيل القائمة عبر AlwanAudioHandler: $e");
    }

    _shuffleController.add(player.shuffleModeEnabled);
    _loopModeController.add(player.loopMode);
  }

  Future<void> playPlaylist(List<AudioTrack> tracks, {int initialIndex = 0}) async {
    await loadPlaylist(tracks, initialIndex: initialIndex, autoPlay: true);
  }

  Future<void> playTrack(AudioTrack track) async {
    if (track.url.trim().isEmpty) {
      await stop();
      throw ArgumentError.value(
        track.url,
        'track.url',
        'لا يوجد رابط بث لهذه المحطة.',
      );
    }

    await loadPlaylist([track], autoPlay: true);
  }

  Future<void> playAudio(String url, {AudioTrack? track}) async {
    if (track != null) {
      await playTrack(track);
      return;
    }
    final tempTrack = AudioTrack(
      id: url,
      title: 'Unknown',
      subtitle: '',
      url: url,
      category: 'أخرى',
    );
    await playTrack(tempTrack);
  }

  Future<void> play() async {
    await initialize();
    try {
      if (!isPlaying) await _audioHandler.play();
    } catch (e, st) {
      debugPrint("خطأ أثناء التشغيل: $e");
      Zone.current.handleUncaughtError(e, st);
    }
  }

  Future<void> pause() async {
    try {
      if (isPlaying) await _audioHandler.pause();
    } catch (e, st) {
      debugPrint("خطأ أثناء الإيقاف المؤقت: $e");
      Zone.current.handleUncaughtError(e, st);
    }
  }

  Future<void> resume() async {
    try {
      if (!isPlaying) await _audioHandler.play();
    } catch (e, st) {
      debugPrint("خطأ أثناء الاستئناف: $e");
      Zone.current.handleUncaughtError(e, st);
    }
  }

  Future<void> stop() async {
    try {
      await _audioHandler.stop();
    } catch (e, st) {
      debugPrint("خطأ أثناء الإيقاف التام: $e");
      Zone.current.handleUncaughtError(e, st);
    }
  }

  Future<void> replay() async {
    await seek(Duration.zero);
    await play();
  }

  Future<void> restart() async {
    await seek(Duration.zero);
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    try {
      if (player.hasNext) {
        await _audioHandler.skipToNext();
        return;
      }
      if (player.loopMode == LoopMode.all && _queue.isNotEmpty) {
        await skipTo(0);
      }
    } catch (e, st) {
      debugPrint("خطأ في الانتقال للتالي: $e");
      Zone.current.handleUncaughtError(e, st);
    }
  }

  Future<void> previous() async {
    try {
      if (position > const Duration(seconds: 3)) {
        await seek(Duration.zero);
        return;
      }
      if (player.hasPrevious) {
        await _audioHandler.skipToPrevious();
        return;
      }
      await seek(Duration.zero);
    } catch (e, st) {
      debugPrint("خطأ في الانتقال للسابق: $e");
      Zone.current.handleUncaughtError(e, st);
    }
  }

  Future<void> skipTo(int index) async {
    if (_queue.isEmpty || index < 0 || index >= _queue.length) return;
    try {
      await _audioHandler.skipToQueueItem(index);
      _currentIndex = index;
    } catch (e, st) {
      debugPrint("خطأ في تخطي العنصر: $e");
      Zone.current.handleUncaughtError(e, st);
    }
  }

  Future<void> seek(Duration position) async {
    Duration target = position;
    if (duration != Duration.zero) {
      if (target < Duration.zero) target = Duration.zero;
      if (target > duration) target = duration;
    }
    try {
      await _audioHandler.seek(target);
    } catch (e, st) {
      Zone.current.handleUncaughtError(e, st);
    }
  }

  Future<void> seekForward({Duration offset = const Duration(seconds: 10)}) async {
    if (duration == Duration.zero) return;
    final target = position + offset;
    await seek(target);
  }

  Future<void> seekBackward({Duration offset = const Duration(seconds: 10)}) async {
    final target = position - offset;
    await seek(target);
  }

  Future<void> setVolume(double value) async {
    final vol = value.clamp(0.0, 1.0);
    _volume = vol;
    try {
      await _audioHandler.setVolume(vol);
    } catch (_) {}
  }

  Future<void> mute() async => await setVolume(0.0);

  Future<void> unMute() async {
    if (_volume == 0) {
      await setVolume(1.0);
    } else {
      await setVolume(_volume);
    }
  }

  Future<void> setSpeed(double value) async {
    final spd = value.clamp(0.5, 3.0);
    _speed = spd;
    try {
      await _audioHandler.setSpeed(spd);
    } catch (_) {}
  }

  Future<void> resetSpeed() async => await setSpeed(1.0);

  Future<void> enableShuffle() async {
    if (_queue.length <= 1) return;
    try {
      await player.shuffle();
      await player.setShuffleModeEnabled(true);
      _shuffleController.add(true);
    } catch (_) {}
  }

  Future<void> disableShuffle() async {
    try {
      await player.setShuffleModeEnabled(false);
      _shuffleController.add(false);
    } catch (_) {}
  }

  Future<void> toggleShuffle() async {
    if (player.shuffleModeEnabled) {
      await disableShuffle();
    } else {
      await enableShuffle();
    }
  }

  Future<void> setLoopMode(LoopMode mode) async {
    try {
      await player.setLoopMode(mode);
      _loopModeController.add(mode);
    } catch (_) {}
  }

  Future<void> toggleRepeatMode() async {
    switch (player.loopMode) {
      case LoopMode.off:
        await setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        await setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        await setLoopMode(LoopMode.off);
        break;
    }
  }

  bool get isRepeatOne => player.loopMode == LoopMode.one;
  bool get isRepeatAll => player.loopMode == LoopMode.all;

  Future<void> addToFavorites(String category, AudioTrack track) async {
    final prefs = await SharedPreferences.getInstance();
    final list = _favorites.putIfAbsent(category, () => []);
    if (list.any((e) => e.id == track.id)) return;
    
    list.add(track);
    await prefs.setString('favorites', jsonEncode(
      _favorites.map((key, value) => MapEntry(key, value.map((e) => e.toJson()).toList())),
    ));
  }

  Future<void> removeFromFavorites(String category, String trackId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = _favorites[category];
    if (list == null) return;
    
    list.removeWhere((e) => e.id == trackId);
    if (list.isEmpty) _favorites.remove(category);
    
    await prefs.setString('favorites', jsonEncode(
      _favorites.map((key, value) => MapEntry(key, value.map((e) => e.toJson()).toList())),
    ));
  }

  bool isFavorite(String category, String trackId) {
    final list = _favorites[category];
    if (list == null) return false;
    return list.any((e) => e.id == trackId);
  }

  Future<void> addDownload(String category, AudioTrack track) async {
    final list = _downloads.putIfAbsent(category, () => []);
    if (list.any((e) => e.id == track.id)) return;
    list.add(track);
  }

  Future<void> removeDownload(String category, String trackId) async {
    final list = _downloads[category];
    if (list == null) return;
    list.removeWhere((e) => e.id == trackId);
    if (list.isEmpty) _downloads.remove(category);
  }

  Future<void> startSleepTimer(Duration duration) async {
    cancelSleepTimer();
    _sleepTimerEndTime = DateTime.now().add(duration);
    _sleepTimerRemaining = duration;
    _sleepTimerController.add(_sleepTimerRemaining);

    _sleepCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = _sleepTimerEndTime!.difference(DateTime.now());
      if (remaining.isNegative) {
        _sleepTimerRemaining = Duration.zero;
      } else {
        _sleepTimerRemaining = remaining;
      }
      _sleepTimerController.add(_sleepTimerRemaining);
    });

    _sleepTimer = Timer(duration, () async {
      await stop();
      cancelSleepTimer();
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepCountdownTimer?.cancel();
    _sleepCountdownTimer = null;
    _sleepTimerEndTime = null;
    _sleepTimerRemaining = Duration.zero;
    _sleepTimerController.add(Duration.zero);
  }

  Future<void> savePlaybackState() async {
    final track = currentTrack;
    if (track == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastTrackIdKey, track.id);
    await prefs.setInt(_lastPositionKey, position.inMilliseconds);
  }

  Future<({String? trackId, Duration position})> loadPlaybackState() async {
    final prefs = await SharedPreferences.getInstance();
    final trackId = prefs.getString(_lastTrackIdKey);
    final milliseconds = prefs.getInt(_lastPositionKey) ?? 0;
    return (trackId: trackId, position: Duration(milliseconds: milliseconds));
  }

  Future<void> restorePlaybackState(List<AudioTrack> library) async {
    final saved = await loadPlaybackState();
    if (saved.trackId == null) return;

    final index = library.indexWhere((e) => e.id == saved.trackId);
    if (index == -1) return;

    await loadPlaylist(library, initialIndex: index, autoPlay: false);
    await seek(saved.position);
  }

  Future<void> dispose() async {
    cancelSleepTimer();
    await _currentIndexSubscription?.cancel();
    if (!_shuffleController.isClosed) await _shuffleController.close();
    if (!_loopModeController.isClosed) await _loopModeController.close();
    if (!_sleepTimerController.isClosed) await _sleepTimerController.close();
    try {
      await _audioHandler.dispose();
    } catch (_) {}
  }
}
