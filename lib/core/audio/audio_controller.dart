// lib/core/audio/audio_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import 'models/audio_track.dart';
import 'screens/queue_screen.dart';
import 'providers/audio_provider.dart';

class AudioController {
  AudioController(this._ref);

  final Ref _ref;

  AudioPlayerNotifier get _notifier => _ref.read(audioPlayerProvider.notifier);
  AudioPlayerState get currentState => _ref.read(audioPlayerProvider);

  AudioTrack? get currentTrack => currentState.currentTrack;
  bool get isPlaying => currentState.isPlaying;
  bool get isLoading => currentState.isLoading;
  bool get isBuffering => currentState.isBuffering;
  bool get hasError => currentState.hasError;
  Duration get position => currentState.position;
  Duration get duration => currentState.duration;
  double get volume => currentState.volume;
  double get speed => currentState.speed;
  bool get hasPrevious => currentState.hasPrevious;
  bool get hasNext => currentState.hasNext;
  bool get shuffleEnabled => currentState.shuffleEnabled;
  LoopMode get loopMode => currentState.loopMode;
  Duration get sleepTimerRemaining => currentState.sleepTimerRemaining;
  bool get hasSleepTimer => sleepTimerRemaining > Duration.zero;

  Future<void> play(AudioTrack track) async {
    await _notifier.play(track);
  }

  Future<void> loadPlaylist(
    List<AudioTrack> tracks, {
    int initialIndex = 0,
  }) async {
    await _notifier.loadPlaylist(tracks, initialIndex: initialIndex);
  }

  Future<void> pause() async => await _notifier.pause();
  Future<void> resume() async => await _notifier.resume();
  Future<void> stop() async => await _notifier.stop();
  Future<void> togglePlayPause() async => await _notifier.togglePlayPause();
  Future<void> togglePlay() async => await togglePlayPause();
  Future<void> replay() async => await _notifier.replay();
  Future<void> restart() async => await _notifier.restart();

  Future<void> next() async => await _notifier.next();
  Future<void> previous() async => await _notifier.previous();
  Future<void> seek(Duration position) async => await _notifier.seek(position);

  Future<void> seekForward() async {
    final target = position + const Duration(seconds: 10);
    await seek(target > duration ? duration : target);
  }

  Future<void> seekBackward() async {
    final target = position - const Duration(seconds: 10);
    await seek(target.isNegative ? Duration.zero : target);
  }

  Future<void> setVolume(double volume) async => await _notifier.setVolume(volume);
  Future<void> setSpeed(double speed) async => await _notifier.setSpeed(speed);

  Future<void> changeSpeed() async {
    final newSpeed = speed == 1.0 ? 1.5 : (speed == 1.5 ? 2.0 : 1.0);
    await _notifier.setSpeed(newSpeed);
  }

  Future<void> toggleShuffle() async => await _notifier.toggleShuffle();
  Future<void> toggleRepeatMode() async => await _notifier.toggleRepeatMode();
  Future<void> toggleRepeat() async => await _notifier.toggleRepeatMode();
  
  Future<void> toggleFavorite(AudioTrack track) async {
    await _notifier.toggleFavorite(track);
  }

  Future<void> startSleepTimer(Duration duration) async {
    await _notifier.startSleepTimer(duration);
  }

  void cancelSleepTimer() => _notifier.cancelSleepTimer();

  Future<void> showQueue(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QueueScreen()),
    );
  }

  Future<void> showSleepTimer(BuildContext context) async {
    final result = await showModalBottomSheet<Duration?>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('15 دقيقة'),
                onTap: () => Navigator.pop(context, const Duration(minutes: 15)),
              ),
              ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('30 دقيقة'),
                onTap: () => Navigator.pop(context, const Duration(minutes: 30)),
              ),
              ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('45 دقيقة'),
                onTap: () => Navigator.pop(context, const Duration(minutes: 45)),
              ),
              ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('ساعة'),
                onTap: () => Navigator.pop(context, const Duration(hours: 1)),
              ),
              ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('ساعتان'),
                onTap: () => Navigator.pop(context, const Duration(hours: 2)),
              ),
              if (hasSleepTimer)
                ListTile(
                  leading: const Icon(Icons.close, color: Colors.red),
                  title: const Text('إلغاء مؤقت النوم'),
                  onTap: () => Navigator.pop(context, Duration.zero),
                ),
            ],
          ),
        );
      },
    );

    if (result == null) return;
    
    if (result == Duration.zero) {
      cancelSleepTimer();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء مؤقت النوم')),
        );
      }
      return;
    }
    
    await startSleepTimer(result);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('سيتوقف التشغيل بعد ${result.inMinutes} دقيقة')),
      );
    }
  }

  void dispose() {}
}

final audioControllerProvider = Provider<AudioController>(
  (ref) => AudioController(ref),
);