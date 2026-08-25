// lib/features/fm_radio/presentation/widgets/fm_station_card.dart

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/localization/localized_text.dart';
import '../../domain/models/fm_station.dart';

class FmStationCard extends StatelessWidget {
  final FmStation station;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const FmStationCard({
    super.key,
    required this.station,
    required this.isSelected,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        transform: Matrix4.diagonal3Values(
          isSelected ? 1.02 : 1.0, 
          isSelected ? 1.02 : 1.0,
          1.0,
        ),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xff5C39E6) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .10),
              blurRadius: 26,
              spreadRadius: 2,
              offset: const Offset(0, 12),
            ),
            if (isSelected)
              BoxShadow(
                color: const Color(0xff7C3AED).withValues(alpha: .25),
                blurRadius: 22,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // =========================================
            // النصف الأول (50%): الشعار والأيقونات العلوية
            // =========================================
            Expanded(
              flex: 1, 
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                      // الأولوية للـ Cover ثم اللوجو كبديل احتياطي
                      child: _buildImage(
                        station.coverImage.isNotEmpty
                            ? station.coverImage
                            : station.logo,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // أيقونة المفضلة
                  Positioned(
                    top: 4, 
                    left: 4, 
                    child: GestureDetector(
                      onTap: onFavoriteToggle,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            width: 24, 
                            height: 24, 
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 0.5,
                              ),
                            ),
                            child: Icon(
                              station.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: station.isFavorite ? Colors.redAccent : Colors.white,
                              size: 13, 
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // أيقونة البث المباشر
                  if (station.isLive)
                    Positioned(
                      top: 4, 
                      right: 4, 
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            height: 20, 
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xffE53935).withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(radius: 2, backgroundColor: Colors.white), 
                                SizedBox(width: 3),
                                Text(
                                  "مباشر",
                                  style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold), 
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // =========================================
            // النصف الثاني (50%): النصوص المرنة للتمدد والانكماش
            // =========================================
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Directionality(
                  textDirection: Directionality.of(context),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Flexible(
                        flex: 2,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            station.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff2D246B),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xffEEF2FF),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.graphic_eq_rounded, size: 12, color: Color(0xff5C39E6)),
                                const SizedBox(width: 6),
                                Text(
                                  station.frequency.contains('FM') ? station.frequency : "${station.frequency} FM",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff5C39E6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            station.country,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة بناء الصور المدمجة (للإنترنت والملفات المحلية)
  Widget _buildImage(String path) {
    if (path.isEmpty) return _buildPlaceholder();
    
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
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

  // دالة الصورة البديلة في حال فشل التحميل
  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xffEEF2FF),
      child: const Icon(Icons.radio_rounded, color: Color(0xff5C39E6), size: 42),
    );
  }
} // 🟢 إغلاق الكلاس الأساسي
