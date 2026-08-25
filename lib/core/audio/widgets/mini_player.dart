// lib/core/audio/widgets/mini_player.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/providers/audio_provider.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/audio/screens/now_playing_screen.dart';
import 'package:alwan_hub/core/recording/presentation/widgets/audio_recording_button.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/widgets/adaptive_content_image.dart';

class MiniPlayer extends ConsumerStatefulWidget {
  const MiniPlayer({super.key});

  @override
  ConsumerState<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends ConsumerState<MiniPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  bool _openingPlayer = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _openNowPlaying() async {
    if (_openingPlayer || !mounted) return;
    _openingPlayer = true;
    try {
      await Navigator.of(context, rootNavigator: true).push<void>(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          settings: const RouteSettings(name: '/player'),
          builder: (_) => const NowPlayingScreen(),
        ),
      );
    } finally {
      _openingPlayer = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioPlayerProvider);
    final audioController = ref.read(audioControllerProvider);

    final track = audioState.currentTrack;

    if (track == null) {
      return const SizedBox.shrink();
    }

    final isFm =
        track.sourceType == AudioSourceType.fm || track.category == 'إذاعات FM';
    final isLive = track.isLiveStream;
    final miniHeight = context.responsive.value(
      compact: 86,
      medium: 90,
      expanded: 94,
    );

    ref.listen<bool>(audioPlayerProvider.select((state) => state.isPlaying), (
      previous,
      isPlaying,
    ) {
      if (isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    });

    if (audioState.isPlaying && !_rotationController.isAnimating) {
      _rotationController.repeat();
    } else if (!audioState.isPlaying && _rotationController.isAnimating) {
      _rotationController.stop();
    }

    final progress = isLive
        ? 0.0
        : audioState.duration.inMilliseconds <= 0
        ? 0.0
        : (audioState.position.inMilliseconds /
                  audioState.duration.inMilliseconds)
              .clamp(0.0, 1.0);

    return SizedBox(
      height: miniHeight + 18,
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _openNowPlaying,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              height: miniHeight,
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      color: Colors.white.withValues(alpha: .92),
                      border: Border.all(color: const Color(0xFFE6E9FF)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6D5DF6).withValues(alpha: .12),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: RotationTransition(
                            key: ValueKey(track.id),
                            turns: _rotationController,
                            child: Container(
                              width:
                                  54, // تم تصغير الأيقونة قليلاً لتوفير المساحة
                              height: 54,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2A1AD8),
                                    Color(0xFF8A4DFF),
                                  ],
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AdaptiveContentImage(
                                  source:
                                      track.presenterImage ??
                                      track.programImage ??
                                      track.imageUrl ??
                                      '',
                                  width: 54,
                                  height: 54,
                                  fit: BoxFit.cover,
                                  semanticLabel: track.title,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      track.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14, // تصغير بسيط
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1F2142),
                                      ),
                                    ),
                                  ),
                                  if (isLive)
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'LIVE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isFm
                                    ? (track.presenterName ?? track.subtitle)
                                    : (track.presenterName != null &&
                                              track.presenterName!.isNotEmpty
                                          ? track.presenterName!
                                          : (track.isLiveStream
                                                ? 'يبث الآن'
                                                : track.subtitle)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isLive
                                      ? Colors.red
                                      : Colors.grey.shade700,
                                ),
                              ),
                              if (!isLive) ...[
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    minHeight: 4,
                                    value: progress,
                                    backgroundColor: const Color(0xFFE9ECFF),
                                    valueColor: const AlwaysStoppedAnimation(
                                      Color(0xFF2A1AD8),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // 🟢 الأزرار مبنية بشكل مرن الآن (لا خطوط صفراء وسوداء بعد اليوم)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (track.url.trim().isNotEmpty)
                              AudioRecordingButton(track: track, compact: true),
                            const SizedBox(width: 4),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: 20,
                              onPressed: () async {
                                await audioController.togglePlayPause();
                              },
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: Icon(
                                  audioState.isPlaying
                                      ? Icons.pause_circle_filled_rounded
                                      : Icons.play_circle_fill_rounded,
                                  key: ValueKey(audioState.isPlaying),
                                  size: 38,
                                  color: const Color(0xFF2A1AD8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: 20,
                              onPressed: () {
                                _openNowPlaying();
                              },
                              icon: const Icon(
                                Icons.keyboard_arrow_up_rounded,
                                size: 30,
                                color: Color(0xFF2A1AD8),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
