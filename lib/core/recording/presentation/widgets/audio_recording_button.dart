import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/recording/models/recording_file.dart';
import 'package:alwan_hub/core/recording/providers/recording_provider.dart';
import 'package:alwan_hub/core/router/app_router.dart';

class AudioRecordingButton extends ConsumerStatefulWidget {
  const AudioRecordingButton({
    super.key,
    required this.track,
    this.compact = false,
  });

  final AudioTrack track;
  final bool compact;

  @override
  ConsumerState<AudioRecordingButton> createState() =>
      _AudioRecordingButtonState();
}

class _AudioRecordingButtonState extends ConsumerState<AudioRecordingButton> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;
  bool _wasRecording = false;

  @override
  void initState() {
    super.initState();
    ref.listenManual(recordingNotifierProvider, (_, next) {
      if (!_wasRecording && next.isRecording) {
        _startTimer();
      }

      if (_wasRecording && !next.isRecording) {
        _timer?.cancel();
        _timer = null;
      }

      _wasRecording = next.isRecording;
    });

    final initialState = ref.read(recordingNotifierProvider);
    _wasRecording = initialState.isRecording;
    if (_wasRecording) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _elapsed = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsed += const Duration(seconds: 1));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _toggleRecording() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('التسجيل من الموقع غير متاح حالياً.')),
      );
      return;
    }

    final recordingState = ref.read(recordingNotifierProvider);
    final notifier = ref.read(recordingNotifierProvider.notifier);

    if (recordingState.isLoading) return;

    if (recordingState.isRecording) {
      final saved = await notifier.stopRecording();
      if (mounted && saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التسجيل في تسجيلاتي.')),
        );
        await Future<void>.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          context.push(AppRoutes.libraryPath);
        }
      } else if (mounted) {
        final message = ref.read(recordingNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message == null
                  ? 'تعذر حفظ التسجيل. حاول مرة أخرى.'
                  : 'تعذر حفظ التسجيل: $message',
            ),
          ),
        );
      }
      return;
    }

    if (widget.track.url.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد رابط صوتي صالح لتسجيل هذه المادة.')),
      );
      return;
    }

    await notifier.startRecording(
      streamUrl: widget.track.url,
      title: widget.track.title,
      folderName: 'تسجيلاتي',
      category: widget.track.category,
      sourceType: _recordingSourceType(widget.track.sourceType),
      programName: widget.track.presenterName ?? widget.track.subtitle,
      imagePath: widget.track.imageUrl,
    );
  }

  RecordingSourceType _recordingSourceType(AudioSourceType sourceType) {
    return switch (sourceType) {
      AudioSourceType.fm => RecordingSourceType.fmStation,
      AudioSourceType.audiobook => RecordingSourceType.audiobook,
      AudioSourceType.podcast => RecordingSourceType.podcast,
      AudioSourceType.program => RecordingSourceType.program,
      AudioSourceType.music || AudioSourceType.local =>
        RecordingSourceType.liveBroadcast,
    };
  }

  String _formatDuration() {
    final hours = _elapsed.inHours.toString().padLeft(2, '0');
    final minutes = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return _elapsed.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final recordingState = ref.watch(recordingNotifierProvider);
    final isRecording = recordingState.isRecording;

    if (widget.compact) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: isRecording ? 94 : 36,
        height: 36,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: recordingState.isLoading ? null : _toggleRecording,
          child: Container(
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: isRecording ? 6 : 4),
          decoration: BoxDecoration(
            color: isRecording
                ? Colors.red.withValues(alpha: .10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isRecording
                    ? Icons.stop_circle_rounded
                    : Icons.fiber_manual_record_rounded,
                color: isRecording ? Colors.red : const Color(0xFFE53935),
                size: 27,
              ),
              if (isRecording) ...[
                const SizedBox(width: 4),
                Text(
                  _formatDuration(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          ),
        ),
      );
    }

    return FilledButton.icon(
      onPressed: recordingState.isLoading ? null : _toggleRecording,
      style: FilledButton.styleFrom(
        backgroundColor: isRecording ? Colors.red : const Color(0xFFE53935),
      ),
      icon: Icon(isRecording ? Icons.stop_rounded : Icons.fiber_manual_record_rounded),
      label: Text(isRecording ? 'إيقاف التسجيل ${_formatDuration()}' : 'تسجيل'),
    );
  }
}
