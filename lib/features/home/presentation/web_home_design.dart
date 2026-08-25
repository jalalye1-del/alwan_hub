import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/audio/providers/audio_provider.dart';
import 'package:alwan_hub/core/router/app_router.dart';
import 'package:alwan_hub/features/interaction/presentation/share_and_chat_screen.dart';
import 'package:alwan_hub/features/programs/domain/entities/fm_program.dart';
import 'package:alwan_hub/features/programs/presentation/providers/fm_program_provider.dart';

/// نسخة سطح المكتب المطابقة للتصميم المرجعي 1920 × 1080.
///
/// الصورة المرجعية هي طبقة العرض الأساسية كي تبقى المسافات والألوان والصور
/// مطابقة تماماً، بينما توفر المناطق الشفافة فوقها الوظائف الفعلية للتطبيق.
class WebHomeDesign extends ConsumerWidget {
  const WebHomeDesign({
    super.key,
    required this.onHomeTap,
    required this.onProgramsTap,
    required this.onStationsTap,
    required this.onLibraryTap,
    required this.onMoreTap,
    required this.onNotificationsTap,
    required this.onProfileTap,
  });

  final VoidCallback onHomeTap;
  final VoidCallback onProgramsTap;
  final VoidCallback onStationsTap;
  final VoidCallback onLibraryTap;
  final VoidCallback onMoreTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onProfileTap;

