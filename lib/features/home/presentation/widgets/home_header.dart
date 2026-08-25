import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/theme/app_radius.dart';
import 'package:alwan_hub/core/theme/app_shadows.dart';
import 'package:alwan_hub/core/theme/app_spacing.dart';
import 'package:alwan_hub/core/widgets/adaptive_content_image.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, this.onNotificationTap, this.onProfileTap});

  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    final buttonSize = responsive.value(compact: 48, medium: 52, expanded: 56);
    final logoHeight = responsive.value(compact: 68, medium: 78, expanded: 88);
    final enlargedLogoHeight = logoHeight + 30;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            _HeaderButton(
              icon: Icons.notifications_none_rounded,
              showBadge: true,
              onTap: onNotificationTap,
              size: buttonSize,
            ),

            const Spacer(),

            SizedBox(
              width: enlargedLogoHeight * 1.42,
              height: logoHeight,
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minHeight: enlargedLogoHeight,
                maxHeight: enlargedLogoHeight,
                child: AdaptiveContentImage(
                  source: 'assets/images/splash_logo.png',
                  height: enlargedLogoHeight,
                  fit: BoxFit.contain,
                  semanticLabel: 'ألوان FM',
                ),
              ),
            ),

            const Spacer(),

            _HeaderButton(
              icon: Icons.person_outline_rounded,
              onTap: onProfileTap,
              size: buttonSize,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.size,
    this.showBadge = false,
    this.onTap,
  });

  final IconData icon;
  final double size;
  final bool showBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.xl,
        onTap: onTap,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.xl,
            boxShadow: AppShadows.card,
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(icon, color: AppColors.primary, size: size * .46),
              ),

              if (showBadge)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
