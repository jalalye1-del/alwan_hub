import 'package:flutter/material.dart';

/// النظام الطباعي الموحد لتطبيق ألوان.
abstract final class AppTypography {
  static const String fontFamily = 'MohammadBoldArt';

  /// يحافظ على قابلية القراءة عبر الهواتف الصغيرة والأجهزة اللوحية والشاشات
  /// الكبيرة من دون ربط الخط بكثافة بكسلات جهاز بعينه.
  static double deviceScaleFor(Size screenSize) {
    final shortestSide = screenSize.shortestSide;

    if (shortestSide < 320) return .90;
    if (shortestSide < 360) return .94;
    if (shortestSide < 600) return 1;
    if (shortestSide < 900) return 1.08;
    return 1.12;
  }

  /// يجمع مقياس الجهاز مع إعداد تكبير النص في النظام، مع حدود آمنة تمنع
  /// الانكماش المفرط أو كسر الواجهات عند درجات التكبير العالية جداً.
  static TextScaler textScalerFor(MediaQueryData mediaQuery) {
    final systemScale = (mediaQuery.textScaler.scale(16) / 16).clamp(1.0, 1.5);
    final effectiveScale = (systemScale * deviceScaleFor(mediaQuery.size))
        .clamp(.90, 1.68);

    return TextScaler.linear(effectiveScale);
  }
}