  static const Size designSize = Size(1920, 1080);
  static const String referenceAsset =
      'assets/images/web/home_reference_1920x1080.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref
        .watch(liveFmProgramProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    final audioState = ref.watch(audioPlayerProvider);
    final liveTrack = _liveTrack(program);
    final isCurrentLiveTrack = audioState.currentTrack?.id == liveTrack.id;

    return ColoredBox(
      color: Colors.white,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox.fromSize(
            size: designSize,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Image(
                    key: ValueKey('web-home-reference'),
                    image: AssetImage(referenceAsset),
                    width: 1920,
                    height: 1080,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                    semanticLabel: 'الواجهة الرئيسية لإذاعة ألوان FM',
                  ),

                  // شريط التنقل العلوي.
                  _Hotspot(
                    key: const ValueKey('web-nav-home'),
                    rect: const Rect.fromLTWH(1534, 79, 120, 86),
                    label: 'الرئيسية',
                    onTap: onHomeTap,
                  ),
                  _Hotspot(
                    key: const ValueKey('web-nav-programs'),
                    rect: const Rect.fromLTWH(1350, 79, 140, 86),
                    label: 'البرامج',
                    onTap: onProgramsTap,
                  ),
                  _Hotspot(
                    key: const ValueKey('web-nav-lounge'),
                    rect: const Rect.fromLTWH(1162, 79, 160, 86),
                    label: 'الاستراحة',
                    onTap: () => context.pushNamed(AppRoutes.lounge),
                  ),
                  _Hotspot(
                    key: const ValueKey('web-nav-stations'),
                    rect: const Rect.fromLTWH(981, 79, 150, 86),
                    label: 'إذاعات FM',
                    onTap: onStationsTap,
                  ),
                  _Hotspot(
                    key: const ValueKey('web-nav-library'),
                    rect: const Rect.fromLTWH(809, 79, 130, 86),
                    label: 'مكتبتي',
                    onTap: onLibraryTap,
                  ),
                  _Hotspot(
                    key: const ValueKey('web-nav-more'),
                    rect: const Rect.fromLTWH(625, 79, 145, 86),
                    label: 'المزيد',
                    onTap: onMoreTap,
                  ),
                  _Hotspot(
                    key: const ValueKey('web-theme'),
                    rect: const Rect.fromLTWH(548, 90, 72, 65),
                    label: 'المظهر',
                    onTap: () => context.pushNamed(AppRoutes.appearance),
                  ),
                  _Hotspot(
                    key: const ValueKey('web-search'),
                    rect: const Rect.fromLTWH(450, 90, 72, 65),
                    label: 'البحث',
                    onTap: () => _showSearchHint(context),
                  ),
                  _Hotspot(
                    key: const ValueKey('web-notifications'),
                    rect: const Rect.fromLTWH(361, 89, 72, 66),
                    label: 'الإشعارات',
                    onTap: onNotificationsTap,
                  ),
                  _Hotspot(
                    key: const ValueKey('web-login'),
                    rect: const Rect.fromLTWH(70, 83, 276, 83),
                    label: 'تسجيل الدخول',
                    onTap: onProfileTap,
                  ),

                  // إجراءات البرنامج المباشر في منتصف الصفحة.
                  _Hotspot(
                    key: const ValueKey('web-listen-now'),
                    rect: const Rect.fromLTWH(437, 641, 306, 98),
                    label: isCurrentLiveTrack && audioState.isPlaying
                        ? 'إيقاف البث مؤقتاً'
                        : 'الاستماع الآن',
                    onTap: () => _toggleLive(ref, liveTrack),
                  ),
                  _Hotspot(
                    key: const ValueKey('web-favorite-main'),
                    rect: const Rect.fromLTWH(350, 648, 84, 91),
                    label: 'إضافة البرنامج إلى المفضلة',
                    onTap: () => ref
                        .read(audioControllerProvider)
                        .toggleFavorite(liveTrack),
                  ),
                  _Hotspot(
                    key: const ValueKey('web-share-main'),
                    rect: const Rect.fromLTWH(754, 642, 74, 96),
                    label: 'مشاركة البرنامج',
                    onTap: () => _openInteraction(context, program),
                  ),

                  // شريط المشغل السفلي داخل التصميم.
                  _Hotspot(
                    key: const ValueKey('web-player-previous'),
                    rect: const Rect.fromLTWH(1083, 978, 67, 70),
                    label: 'السابق',
                    onTap: () => ref.read(audioControllerProvider).previous(),
                  ),
                  _Hotspot(
                    key: const ValueKey('web-player-toggle'),
                    rect: const Rect.fromLTWH(1150, 963, 92, 92),
                    label: isCurrentLiveTrack && audioState.isPlaying
                        ? 'إيقاف مؤقت'
                        : 'تشغيل',
                    onTap: () => _toggleLive(ref, liveTrack),
                  ),
                  _Hotspot(
                    key: const ValueKey('web-player-next'),
                    rect: const Rect.fromLTWH(1242, 978, 69, 70),
                    label: 'التالي',
                    onTap: () => ref.read(audioControllerProvider).next(),
                  ),
                  _Hotspot(
                    key: const ValueKey('web-favorite-player'),
                    rect: const Rect.fromLTWH(1303, 965, 82, 90),
                    label: 'المفضلة',
                    onTap: () => ref
                        .read(audioControllerProvider)
                        .toggleFavorite(liveTrack),
                  ),
                  _VolumeHotspot(
                    key: const ValueKey('web-volume'),
                    rect: const Rect.fromLTWH(1463, 987, 350, 58),
                    value: audioState.volume,
                    onChanged: (value) =>
                        ref.read(audioControllerProvider).setVolume(value),
                  ),

                  _AlwanAiWebButton(
                    onTap: () => context.pushNamed(
                      AppRoutes.alwanAi,
                      queryParameters: const {'listen': '1'},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  AudioTrack _liveTrack(FmProgram? program) {
    final image = program?.imageUrl.trim();
    return AudioTrack(
      id: program == null ? 'live_alwan_fm' : 'fm-program-${program.id}',
      title: program?.title.trim().isNotEmpty == true
          ? program!.title
          : 'صباحكم ألوان',
      subtitle: 'ألوان FM 88.7',
      url: program?.streamUrl.trim().isNotEmpty == true
          ? program!.streamUrl
          : 'https://s9.voscast.com:9617/stream',
      imageUrl: image?.isNotEmpty == true ? image : 'assets/images/shurooq.jpg',
      presenterName: program?.presenterName.trim().isNotEmpty == true
          ? program!.presenterName
          : 'الإعلامية شروق أحمد',
      isLiveStream: true,
      isFm: true,
      sourceType: AudioSourceType.fm,
      category: 'برامج FM',
    );
  }

  Future<void> _toggleLive(WidgetRef ref, AudioTrack track) async {
    final controller = ref.read(audioControllerProvider);
    if (controller.currentTrack?.id == track.id) {
      await controller.togglePlayPause();
      return;
    }
    await controller.play(track);
  }

  void _openInteraction(BuildContext context, FmProgram? program) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ShareAndChatScreen(program: program),
      ),
    );
  }

  void _showSearchHint(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث في ألوان'),
        content: const Text('سيتم ربط البحث الشامل في المرحلة التالية.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

class _AlwanAiWebButton extends StatelessWidget {
  const _AlwanAiWebButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: const Rect.fromLTWH(1812, 790, 84, 84),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          key: const ValueKey('web-alwan-ai-button'),
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF7625DA),
                  Color(0xFF1769E8),
                  Color(0xFF05A9C7),
                ],
              ),
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x446C27D9),
                  blurRadius: 24,
                  offset: Offset(0, 9),
                ),
              ],
            ),
            child: const Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                Positioned(
                  left: 1,
                  bottom: 1,
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.mic_rounded,
                      color: Color(0xFF6528D5),
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hotspot extends StatelessWidget {
  const _Hotspot({
    super.key,
    required this.rect,
    required this.label,
    required this.onTap,
  });

  final Rect rect;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: rect,
      child: Semantics(
        label: label,
        button: true,
        child: Tooltip(
          message: label,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                hoverColor: Colors.transparent,
                splashColor: const Color(0x110B00AD),
                highlightColor: Colors.transparent,
                onTap: onTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VolumeHotspot extends StatelessWidget {
  const _VolumeHotspot({
    super.key,
    required this.rect,
    required this.value,
    required this.onChanged,
  });

  final Rect rect;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    void update(Offset localPosition) {
      onChanged((localPosition.dx / rect.width).clamp(0.0, 1.0));
    }

    return Positioned.fromRect(
      rect: rect,
      child: Semantics(
        label: 'مستوى الصوت',
        slider: true,
        value: '${(value * 100).round()}%',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => update(details.localPosition),
            onHorizontalDragUpdate: (details) => update(details.localPosition),
          ),
        ),
      ),
    );
  }
}
