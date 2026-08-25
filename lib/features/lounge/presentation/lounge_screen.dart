import 'dart:ui';
import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import '../data/lounge_categories.dart';
import '../domain/models/category_config.dart';
import 'category_details_screen.dart';
import 'yemeni_songs_screen.dart';

class LoungeScreen extends StatelessWidget {
  const LoungeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              const _LoungeHeader(),
              const SizedBox(height: 24),
              const _PromoBanner(),
              const SizedBox(height: 32),
              _buildGlassyGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassyGrid(BuildContext context) {
    // جلب البيانات من الكلاس المخصص
    final categories = LoungeCategoriesData.loungeCategories;

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 22,
        crossAxisSpacing: 16,
        childAspectRatio: 0.80,
      ),
      itemBuilder: (context, index) {
        return _GlassyCategoryCard(
          category: categories[index],
          onTap: () {
            final category = categories[index];
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => category.id == 'yemeni-songs'
                    ? const YemeniSongsScreen()
                    : CategoryDetailsScreen(categoryId: category.id),
              ),
            );
          },
        );
      },
    );
  }
}

/// ==========================================
/// ويدجت الهيدر
/// ==========================================
class _LoungeHeader extends StatelessWidget {
  const _LoungeHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'إستراحة ألوان',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xff111827),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'حديقة صوتية ملونة .. تزهر بتفاعلكم',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff6B7280),
                height: 1.3,
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
              Navigator.maybePop(context);
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Color(0xff1A1A1A),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_outlined,
                size: 20,
                color: Color(0xff1A1A1A),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// ==========================================
/// ويدجت البنر الإعلاني
/// ==========================================
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 165,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: const NetworkImage(
            'https://images.pexels.com/photos/1763075/pexels-photo-1763075.jpeg?auto=compress&cs=tinysrgb&w=800',
          ), // تم استبدال صورة البنر لتجنب Unsplash
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            const Color(0xFF5B4CF0).withValues(alpha: 0.75),
            BlendMode.srcOver,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B4CF0).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'جديد إستراحة ألوان',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            SizedBox(height: 6),
            Text(
              'ألبوم الصيف حصرياً\nبدون فواصل إعلانية',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ==========================================
/// ويدجت البطاقة الزجاجية
/// ==========================================
class _GlassyCategoryCard extends StatelessWidget {
  // تم تغيير النوع ليتطابق مع كيان البيانات الجديد
  final CategoryConfig category;
  final VoidCallback onTap;

  const _GlassyCategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // استخدام الخصائص مباشرة من الـ Object
    final Color rawColor = category.primaryColor;
    final String imageUrl = category.bannerImage;

    final Color mainColor =
        Color.lerp(rawColor, Colors.white, 0.25) ?? rawColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: mainColor.withValues(alpha: 0.45),
              blurRadius: 22,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 11,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        image: imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imageUrl.isEmpty
                          ? Center(
                              // تم استخدام أيقونة افتراضية كبديل بما أن CategoryConfig لا يحتوي على حقل icon
                              child: Icon(
                                Icons.folder_special_rounded,
                                size: 52,
                                color: mainColor,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Expanded(
                    flex: 9,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(22),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            mainColor.withValues(alpha: 0.85),
                            mainColor,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            // الوصول للعنوان عبر category.title
                            category.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category.gridTitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
}
