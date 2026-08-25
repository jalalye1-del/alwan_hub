import 'package:flutter/material.dart';

import 'package:alwan_hub/core/content/models/managed_media.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/theme/app_radius.dart';
import 'package:alwan_hub/core/theme/app_shadows.dart';
import 'package:alwan_hub/core/theme/app_spacing.dart';
import 'package:alwan_hub/core/widgets/adaptive_content_image.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({
    super.key,
    this.banners = _defaultBanners,
    this.onBannerTap,
  });

  final List<ManagedMedia> banners;
  final ValueChanged<ManagedMedia>? onBannerTap;

  static const List<ManagedMedia> _defaultBanners = [
    ManagedMedia(
      id: 'home_banner_1',
      type: ManagedMediaType.image,
      url: 'assets/images/banners/banner1.jpg',
    ),
    ManagedMedia(
      id: 'home_banner_2',
      type: ManagedMediaType.image,
      url: 'assets/images/banners/banner2.jpg',
    ),
    ManagedMedia(
      id: 'home_banner_3',
      type: ManagedMediaType.image,
      url: 'assets/images/banners/banner3.jpg',
    ),
  ];

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  List<ManagedMedia> get _visibleBanners =>
      widget.banners
          .where((banner) => banner.isActive && banner.url.trim().isNotEmpty)
          .toList()
        ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = _visibleBanners;
    if (banners.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final aspectRatio = context.responsive.value(
          compact: 2,
          medium: 2.7,
          expanded: 3.2,
          large: 3.5,
        );
        final bannerHeight = (constraints.maxWidth / aspectRatio).clamp(
          150.0,
          330.0,
        );

        return Column(
          children: [
            SizedBox(
              height: bannerHeight,
              child: PageView.builder(
                controller: _controller,
                itemCount: banners.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return InkWell(
                    onTap: widget.onBannerTap == null
                        ? null
                        : () => widget.onBannerTap!(banner),
                    borderRadius: AppRadius.xl,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: AppRadius.xl,
                        boxShadow: AppShadows.medium,
                      ),
                      child: AdaptiveContentImage(
                        source: banner.url,
                        width: double.infinity,
                        height: bannerHeight,
                        fit: BoxFit.cover,
                        semanticLabel: banner.title,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: List.generate(banners.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: AppRadius.pill,
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
