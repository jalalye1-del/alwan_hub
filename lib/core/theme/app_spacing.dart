import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  // =========================
  // مقياس التصميم الثابت (4pt Grid System)
  // =========================
  static const double xs = 4; //
  static const double sm = 8; //
  static const double md = 12; //[cite: 8]
  static const double lg = 16; //[cite: 8]
  static const double xl = 20; //[cite: 8]
  static const double xxl = 24; //[cite: 8]
  static const double xxxl = 32; //[cite: 8]

  // =========================
  // الحشوات المتكررة (Paddings)
  // =========================

  // الحشوة الأفقية المعتمدة للشاشات[cite: 8]
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: xl); //[cite: 8]

  // الحشوة الداخلية للبطاقات[cite: 8]
  static const EdgeInsets cardPadding = EdgeInsets.all(xl); //[cite: 8]

  // --- الإضافات الجديدة ---

  // حشوة رأسية موحدة للقوائم والعناصر
  static const EdgeInsets verticalPadding = EdgeInsets.symmetric(vertical: xxl);

  // حشوة شاملة للصفحة (أفقية ورأسية) لتوحيد هوامش الشاشات بالكامل
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: xl, vertical: xxl);
}