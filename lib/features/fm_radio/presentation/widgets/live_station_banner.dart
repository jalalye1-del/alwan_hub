// lib/features/fm_radio/presentation/widgets/live_station_banner.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:intl/intl.dart';
import '../../domain/models/fm_station.dart';
import '../station_details_screen.dart';

class LiveStationBanner extends StatelessWidget {
  final FmStation station;
  final bool isPlaying;
  final VoidCallback? onPlayToggle;

  const LiveStationBanner({
    super.key,
    required this.station,
    required this.isPlaying,
    this.onPlayToggle,
  });

  @override
  Widget build(BuildContext context) {
    // 🟢 7. تحسين الـ Gesture باستخدام Material و InkWell لتأثير Ripple احترافي
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StationDetailsScreen(station: station)),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff6C3CF3).withValues(alpha: 0.3),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 🟢 1. استخدام صورة الغلاف كخلفية
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: _buildSafeImage(
                    station.coverImage.isNotEmpty ? station.coverImage : station.logo,
                  ),
                ),
              ),
              
              // 🟢 1. طبقة التدرج فوق صورة الغلاف لضمان وضوح النصوص
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black54,
                        const Color(0xff24125C).withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                ),
              ),

              // تأثيرات زجاجية وإضاءة في الخلفية
              Positioned(
                top: -50,
                left: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                right: -20,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 118,
                      height: 118,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      // 🟢 3. استخدام Hero لربط صورة الشعار بشاشة التفاصيل بانسجام
                      child: Hero(
                        tag: 'station_${station.id}',
                        transitionOnUserGestures: true,
                        flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
                          return FadeTransition(opacity: animation, child: toHeroContext.widget);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: _buildSafeImage(station.logo),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 18),
                            child: Row(
                              children: [
                                if (station.isLive) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(radius: 4, backgroundColor: Colors.white),
                                        SizedBox(width: 4),
                                        Text(
                                          "مباشر الآن",
                                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  // 🟢 2. معالجة التردد لمنع تكرار كلمة FM
                                  child: Text(
                                    station.frequency.contains('FM') ? station.frequency : "${station.frequency} FM",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),

                          Text(
                            station.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          
                          // 🟢 5. عرض "البث المباشر" افتراضياً في حال عدم وجود برنامج حالي
                          Text(
                            station.currentProgram.isNotEmpty ? station.currentProgram : "البث المباشر",
                            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              // 🟢 4. استخدام مكون الزر الجديد لإضافة تأثير النبض (AnimatedScale)
                              _AnimatedPlayButton(
                                isPlaying: isPlaying,
                                onTap: onPlayToggle,
                              ),
                              const Spacer(),
                              
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.headphones_rounded, color: Colors.white.withValues(alpha: 0.9), size: 18),
                                  const SizedBox(height: 2),
                                  Text(
                                    NumberFormat.compact().format(station.listeners),
                                    style: const TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.w900, 
                                      color: Colors.white,
                                    ),
                                  ),
                                  // 🟢 6. استخدام "مستمع عبر ألوان" لتعزيز هوية المنصة
                                  Text(
                                    "مستمع عبر ألوان",
                                    style: TextStyle(
                                      fontSize: 10, 
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSafeImage(String path) {
    if (path.isEmpty) return _fallbackIcon();
    
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 250),
        fadeOutDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        errorWidget: (context, url, error) => _fallbackIcon(),
      );
    } 
    
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      color: const Color(0xffEEF2FF),
      child: const Icon(Icons.radio_rounded, color: Color(0xff5C39E6), size: 40),
    );
  }
}

// 🟢 4. مكون منفصل لزر التشغيل لإضافة تأثير الـ AnimatedScale بسلاسة تامة
class _AnimatedPlayButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback? onTap;

  const _AnimatedPlayButton({
    required this.isPlaying,
    this.onTap,
  });

  @override
  State<_AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<_AnimatedPlayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: const Color(0xff5C39E6),
            size: 32,
          ),
        ),
      ),
    );
  }
}
