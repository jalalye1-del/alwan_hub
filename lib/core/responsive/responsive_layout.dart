import 'package:flutter/material.dart';

enum AppDeviceType { compact, medium, expanded, large }

abstract final class AppBreakpoints {
  static const double medium = 600;
  static const double expanded = 900;
  static const double large = 1200;
  static const double maxContentWidth = 1280;
}

@immutable
class ResponsiveInfo {
  const ResponsiveInfo({
    required this.width,
    required this.height,
    required this.deviceType,
  });

  factory ResponsiveInfo.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return ResponsiveInfo(
      width: size.width,
      height: size.height,
      deviceType: switch (size.width) {
        < AppBreakpoints.medium => AppDeviceType.compact,
        < AppBreakpoints.expanded => AppDeviceType.medium,
        < AppBreakpoints.large => AppDeviceType.expanded,
        _ => AppDeviceType.large,
      },
    );
  }

  final double width;
  final double height;
  final AppDeviceType deviceType;

  bool get isCompact => deviceType == AppDeviceType.compact;
  bool get isMedium => deviceType == AppDeviceType.medium;
  bool get isExpanded =>
      deviceType == AppDeviceType.expanded || deviceType == AppDeviceType.large;

  double value({
    required double compact,
    double? medium,
    double? expanded,
    double? large,
  }) {
    return switch (deviceType) {
      AppDeviceType.compact => compact,
      AppDeviceType.medium => medium ?? compact,
      AppDeviceType.expanded => expanded ?? medium ?? compact,
      AppDeviceType.large => large ?? expanded ?? medium ?? compact,
    };
  }

  int columns({
    int compact = 2,
    int medium = 3,
    int expanded = 4,
    int large = 5,
  }) {
    return switch (deviceType) {
      AppDeviceType.compact => compact,
      AppDeviceType.medium => medium,
      AppDeviceType.expanded => expanded,
      AppDeviceType.large => large,
    };
  }

  EdgeInsets get pagePadding => EdgeInsets.symmetric(
    horizontal: value(compact: 16, medium: 24, expanded: 32, large: 40),
  );
}

extension ResponsiveContext on BuildContext {
  ResponsiveInfo get responsive => ResponsiveInfo.of(this);
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.maxContentWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? context.responsive.pagePadding,
          child: child,
        ),
      ),
    );
  }
}
