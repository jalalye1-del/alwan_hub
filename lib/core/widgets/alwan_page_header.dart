import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/theme/app_colors.dart';

class AlwanPageHeader extends StatelessWidget {
  const AlwanPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.onNotificationTap,
    this.trailing,
    this.dark = false,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final VoidCallback? onNotificationTap;
  final Widget? trailing;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : AppColors.textPrimary;
    final secondary = dark ? Colors.white70 : AppColors.textSecondary;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            _HeaderAction(
              icon: Icons.arrow_back_rounded,
              tooltip: context.translateInterface('عودة'),
              foreground: foreground,
              dark: dark,
              onTap: onBack ?? () => Navigator.maybePop(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: secondary, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            trailing ??
                _HeaderAction(
                  icon: Icons.notifications_none_rounded,
                  tooltip: context.translateInterface('الإشعارات'),
                  foreground: foreground,
                  dark: dark,
                  onTap: onNotificationTap,
                  showBadge: onNotificationTap != null,
                ),
          ],
        ),
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.foreground,
    required this.dark,
    this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final String tooltip;
  final Color foreground;
  final bool dark;
  final VoidCallback? onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton.filledTonal(
          onPressed: onTap,
          tooltip: tooltip,
          style: IconButton.styleFrom(
            backgroundColor: dark
                ? Colors.white.withValues(alpha: .09)
                : Colors.white,
            foregroundColor: foreground,
            side: BorderSide(color: dark ? Colors.white12 : AppColors.divider),
          ),
          icon: Icon(icon),
        ),
        if (showBadge)
          const Positioned(
            top: 5,
            right: 5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: SizedBox(width: 8, height: 8),
            ),
          ),
      ],
    );
  }
}
