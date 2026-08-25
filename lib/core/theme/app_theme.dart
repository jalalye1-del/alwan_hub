import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(TextTheme baseTheme, Color textColor) {
    final themed = baseTheme.apply(
      fontFamily: AppTypography.fontFamily,
      bodyColor: textColor,
      displayColor: textColor,
    );

    return themed.copyWith(
      displayLarge: themed.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      displayMedium: themed.displayMedium?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      titleLarge: themed.titleLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
      titleMedium: themed.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      bodyLarge: themed.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      bodyMedium: themed.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      labelLarge: themed.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.35,
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    final textTheme = _buildTextTheme(base.textTheme, AppColors.textPrimary);

    return ThemeData(
      useMaterial3: true, //
      brightness: Brightness.light, //[cite: 6]

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary, //[cite: 6]
        brightness: Brightness.light, //[cite: 6]
      ),

      scaffoldBackgroundColor: AppColors.background, //[cite: 6]

      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent, //[cite: 6]
        elevation: 0, //[cite: 6]
        centerTitle: true, //[cite: 6]
        foregroundColor: AppColors.textPrimary, //[cite: 6]
      ),

      cardTheme: CardThemeData(
        elevation: 0, //[cite: 6]
        color: AppColors.card, //[cite: 6]
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ), //[cite: 6]
      ),

      // تنسيق الأزرار المرتفعة (الموجود مسبقاً)[cite: 6]
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, //[cite: 6]
          foregroundColor: Colors.white, //[cite: 6]
          minimumSize: const Size(double.infinity, 56), //[cite: 6]
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), //[cite: 6]
          ),
        ),
      ),

      // --- الإضافة الجديدة: تنسيق الأزرار الممتلئة (Filled Buttons) ---
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // --- الإضافة الجديدة: تنسيق الأزرار المفرغة (Outlined Buttons) ---
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true, //[cite: 6]
        fillColor: Colors.white, //[cite: 6]
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18, //[cite: 6]
          vertical: 16, //[cite: 6]
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), //[cite: 6]
          borderSide: BorderSide.none, //[cite: 6]
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    final textTheme = _buildTextTheme(base.textTheme, Colors.white);

    return ThemeData(
      useMaterial3: true, //[cite: 6]
      brightness: Brightness.dark, //[cite: 6]

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary, //[cite: 6]
        brightness: Brightness.dark, //[cite: 6]
      ),

      scaffoldBackgroundColor: AppColors.darkBackground, //[cite: 6]

      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, //[cite: 6]
        elevation: 0, //[cite: 6]
        centerTitle: true, //[cite: 6]
      ),

      cardTheme: CardThemeData(
        elevation: 0, //[cite: 6]
        color: AppColors.darkCard, //[cite: 6]
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ), //[cite: 6]
      ),

      // تنسيق الأزرار المرتفعة[cite: 6]
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary, //[cite: 6]
          foregroundColor: Colors.white, //[cite: 6]
          minimumSize: const Size(double.infinity, 56), //[cite: 6]
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), //[cite: 6]
          ),
        ),
      ),

      // --- الإضافة الجديدة (الوضع الداكن) ---
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // --- الإضافة الجديدة (الوضع الداكن) ---
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors
              .primary, // يمكن تغييره للون أفتح إذا لزم الأمر في الوضع الداكن
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true, //[cite: 6]
        fillColor: AppColors.darkSurface, //[cite: 6]
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18, //[cite: 6]
          vertical: 16, //[cite: 6]
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), //[cite: 6]
          borderSide: BorderSide.none, //[cite: 6]
        ),
      ),
    );
  }
}
