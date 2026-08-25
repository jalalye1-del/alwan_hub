import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../library/presentation/providers/library_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Timer _navigationTimer;
  VideoPlayerController? _webVideoController;
  bool _webVideoReady = false;

  @override
  void initState() {
    super.initState();

    // استدعاء التهيئة الخاصة بالمكتبة والمجلدات الافتراضية
    Future.microtask(() async {
      await ref.read(libraryInitializerProvider).initialize();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _scale = Tween<double>(
      begin: .95,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    if (kIsWeb) {
      _initializeWebVideo();
    }

    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.go('/home');
    });
  }

  Future<void> _initializeWebVideo() async {
    final videoController = VideoPlayerController.asset(
      'assets/videos/alwan_web_splash.mp4',
    );
    _webVideoController = videoController;

    try {
      await videoController.initialize();
      await videoController.setLooping(false);
      // كتم الصوت يسمح بالتشغيل التلقائي في متصفحات الويب الحديثة.
      await videoController.setVolume(0);
      // المصدر أقصر قليلاً من ثلاث ثوانٍ؛ نضبط سرعته لملء زمن
      // شاشة الترحيب المطلوب من دون قص أو تكرار مفاجئ.
      final sourceMilliseconds =
          videoController.value.duration.inMilliseconds.toDouble();
      if (sourceMilliseconds > 0) {
        await videoController.setPlaybackSpeed(
          (sourceMilliseconds / 3000).clamp(.1, 10),
        );
      }
      await videoController.seekTo(Duration.zero);
      await videoController.play();
      if (!mounted) return;
      setState(() => _webVideoReady = true);
    } catch (error, stackTrace) {
      debugPrint('تعذر تشغيل فيديو شاشة الترحيب: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _navigationTimer.cancel();
    _webVideoController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _WebVideoSplash(
        controller: _webVideoController,
        isReady: _webVideoReady,
      );
    }

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/splash_welcome.png',
                  width: 315,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              top: 80,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Center(
                    child: Image.asset(
                      'assets/images/splash_logo.png',
                      width: 245,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 220,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/splash_people1.png',
                  width: size.width,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/splash_title.png',
                  width: 325,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned(
              bottom: 42,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/Loading.png',
                    width: 34,
                    height: 34,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'جاري التحميل',
                    style: TextStyle(
                      fontFamily: 'MohammadBoldArt',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2A2A2A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WebVideoSplash extends StatelessWidget {
  const _WebVideoSplash({required this.controller, required this.isReady});

  final VideoPlayerController? controller;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    final videoController = controller;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Semantics(
        label: 'شاشة ألوان الترحيبية',
        image: true,
        child: SizedBox.expand(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: isReady && videoController != null
                ? FittedBox(
                    key: const ValueKey('web-splash-video'),
                    fit: BoxFit.cover,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: videoController.value.size.width,
                      height: videoController.value.size.height,
                      child: VideoPlayer(videoController),
                    ),
                  )
                : const Center(
                    key: ValueKey('web-splash-loading'),
                    child: Image(
                      image: AssetImage('assets/images/splash_logo.png'),
                      width: 250,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
