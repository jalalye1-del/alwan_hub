import 'dart:ui';
import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/providers/audio_provider.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item_type.dart';
import 'package:alwan_hub/features/library/presentation/providers/library_provider.dart';
import 'package:alwan_hub/features/podcasts/domain/entities/podcast_episode.dart';
import 'package:alwan_hub/features/podcasts/domain/mappers/podcast_episode_mapper.dart';

class PodcastVideoPlayerScreen extends ConsumerStatefulWidget {
  const PodcastVideoPlayerScreen({
    super.key,
    required this.episode,
    required this.playlist,
  });

  final PodcastEpisode episode;
  final List<PodcastEpisode> playlist;

  @override
  ConsumerState<PodcastVideoPlayerScreen> createState() =>
      _PodcastVideoPlayerScreenState();
}

class _PodcastVideoPlayerScreenState
    extends ConsumerState<PodcastVideoPlayerScreen> {
  late VideoPlayerController _videoController;
  bool _showControls = true;
  bool _isCinematicMode = false;
  bool _subtitlesEnabled = true;
  bool _isAudioOnly = false; // التحكم بوضع الصوت أو الفيديو

  String _currentQuality = 'تلقائي';
  double _playbackSpeed = 1.0;
  bool _switchingQuality = false;
  final TextEditingController _commentController = TextEditingController();
  final List<_EpisodeComment> _comments = [
    const _EpisodeComment(
      author: 'جلال اليماني',
      message:
          'طرح جميل ومفيد، خصوصاً الجزء المتعلق بتأثير العادات اليومية على قرارات الشراء.',
      timeLabel: 'منذ 12 دقيقة',
      color: Color(0xFF6A5AE0),
    ),
    const _EpisodeComment(
      author: 'أحمد الشامي',
      message: 'موضوع الحلقة مهم، وأتمنى حلقة قادمة تتوسع في الحلول العملية.',
      timeLabel: 'منذ 28 دقيقة',
      color: Colors.teal,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _videoController = _createVideoController(widget.episode.videoUrl);
    _initializeVideo(autoplay: true);
  }

  @override
  void dispose() {
    _videoController.removeListener(_onVideoChanged);
    _videoController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  VideoPlayerController _createVideoController(String url) {
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    controller.addListener(_onVideoChanged);
    return controller;
  }

  Future<void> _initializeVideo({required bool autoplay}) async {
    try {
      await _videoController.initialize();
      await _videoController.setPlaybackSpeed(_playbackSpeed);
      if (autoplay) {
        await ref.read(audioControllerProvider).pause();
        await _videoController.play();
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تحميل الفيديو، يمكنك الاستماع إلى نسخة MP3'),
        ),
      );
    }
  }

  void _onVideoChanged() {
    if (!mounted || _isAudioOnly) return;
    setState(() {});
    if (_videoController.value.isPlaying && _showControls) {
      Future<void>.delayed(const Duration(seconds: 4), () {
        if (mounted && _videoController.value.isPlaying && !_isAudioOnly) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> _changePlaybackSpeed(double speed) async {
    if (_isAudioOnly) {
      await ref.read(audioControllerProvider).setSpeed(speed);
    } else {
      await _videoController.setPlaybackSpeed(speed);
    }
    setState(() => _playbackSpeed = speed);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _changeQuality(String quality) async {
    Navigator.pop(context);
    final nextUrl = widget.episode.videoQualityUrls[quality];
    if (nextUrl == null || nextUrl.isEmpty || quality == _currentQuality) {
      return;
    }
    final oldController = _videoController;
    final oldPosition = oldController.value.position;
    final wasPlaying = oldController.value.isPlaying;
    setState(() {
      _currentQuality = quality;
      _switchingQuality = true;
    });
    oldController.removeListener(_onVideoChanged);
    final nextController = _createVideoController(nextUrl);
    _videoController = nextController;
    try {
      await nextController.initialize();
      await nextController.seekTo(oldPosition);
      await nextController.setPlaybackSpeed(_playbackSpeed);
      if (wasPlaying) await nextController.play();
      await oldController.dispose();
    } finally {
      if (mounted) setState(() => _switchingQuality = false);
    }
  }

  bool get _isMediaPlaying => _isAudioOnly
      ? ref.read(audioPlayerProvider).isPlaying
      : _videoController.value.isPlaying;

  Duration get _mediaPosition => _isAudioOnly
      ? ref.read(audioPlayerProvider).position
      : _videoController.value.position;

  Duration get _mediaDuration => _isAudioOnly
      ? ref.read(audioPlayerProvider).duration
      : _videoController.value.duration;

  Future<void> _toggleMediaMode() async {
    final audioController = ref.read(audioControllerProvider);
    if (!_isAudioOnly) {
      final videoPosition = _videoController.value.position;
      await _videoController.pause();
      if (mounted) setState(() => _isAudioOnly = true);
      try {
        final tracks = widget.playlist
            .map((item) => item.toAudioTrack())
            .toList();
        final index = widget.playlist.indexWhere(
          (item) => item.id == widget.episode.id,
        );
        if (audioController.currentTrack?.id != widget.episode.id) {
          await audioController.loadPlaylist(
            tracks,
            initialIndex: index < 0 ? 0 : index,
          );
        } else if (!audioController.isPlaying) {
          await audioController.resume();
        }
        await audioController.seek(videoPosition);
        await audioController.setSpeed(_playbackSpeed);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تعذر بدء MP3، حاول مرة أخرى')),
          );
        }
      }
      return;
    }

    final audioPosition = audioController.position;
    await audioController.pause();
    if (mounted) setState(() => _isAudioOnly = false);
    if (_videoController.value.isInitialized) {
      await _videoController.seekTo(audioPosition);
      await _videoController.setPlaybackSpeed(_playbackSpeed);
      await _videoController.play();
    }
  }

  Future<void> _togglePlayback() async {
    if (_isAudioOnly) {
      await ref.read(audioControllerProvider).togglePlayPause();
    } else if (_videoController.value.isPlaying) {
      await _videoController.pause();
    } else {
      await ref.read(audioControllerProvider).pause();
      await _videoController.play();
    }
    if (mounted) setState(() => _showControls = true);
  }

  Future<void> _seekBy(Duration delta) async {
    final duration = _mediaDuration;
    var target = _mediaPosition + delta;
    if (target.isNegative) target = Duration.zero;
    if (duration > Duration.zero && target > duration) target = duration;
    if (_isAudioOnly) {
      await ref.read(audioControllerProvider).seek(target);
    } else {
      await _videoController.seekTo(target);
    }
  }

  Future<void> _saveToLibrary() async {
    final repository = ref.read(libraryRepositoryProvider);
    final itemId = 'podcast-library-${widget.episode.id}';
    final existing = await repository.getItem(itemId);
    if (existing == null) {
      await repository.saveItem(
        LibraryItem(
          id: itemId,
          title: widget.episode.title,
          type: LibraryItemType.podcast,
          categoryId: 'podcasts',
          sourceId: widget.episode.id,
          localPath: widget.episode.audioUrl,
          audioUrl: widget.episode.audioUrl,
          videoUrl: widget.episode.videoUrl,
          coverUrl: widget.episode.imageAsset,
          createdAt: DateTime.now(),
        ),
      );
    } else {
      await repository.updateItem(
        existing.copyWith(
          title: widget.episode.title,
          localPath: widget.episode.audioUrl,
          audioUrl: widget.episode.audioUrl,
          videoUrl: widget.episode.videoUrl,
          coverUrl: widget.episode.imageAsset,
        ),
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existing == null
              ? 'تم حفظ نسختي الفيديو وMP3 في مكتبتي'
              : 'تم تحديث الحلقة في مكتبتي بنسختي الفيديو وMP3',
        ),
        backgroundColor: const Color(0xFF00A38C),
      ),
    );
  }

  Future<void> _shareEpisode() async {
    await SharePlus.instance.share(
      ShareParams(
        subject: widget.episode.title,
        text:
            'شاهد أو استمع إلى "${widget.episode.title}" من بودكاست ألوان. ${widget.episode.videoUrl}',
      ),
    );
  }

  // قائمة البث للأجهزة (Cast) مطابقة للفيديو
  void _showCastMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E2C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.cast_connected_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'البث إلى شاشات وأجهزة أخرى',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCastOption('تلفاز الصالة الذكي (Samsung 4K)'),
            _buildCastOption('جهاز Chromecast الصالة'),
            _buildCastOption('جهاز Apple TV المكتب'),
            _buildCastOption('مكبر صوت ذكي (Nest Speaker)'),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'إلغاء البث',
                  style: TextStyle(
                    color: Color(0xFFFF0044),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCastOption(String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم الاتصال بـ $title',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF00B09B),
          ),
        );
      },
    );
  }

  // قوائم السرعة والجودة
  void _showSpeedMenu() {
    final List<double> speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'سرعة التشغيل',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...speeds.map(
              (speed) => ListTile(
                title: Text(
                  '${speed}x',
                  style: TextStyle(
                    color: _playbackSpeed == speed
                        ? const Color(0xFF00B09B)
                        : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: _playbackSpeed == speed
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF00B09B),
                      )
                    : null,
                onTap: () => _changePlaybackSpeed(speed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQualityMenu() {
    final qualities = widget.episode.videoQualityUrls.keys.toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E2C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر جودة البث',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...qualities.map(
              (q) => ListTile(
                title: Text(
                  q,
                  style: TextStyle(
                    color: _currentQuality == q
                        ? const Color(0xFFFF0044)
                        : Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                trailing: _currentQuality == q
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFFFF0044),
                      )
                    : null,
                onTap: () => _changeQuality(q),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(audioPlayerProvider);
    final baseTheme = Theme.of(context);
    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: 'MohammadBoldArt'),
      ),
      child: Scaffold(
        backgroundColor: _isCinematicMode
            ? Colors.black
            : const Color(0xFFF4F6F9),
        appBar: _isCinematicMode ? null : _buildAppBar(),
        body: _isCinematicMode
            ? Center(child: _buildVideoPlayerArea())
            : Column(
                children: [
                  _buildVideoPlayerArea(),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Column(
                            children: [
                              _buildInfoCard(),
                              const SizedBox(height: 16),
                              _buildQuickActionsRow(),
                              const SizedBox(height: 16),
                              _buildEngagementActions(),
                              const SizedBox(height: 16),
                              _buildSubtitlesCard(),
                              const SizedBox(height: 16),
                              _buildCommentsCard(),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF4F6F9),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF1E1E1E),
          size: 30,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.episode.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF1E1E1E),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.cast_connected_rounded,
            color: Color(0xFF1E1E1E),
          ),
          onPressed: _showCastMenu, // ربط زر البث في الـ AppBar أيضاً
        ),
      ],
    );
  }

  // ==========================================
  // منطقة المشغل (صوت أو فيديو) مع الطبقة الثابتة
  // ==========================================
  Widget _buildVideoPlayerArea() {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _isCinematicMode ? double.infinity : 920,
        ),
        child: GestureDetector(
          onTap: () => setState(() => _showControls = !_showControls),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_switchingQuality)
                    const CircularProgressIndicator(color: Color(0xFFFF0044))
                  else if (_isAudioOnly)
                    _buildAudioCover()
                  else if (_videoController.value.isInitialized)
                    VideoPlayer(_videoController)
                  else
                    const CircularProgressIndicator(color: Color(0xFFFF0044)),
                  if (_showControls) _buildControlsOverlay(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioCover() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(widget.episode.imageAsset),
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(Colors.black54, BlendMode.darken),
        ),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2A3A), Color(0xFF1A1A2E)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.headphones_rounded, color: Colors.white, size: 52),
          const SizedBox(height: 8),
          Text(
            widget.episode.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'نسخة MP3 • يستمر التشغيل في الخلفية',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الشريط العلوي للفيديو (سرعة، جودة، وضع التشغيل)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: _toggleMediaMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _isAudioOnly
                          ? const Color(0xFF6A5AE0)
                          : const Color(0xFFFF0044),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isAudioOnly
                              ? Icons.videocam_rounded
                              : Icons.headset_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isAudioOnly ? 'العودة للفيديو' : 'الاستماع MP3',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: _showQualityMenu,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _currentQuality,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _showSpeedMenu,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${_playbackSpeed}x',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: _showCastMenu,
                      child: const Icon(
                        Icons.cast_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () =>
                          setState(() => _isCinematicMode = !_isCinematicMode),
                      child: Icon(
                        _isCinematicMode
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // أزرار التحكم الوسطى
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.replay_10_rounded,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () => _seekBy(const Duration(seconds: -10)),
              ),
              const SizedBox(width: 24),
              InkWell(
                onTap: _togglePlayback,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        _isMediaPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                icon: const Icon(
                  Icons.forward_10_rounded,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () => _seekBy(const Duration(seconds: 10)),
              ),
            ],
          ),

          // شريط التقدم الزمني
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Text(
                  _formatDuration(_mediaPosition),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _isAudioOnly
                      ? SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                          ),
                          child: Slider(
                            value: _mediaDuration.inMilliseconds <= 0
                                ? 0
                                : (_mediaPosition.inMilliseconds /
                                          _mediaDuration.inMilliseconds)
                                      .clamp(0.0, 1.0),
                            onChanged: (value) => ref
                                .read(audioControllerProvider)
                                .seek(_mediaDuration * value),
                            activeColor: const Color(0xFF00B09B),
                            inactiveColor: Colors.white24,
                          ),
                        )
                      : VideoProgressIndicator(
                          _videoController,
                          allowScrubbing: true,
                          colors: VideoProgressColors(
                            playedColor: const Color(0xFF00B09B),
                            bufferedColor: Colors.white.withValues(alpha: 0.3),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.1,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDuration(_mediaDuration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // تصميم البطاقات السفلية الأنيقة
  // ==========================================
  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildInfoCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.episode.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EDFF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'تقديم: ${widget.episode.hostName}',
                  style: const TextStyle(
                    color: Color(0xFF6A5AE0),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.visibility_rounded, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                '${widget.episode.listeners} مشاهدة واستماع',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    final savedItems = ref.watch(libraryItemsProvider).valueOrNull ?? const [];
    final isSaved = savedItems.any(
      (item) => item.sourceId == widget.episode.id,
    );
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _saveToLibrary,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5F3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSaved
                        ? Icons.library_add_check_rounded
                        : Icons.download_rounded,
                    color: const Color(0xFF00B09B),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isSaved ? 'محفوظة في مكتبتي' : 'تحميل الحلقة',
                    style: const TextStyle(
                      color: Color(0xFF00B09B),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _isCinematicMode = !_isCinematicMode),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A3A),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2A2A3A).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isCinematicMode
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'الوضع السينمائي',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEngagementActions() {
    final track = widget.episode.toAudioTrack();
    final isFavorite = ref.watch(audioPlayerProvider).isFavorite(track.id);
    return Row(
      children: [
        Expanded(
          child: _buildSmallAction(
            icon: isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: isFavorite ? 'في المفضلة' : 'إضافة للمفضلة',
            color: const Color(0xFFE84273),
            onTap: () =>
                ref.read(audioControllerProvider).toggleFavorite(track),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSmallAction(
            icon: Icons.ios_share_rounded,
            label: 'مشاركة الحلقة',
            color: const Color(0xFF6A5AE0),
            onTap: _shareEpisode,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSmallAction(
            icon: _isAudioOnly
                ? Icons.headphones_rounded
                : Icons.videocam_rounded,
            label: _isAudioOnly ? 'MP3 مفعل' : 'فيديو HD',
            color: const Color(0xFF188FC5),
            onTap: _toggleMediaMode,
          ),
        ),
      ],
    );
  }

  Widget _buildSmallAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: .18)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitlesCard() {
    return _buildCardContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.subtitles_rounded,
                  color: Color(0xFFFF7A00),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ترجمات الفيديو التلقائية',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'تمكين نصوص الترجمة المتزامنة',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _subtitlesEnabled,
            activeThumbColor: const Color(0xFF00B09B),
            activeTrackColor: const Color(0xFF00B09B).withValues(alpha: 0.3),
            onChanged: (value) => setState(() => _subtitlesEnabled = value),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsCard() {
    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.mode_comment_rounded,
                color: Color(0xFF6A5AE0),
                size: 22,
              ),
              SizedBox(width: 10),
              Text(
                'التعليقات على الحلقة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A5AE0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'شارك رأيك في موضوع «${widget.episode.title}»',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF0F0F0)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: 'اكتب تعليقك على الحلقة وموضوعها...',
                    filled: true,
                    fillColor: const Color(0xFFF8F9FF),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E5F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E5F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF6A5AE0),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'إضافة التعليق',
                onPressed: _addComment,
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5AE0),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(48, 48),
                ),
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'آراء المستمعين والمشاهدين',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${_comments.length} تعليق',
                style: const TextStyle(
                  color: Color(0xFF6A5AE0),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          for (var index = 0; index < _comments.length; index++) ...[
            _buildCommentBubble(_comments[index]),
            if (index != _comments.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  void _addComment() {
    final message = _commentController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اكتب تعليقك أولاً')));
      return;
    }
    setState(() {
      _comments.insert(
        0,
        _EpisodeComment(
          author: 'أنت',
          message: message,
          timeLabel: 'الآن',
          color: const Color(0xFFE64273),
        ),
      );
      _commentController.clear();
    });
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تمت إضافة تعليقك إلى الحلقة'),
        backgroundColor: Color(0xFF6A5AE0),
      ),
    );
  }

  Widget _buildCommentBubble(_EpisodeComment comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: comment.color.withValues(alpha: 0.15),
          child: Text(
            comment.author.substring(0, 1),
            style: TextStyle(
              color: comment.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FF),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
                topRight: Radius.circular(4),
              ),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1E1E1E),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      comment.timeLabel,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.message,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EpisodeComment {
  const _EpisodeComment({
    required this.author,
    required this.message,
    required this.timeLabel,
    required this.color,
  });

  final String author;
  final String message;
  final String timeLabel;
  final Color color;
}
