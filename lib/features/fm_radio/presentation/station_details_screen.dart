// lib/features/fm_radio/presentation/station_details_screen.dart

import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/providers/audio_provider.dart';
import 'package:alwan_hub/features/fm_radio/domain/models/fm_station.dart';
import 'package:alwan_hub/features/fm_radio/presentation/providers/fm_station_provider.dart';

// 🟢 تم تحويل الشاشة إلى StatefulWidget لدعم حركة "عرض المزيد" للوصف
class StationDetailsScreen extends ConsumerStatefulWidget {
  final FmStation station;

  const StationDetailsScreen({
    super.key,
    required this.station,
  });

  @override
  ConsumerState<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends ConsumerState<StationDetailsScreen> {
  // 🟢 8. متغير للتحكم في تمدد الوصف
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final station = widget.station;
    final audioState = ref.watch(audioPlayerProvider);
    final activeStation = ref.watch(activeStationProvider);
    final isPlaying = audioState.isPlaying && activeStation?.id == station.id;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      // إزالة SafeArea من الأعلى للسماح للصورة بتغطية الشاشة بالكامل
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          ///==============================
          /// 7. Header (Spotify Style) + Hero 
          ///==============================
          SliverAppBar(
            expandedHeight: 360,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xffF7F8FC),
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _circleButton(
                icon: Icons.arrow_back_ios_new,
                onTap: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _circleButton(
                  icon: Icons.share_rounded,
                  onTap: () {
                    SharePlus.instance.share(
                      ShareParams(text: "استمع إلى ${station.name} عبر منصة ألوان"),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Hero(
                tag: "station_${station.id}",
                transitionOnUserGestures: true,
                // 🟢 10. تحسين الـ Hero بـ FadeTransition ليتطابق مع الشاشة السابقة
                flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                  return FadeTransition(
                    opacity: animation,
                    child: toHeroContext.widget,
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 🟢 1 & 2. استخدام صورة الغلاف ودالة _buildImage الذكية
                    _buildImage(station.coverImage.isNotEmpty ? station.coverImage : station.logo),
                    
                    // 🟢 7. التدرج اللوني فوق الصورة لدمجها مع الواجهة
                    Positioned(
                      bottom: -1, left: 0, right: 0,
                      child: Container(
                        height: 120,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color(0xffF7F8FC),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          ///====================================
          /// Station Information
          ///====================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    station.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xff24125C)),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "${station.country} • ${station.frequency}",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _glassInfoCard(
                          icon: Icons.public,
                          label: station.country,
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      // 🟢 6. بطاقة المستمعين بصياغة "عبر ألوان"
                      Expanded(
                        child: _glassInfoCard(
                          icon: Icons.headphones,
                          label: NumberFormat.compact().format(station.listeners),
                          subtitle: "مستمع عبر ألوان",
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      Expanded(
                        child: _glassInfoCard(
                          icon: Icons.star,
                          label: station.rating.toString(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      
                      Expanded(
                        child: _glassInfoCard(
                          customTopWidget: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: station.isLive ? Colors.green : Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.radio_rounded, color: Color(0xff4E21B3), size: 18),
                            ],
                          ),
                          label: station.isLive ? "يبث الآن" : "متوقف",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _actionButton(
                        icon: station.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        onTap: () async {
                          await ref.read(fmStationRepositoryProvider).toggleFavorite(station.id);
                          ref.invalidate(favoriteFmStationsProvider);
                        },
                      ),
                      const SizedBox(width: 24),

                      // 🟢 5. زر التشغيل مع النص التوضيحي أسفله
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _playButton(
                            isPlaying: isPlaying,
                            onTap: () {
                              ref.read(activeStationProvider.notifier).setActiveStation(station);
                              if (isPlaying) {
                                ref.read(audioControllerProvider).pause();
                              } else {
                                ref.read(audioControllerProvider).play(station.toAudioTrack());
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isPlaying ? "إيقاف البث" : "استمع الآن",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xff24125C),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),

                      _actionButton(
                        icon: Icons.share_rounded,
                        color: const Color(0xff4E21B3),
                        onTap: () {
                          SharePlus.instance.share(ShareParams(text: "استمع إلى ${station.name} عبر منصة ألوان"));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 34),
                ],
              ),
            ),
          ),

          ///====================================
          /// معلومات الإذاعة
          ///====================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // 🟢 9. بطاقة البث الحالي (تظهر فقط إذا كان البرنامج متوفراً)
                  if (station.currentProgram.isNotEmpty) ...[
                    const Text("البث الحالي", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xff24125C))),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: .03), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                        border: Border.all(color: const Color(0xff4E21B3).withValues(alpha: 0.1), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: const Color(0xffEEF2FF), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.podcasts_rounded, color: Color(0xff4E21B3), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("اسم البرنامج", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                                const SizedBox(height: 4),
                                Text(
                                  station.currentProgram,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xff24125C)),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.graphic_eq_rounded, color: Colors.green),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  const Text("معلومات الإذاعة", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xff24125C))),
                  const SizedBox(height: 16),

                  _infoCardContainer(Icons.radio, "اسم الإذاعة", station.name),
                  const SizedBox(height: 12),
                  _infoCardContainer(Icons.graphic_eq, "التردد", station.frequency),
                  const SizedBox(height: 12),
                  _infoCardContainer(Icons.public, "الدولة", station.country),
                  const SizedBox(height: 12),
                  
                  // 🟢 3. إضافة المعلومات الجديدة ديناميكياً
                  if (station.city.isNotEmpty) ...[
                    _infoCardContainer(Icons.location_city, "المدينة", station.city),
                    const SizedBox(height: 12),
                  ],
                  if (station.language.isNotEmpty) ...[
                    _infoCardContainer(Icons.language, "اللغة", station.language),
                    const SizedBox(height: 12),
                  ],
                  if (station.category.isNotEmpty) ...[
                    _infoCardContainer(Icons.category, "التصنيف", station.category),
                    const SizedBox(height: 12),
                  ],
                  if (station.foundedYear > 0) ...[
                    _infoCardContainer(Icons.calendar_today, "سنة التأسيس", station.foundedYear.toString()),
                    const SizedBox(height: 12),
                  ],
                  
                  _infoCardContainer(Icons.headphones, "عدد المستمعين", NumberFormat.decimalPattern().format(station.listeners)),
                  const SizedBox(height: 12),
                  _infoCardContainer(Icons.star, "التقييم", station.rating.toString()),

                  const SizedBox(height: 28),

                  // 🟢 4. وسائل التواصل (تظهر فقط في حال وجود روابط)
                  if (_hasSocialMedia(station)) ...[
                    const Text("وسائل التواصل", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xff24125C))),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        if (station.facebookUrl?.isNotEmpty == true)
                          _socialCircleButton(icon: Icons.facebook, onTap: () {}),
                        if (station.instagramUrl?.isNotEmpty == true)
                          _socialCircleButton(icon: Icons.camera_alt_outlined, onTap: () {}),
                        if (station.website?.isNotEmpty == true)
                          _socialCircleButton(icon: Icons.language, onTap: () {}),
                        if (station.email?.isNotEmpty == true)
                          _socialCircleButton(icon: Icons.email_outlined, onTap: () {}),
                        if (station.studioWhatsapp?.isNotEmpty == true)
                          _socialCircleButton(icon: Icons.chat_outlined, onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],

                  const Text("نبذة عن الإذاعة", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xff24125C))),
                  const SizedBox(height: 14),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: .04), blurRadius: 16, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🟢 8. الوصف مع AnimatedSize وزر "عرض المزيد"
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Text(
                            station.description.isNotEmpty ? station.description : "لا توجد نبذة متوفرة عن هذه الإذاعة حالياً.",
                            maxLines: _isDescriptionExpanded ? null : 3,
                            overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.fade,
                            style: const TextStyle(height: 1.8, fontSize: 14, color: Color(0xff444444)),
                          ),
                        ),
                        if (station.description.length > 100)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isDescriptionExpanded = !_isDescriptionExpanded;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                _isDescriptionExpanded ? "إخفاء" : "عرض المزيد",
                                style: const TextStyle(color: Color(0xff4E21B3), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🟢 4. دالة التحقق من وجود حسابات تواصل اجتماعي
  bool _hasSocialMedia(FmStation station) {
    return (station.facebookUrl?.isNotEmpty == true) ||
           (station.instagramUrl?.isNotEmpty == true) ||
           (station.website?.isNotEmpty == true) ||
           (station.email?.isNotEmpty == true) ||
           (station.studioWhatsapp?.isNotEmpty == true);
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withValues(alpha: 0.85), // شفافية خفيفة لتندمج مع الصور
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48, height: 48,
          child: Icon(icon, color: const Color(0xff4E21B3), size: 22),
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: 56, height: 56,
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  Widget _playButton({required bool isPlaying, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 76, height: 76,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [Color(0xff4F46E5), Color(0xff7C3AED)]),
          boxShadow: [
             BoxShadow(color: Color(0xff7C3AED), blurRadius: 16, offset: Offset(0, 4)),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white, size: 38,
        ),
      ),
    );
  }

  Widget _glassInfoCard({
    IconData? icon,
    Widget? customTopWidget,
    required String label,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          customTopWidget ?? Icon(icon, color: const Color(0xff4E21B3), size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xff24125C)),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
          ]
        ],
      ),
    );
  }

  Widget _infoCardContainer(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: .03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xffEEF2FF), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xff4E21B3), size: 18),
          ),
          const SizedBox(width: 14),
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xff24125C))),
        ],
      ),
    );
  }

  Widget _socialCircleButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 56, height: 56,
          child: Icon(icon, color: const Color(0xff4E21B3), size: 22),
        ),
      ),
    );
  }

  // 🟢 2. دالة معالجة الصور التي تدعم الإنترنت والملفات المحلية (Assets)
  Widget _buildImage(String path) {
    if (path.isEmpty) {
      return _buildPlaceholder();
    }
    
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 250),
        fadeOutDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => Container(
          color: const Color(0xffEEF2FF),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    } else if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    } 
    
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xffEEF2FF),
      child: const Icon(Icons.radio_rounded, color: Color(0xff5C39E6), size: 42),
    );
  }
}
