import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/audio/providers/audio_provider.dart';
import 'package:alwan_hub/core/recording/presentation/widgets/audio_recording_button.dart';
import 'package:alwan_hub/core/widgets/adaptive_content_image.dart';

class NowPlayingScreen extends ConsumerWidget {
  const NowPlayingScreen({super.key});

  String _format(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '${twoDigits(duration.inHours)}:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioController = ref.read(audioControllerProvider);
    final track = audioState.currentTrack;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF35227F), Color(0xFF6A5AE0), Color(0xFFF5F3FF)],
            stops: [0, .42, .82],
          ),
        ),
        child: SafeArea(
          child: track == null
              ? _EmptyPlayer(onClose: () => Navigator.maybePop(context))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 820;
                    return Column(
                      children: [
                        _PlayerHeader(
                          onClose: () => Navigator.maybePop(context),
                          onQueue: () => audioController.showQueue(context),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(
                              isWide ? 32 : 18,
                              12,
                              isWide ? 32 : 18,
                              24,
                            ),
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1040,
                                ),
                                child: isWide
                                    ? Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: _TrackOverview(
                                              track: track,
                                              hasError: audioState.hasError,
                                              artworkSize: 320,
                                            ),
                                          ),
                                          const SizedBox(width: 28),
                                          Expanded(
                                            child: _PlayerPanel(
                                              track: track,
                                              audioState: audioState,
                                              controller: audioController,
                                              formatDuration: _format,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          _TrackOverview(
                                            track: track,
                                            hasError: audioState.hasError,
                                            artworkSize: constraints.maxHeight
                                                .clamp(185.0, 265.0),
                                          ),
                                          const SizedBox(height: 18),
                                          _PlayerPanel(
                                            track: track,
                                            audioState: audioState,
                                            controller: audioController,
                                            formatDuration: _format,
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _PlayerHeader extends StatelessWidget {
  const _PlayerHeader({required this.onClose, required this.onQueue});

  final VoidCallback onClose;
  final VoidCallback onQueue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: 'إغلاق المشغل',
            onPressed: onClose,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 38,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: Column(
              children: [
                Text(
                  'قيد التشغيل الآن',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'مشغل ألوان',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'قائمة التشغيل',
            onPressed: onQueue,
            icon: const Icon(Icons.queue_music_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _TrackOverview extends StatelessWidget {
  const _TrackOverview({
    required this.track,
    required this.hasError,
    required this.artworkSize,
  });

  final AudioTrack track;
  final bool hasError;
  final double artworkSize;

  @override
  Widget build(BuildContext context) {
    final image =
        track.presenterImage ??
        track.programImage ??
        track.imageUrl ??
        track.coverUrl ??
        '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: artworkSize,
          height: artworkSize,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .22),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: ClipOval(
            child: AdaptiveContentImage(
              source: image,
              width: artworkSize,
              height: artworkSize,
              fit: BoxFit.cover,
              semanticLabel: track.title,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          track.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          hasError
              ? 'تعذر تشغيل المحتوى، حاول مرة أخرى'
              : (track.presenterName?.trim().isNotEmpty == true
                    ? track.presenterName!
                    : track.subtitle),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: hasError ? const Color(0xFFFFD0D0) : Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (track.isLiveStream) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              '●  بث مباشر',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  const _PlayerPanel({
    required this.track,
    required this.audioState,
    required this.controller,
    required this.formatDuration,
  });

  final AudioTrack track;
  final AudioPlayerState audioState;
  final AudioController controller;
  final String Function(Duration duration) formatDuration;

  @override
  Widget build(BuildContext context) {
    final isLive = track.isLiveStream;
    final hasSleepTimer = audioState.sleepTimerRemaining > Duration.zero;
    final progress = isLive || audioState.duration.inMilliseconds <= 0
        ? 0.0
        : (audioState.position.inMilliseconds /
                  audioState.duration.inMilliseconds)
              .clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive)
            const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: Text(
                'أنت تستمع إلى البث المباشر',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
          else ...[
            Slider(
              value: progress,
              onChanged: (value) => controller.seek(
                Duration(
                  milliseconds: (audioState.duration.inMilliseconds * value)
                      .round(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatDuration(audioState.position)),
                Text(formatDuration(audioState.duration)),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: 'سرعة التشغيل',
                onPressed: controller.changeSpeed,
                icon: Text(
                  '${audioState.speed}x',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              if (!isLive)
                IconButton(
                  tooltip: 'السابق',
                  onPressed: audioState.hasPrevious
                      ? controller.previous
                      : null,
                  icon: const Icon(Icons.skip_previous_rounded, size: 38),
                ),
              Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF2A1AD8), Color(0xFF8A4DFF)],
                  ),
                ),
                child: audioState.isLoading || audioState.isBuffering
                    ? const Padding(
                        padding: EdgeInsets.all(22),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : IconButton(
                        tooltip: audioState.isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                        onPressed: controller.togglePlayPause,
                        icon: Icon(
                          audioState.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 43,
                        ),
                      ),
              ),
              if (!isLive)
                IconButton(
                  tooltip: 'التالي',
                  onPressed: audioState.hasNext ? controller.next : null,
                  icon: const Icon(Icons.skip_next_rounded, size: 38),
                ),
              IconButton(
                tooltip: 'قائمة التشغيل',
                onPressed: () => controller.showQueue(context),
                icon: const Icon(Icons.queue_music_rounded, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (track.url.trim().isNotEmpty) ...[
            AudioRecordingButton(track: track),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.showSleepTimer(context),
                  icon: Icon(
                    hasSleepTimer ? Icons.bedtime : Icons.bedtime_outlined,
                  ),
                  label: Text(
                    hasSleepTimer
                        ? formatDuration(audioState.sleepTimerRemaining)
                        : 'مؤقت النوم',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => controller.toggleFavorite(track),
                  icon: Icon(
                    audioState.isFavorite(track.id)
                        ? Icons.favorite
                        : Icons.favorite_border_rounded,
                  ),
                  label: const Text('المفضلة'),
                ),
              ),
            ],
          ),
          if (!isLive) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: controller.toggleShuffle,
                  icon: Icon(
                    Icons.shuffle,
                    color: audioState.shuffleEnabled
                        ? const Color(0xFF2A1AD8)
                        : null,
                  ),
                  label: const Text('عشوائي'),
                ),
                TextButton.icon(
                  onPressed: controller.toggleRepeat,
                  icon: Icon(
                    audioState.repeatEnabled ? Icons.repeat_one : Icons.repeat,
                  ),
                  label: const Text('تكرار'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyPlayer extends StatelessWidget {
  const _EmptyPlayer({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.headphones_rounded,
                  size: 74,
                  color: Color(0xFF6A5AE0),
                ),
                const SizedBox(height: 14),
                const Text(
                  'لا يوجد محتوى قيد التشغيل',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'شغّل البث المباشر أو إذاعة أو ملفاً صوتياً، ثم افتح المشغل من البطاقة المصغّرة.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onClose,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('العودة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
