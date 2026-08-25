import 'package:alwan_hub/core/theme/app_theme.dart';
import 'package:alwan_hub/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTypography', () {
    test('uses MohammadBoldArt throughout both application themes', () {
      for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
        expect(
          theme.textTheme.bodyMedium?.fontFamily,
          AppTypography.fontFamily,
        );
        expect(
          theme.textTheme.titleLarge?.fontFamily,
          AppTypography.fontFamily,
        );
        expect(
          theme.primaryTextTheme.labelLarge?.fontFamily,
          AppTypography.fontFamily,
        );
      }
    });

    test('adapts its base scale to different device classes', () {
      expect(AppTypography.deviceScaleFor(const Size(300, 640)), .90);
      expect(AppTypography.deviceScaleFor(const Size(340, 720)), .94);
      expect(AppTypography.deviceScaleFor(const Size(390, 844)), 1);
      expect(AppTypography.deviceScaleFor(const Size(800, 1280)), 1.08);
      expect(AppTypography.deviceScaleFor(const Size(1200, 1600)), 1.12);
    });

    test('combines device size with the operating-system text scale', () {
      const phone = MediaQueryData(
        size: Size(390, 844),
        textScaler: TextScaler.linear(1.25),
      );
      const tablet = MediaQueryData(
        size: Size(800, 1280),
        textScaler: TextScaler.linear(1.25),
      );

      expect(AppTypography.textScalerFor(phone).scale(16), closeTo(20, .01));
      expect(AppTypography.textScalerFor(tablet).scale(16), closeTo(21.6, .01));
    });
  });
}
