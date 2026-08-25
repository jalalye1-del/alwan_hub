import 'package:flutter/material.dart';

/// جميع الزوايا المستخدمة في تطبيق Alwan Hub
class AppRadius {
  AppRadius._();

  // =========================
  // قيم Radius المفردة 
  // (مفيدة للاستخدام المباشر مع BorderRadius.only أو ClipRRect)
  // =========================
  static const Radius radiusXs = Radius.circular(6);
  static const Radius radiusSm = Radius.circular(10);
  static const Radius radiusMd = Radius.circular(14);
  static const Radius radiusLg = Radius.circular(18);
  static const Radius radiusXl = Radius.circular(24);
  static const Radius radiusXxl = Radius.circular(32);
  static const Radius radiusPill = Radius.circular(100);

  // =========================
  // قيم BorderRadius الكاملة
  // (متسقة مع مقاييس التصميم xs إلى xxl)
  // =========================
  
  static const BorderRadius xs = BorderRadius.all(radiusXs); //[cite: 10]

  static const BorderRadius sm = BorderRadius.all(radiusSm); //[cite: 10]

  static const BorderRadius md = BorderRadius.all(radiusMd); //[cite: 10]

  static const BorderRadius lg = BorderRadius.all(radiusLg); //[cite: 10]

  static const BorderRadius xl = BorderRadius.all(radiusXl); //[cite: 10]

  static const BorderRadius xxl = BorderRadius.all(radiusXxl); //[cite: 10]

  static const BorderRadius pill = BorderRadius.all(radiusPill); //[cite: 10]
}