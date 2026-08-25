import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_typography.dart';
import 'package:alwan_hub/core/widgets/adaptive_content_image.dart';
import 'package:alwan_hub/features/interaction/presentation/share_and_chat_screen.dart';
import 'package:alwan_hub/features/programs/domain/entities/fm_program.dart';
import 'package:alwan_hub/features/programs/presentation/providers/fm_program_provider.dart';

class LiveProgramCard extends ConsumerStatefulWidget {
  const LiveProgramCard({
    super.key,
    this.programTitle,
    this.presenterName,
    this.broadcastTime,
    this.presenterImage,
    this.streamUrl,
    this.stationName = 'ألوان FM 88.7',
  });

  final String? programTitle;
  final String? presenterName;
  final String? broadcastTime;
  final String? presenterImage;
  final String? streamUrl;
  final String stationName;

  @override
  ConsumerState<LiveProgramCard> createState() => _LiveProgramCardState();
}

class _LiveProgramCardState extends ConsumerState<LiveProgramCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: .35, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final dashboardProgram = ref
        .watch(liveFmProgramProvider)
        .maybeWhen(data: (program) => program, orElse: () => null);
    final programTitle =
        widget.programTitle ?? dashboardProgram?.title ?? 'صباحكم ألوان';
    final presenterName =
        widget.presenterName ??
        dashboardProgram?.presenterName ??
        'الإعلامية شروق أحمد';
    final broadcastTime =
        widget.broadcastTime ??
        dashboardProgram?.broadcastTimeLabel ??
        '09:00 - 10:30 AM';
    final presenterImage =
        widget.presenterImage ??
        dashboardProgram?.imageUrl ??
        'assets/images/shurooq.jpg';
    final streamUrl =
        widget.streamUrl ??
        dashboardProgram?.streamUrl ??
        'https://s9.voscast.com:9617/stream';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 390;
        final isVeryNarrow = constraints.maxWidth < 350;
        final baseImageSize = responsive.value(
          compact: isVeryNarrow ? 68 : (isNarrow ? 82 : 100),
          medium: 116,
          expanded: 128,
        );
        final imageSize = baseImageSize * 2;
        final imageInset = responsive.value(
          compact: isVeryNarrow ? 28 : 44,
          medium: 52,
          expanded: 60,
        );
        final shareEdgeOffset = Directionality.of(context) == TextDirection.rtl
            ? -8.0
            : 8.0;
        final horizontalPadding = responsive.value(
          compact: isVeryNarrow ? 12 : 16,
          medium: 22,
          expanded: 28,
        );

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: responsive.value(compact: 12, medium: 18, expanded: 20),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2A1AD8), Color(0xFF7231EC), Color(0xFFB948FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7231EC).withValues(alpha: .3),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _LiveBadge(animation: _pulseAnimation),
                      Transform.translate(
                        offset: Offset(shareEdgeOffset, 0),
                        child: IconButton(
                          tooltip: context.translateInterface(
                            'مشاركة البرنامج',
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 34,
                            height: 34,
                          ),
                          onPressed: () => Navigator.push<void>(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) => ShareAndChatScreen(
                                program: dashboardProgram,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: imageSize - 40,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                programTitle,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsive.value(
                                    compact: isVeryNarrow
                                        ? 16
                                        : (isNarrow ? 18 : 21),
                                    medium: 24,
                                    expanded: 27,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                presenterName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .86),
                                  fontSize: responsive.value(
                                    compact: 12,
                                    medium: 14,
                                    expanded: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 15,
                                    color: Colors.white.withValues(alpha: .85),
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      broadcastTime,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: .85,
                                        ),
                                        fontSize: responsive.value(
                                          compact: 11,
                                          medium: 12,
                                          expanded: 13,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: imageSize + imageInset),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Actions(
                    isNarrow: isNarrow,
                    isVeryNarrow: isVeryNarrow,
                    onListen: () => _playLiveStream(
                      program: dashboardProgram,
                      title: programTitle,
                      presenterName: presenterName,
                      presenterImage: presenterImage,
                      streamUrl: streamUrl,
                    ),
                    onChat: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ShareAndChatScreen(
                          program: dashboardProgram,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              PositionedDirectional(
                top: 0,
                end: imageInset,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (_, child) => Container(
                    width: imageSize,
                    height: imageSize,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(
                            alpha: .35 * _animationController.value,
                          ),
                          blurRadius: 18 * _animationController.value,
                          spreadRadius: 7 * _animationController.value,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: AdaptiveContentImage(
                        source: presenterImage,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.cover,
                        semanticLabel: presenterName,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _playLiveStream({
    required FmProgram? program,
    required String title,
    required String presenterName,
    required String presenterImage,
    required String streamUrl,
  }) async {
    if (streamUrl.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رابط البث غير متوفر حالياً.')),
      );
      return;
    }

    await ref
        .read(audioControllerProvider)
        .play(
          AudioTrack(
            id: program == null ? 'live_alwan_fm' : 'fm-program-${program.id}',
            title: title,
            subtitle: widget.stationName,
            url: streamUrl,
            imageUrl: presenterImage,
            presenterName: presenterName,
            isLiveStream: true,
            isFm: true,
            sourceType: AudioSourceType.fm,
            category: 'برامج FM',
          ),
        );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: animation,
            child: const Icon(Icons.circle, size: 8, color: Colors.white),
          ),
          const SizedBox(width: 6),
          const Text(
            'مباشر الآن',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.isNarrow,
    required this.isVeryNarrow,
    required this.onListen,
    required this.onChat,
  });

  final bool isNarrow;
  final bool isVeryNarrow;
  final VoidCallback onListen;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final actionTextStyle = TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: isVeryNarrow ? 11 : 14,
      fontWeight: FontWeight.w700,
    );
    final listenButton = ElevatedButton.icon(
      onPressed: onListen,
      icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
      label: Text(
        isNarrow ? 'استمع الآن' : 'استمع للبث المباشر',
        key: const ValueKey('live-listen-label'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: actionTextStyle,
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: EdgeInsets.symmetric(
          horizontal: isVeryNarrow ? 5 : (isNarrow ? 8 : 14),
        ),
        textStyle: actionTextStyle,
      ),
    );
    final chatButton = ElevatedButton.icon(
      onPressed: onChat,
      icon: const Icon(Icons.forum_outlined, size: 18),
      label: Text(
        'شارك ودردش',
        key: const ValueKey('live-chat-label'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: actionTextStyle,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: .18),
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 44),
        padding: EdgeInsets.symmetric(
          horizontal: isVeryNarrow ? 5 : (isNarrow ? 8 : 14),
        ),
        textStyle: actionTextStyle,
        side: BorderSide(color: Colors.white.withValues(alpha: .3)),
      ),
    );

    return Row(
      children: [
        Expanded(flex: 3, child: listenButton),
        SizedBox(width: isNarrow ? 8 : 10),
        Expanded(flex: 2, child: chatButton),
      ],
    );
  }
}
