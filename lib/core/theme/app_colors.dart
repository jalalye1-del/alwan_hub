import 'package:flutter/material.dart';

/// جميع ألوان تطبيق Alwan Hub
/// يمنع استخدام الألوان بشكل مباشر داخل الواجهات.[cite: 11]
class AppColors {
  AppColors._();

  // =========================
  // Brand Colors[cite: 11]
  // =========================

  static const Color primary = Color(0xFF1565C0); //[cite: 11]
  static const Color secondary = Color(0xFF7E57C2); //[cite: 11]
  static const Color accent = Color(0xFFFFC107); //[cite: 11]

  // =========================
  // Light Theme[cite: 11]
  // =========================

  static const Color background = Color(0xFFF8FAFC); //[cite: 11]

  static const Color surface = Colors.white; //[cite: 11]

  static const Color card = Colors.white; //[cite: 11]

  // =========================
  // Dark Theme[cite: 11]
  // =========================

  static const Color darkBackground = Color(0xFF081C3A); //[cite: 11]

  static const Color darkSurface = Color(0xFF10294D); //[cite: 11]

  static const Color darkCard = Color(0xFF17375E); //[cite: 11]

  // =========================
  // Text[cite: 11]
  // =========================

  static const Color textPrimary = Color(0xFF1A1A1A); //[cite: 11]

  static const Color textSecondary = Color(0xFF6B7280); //[cite: 11]

  static const Color textLight = Colors.white; //[cite: 11]

  // =========================
  // Status[cite: 11]
  // =========================

  static const Color success = Color(0xFF2E7D32); //[cite: 11]

  static const Color warning = Color(0xFFF9A825); //[cite: 11]

  static const Color error = Color(0xFFC62828); //[cite: 11]

  static const Color info = Color(0xFF0288D1); //[cite: 11]

  // =========================
  // Divider & Border[cite: 11]
  // =========================

  static const Color divider = Color(0xFFE5E7EB); //[cite: 11]

  static const Color border = Color(0xFFD1D5DB); //[cite: 11]

  // =========================
  // Live Radio[cite: 11]
  // =========================

  static const Color live = Color(0xFFE53935); //[cite: 11]
  
  // =========================
  // Common[cite: 11]
  // =========================

  static const Color white = Colors.white; //[cite: 11]
  static const Color black = Colors.black; //[cite: 11]
  static const Color transparent = Colors.transparent; //[cite: 11]

  // =========================
  // Component States (الإضافة الجديدة لحالات العناصر)
  // =========================

  /// لون الخلفية للعناصر المعطلة (Disabled)
  static const Color disabledBackground = Color(0xFFE0E0E0); 
  
  /// لون النص للعناصر المعطلة (Disabled Text)
  static const Color disabledText = Color(0xFF9E9E9E);
  
  /// لون التركيز (Focus) عند الضغط أو التحديد
  static const Color focus = Color(0x1F1565C0); // لون Primary مع شفافية 12%

  // =========================
  // Glass Effect[cite: 11]
  // =========================

  static const Color glass = Color(0x26FFFFFF); // 15% White[cite: 11]
  static const Color glassBorder = Color(0x40FFFFFF); //[cite: 11]
  static const Color glassShadow = Color(0x22000000); //[cite: 11]

  // =========================
  // Gradients[cite: 11]
  // =========================

  static const Color gradientStart = Color(0xFF1565C0); //[cite: 11]
  static const Color gradientEnd = Color(0xFF7E57C2); //[cite: 11]

  static const Color headerStart = Color(0xFF0D47A1); //[cite: 11]
  static const Color headerEnd = Color(0xFF5E35B1); //[cite: 11]

  // --- الإضافة الجديدة: كائنات التدرج الجاهزة للاستخدام المباشر ---
  
  /// التدرج الأساسي
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [gradientStart, gradientEnd],
  );

  /// تدرج الهيدر (الرأس)
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [headerStart, headerEnd],
  );

  // =========================
  // Overlay[cite: 11]
  // =========================

  static const Color overlayDark = Color(0x66000000); //[cite: 11]
  static const Color overlayLight = Color(0x66FFFFFF); //[cite: 11]
}