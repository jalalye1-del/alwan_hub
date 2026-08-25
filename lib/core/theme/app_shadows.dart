import 'package:flutter/material.dart';

/// جميع الظلال المستخدمة في تطبيق Alwan Hub[cite: 9]
class AppShadows {
  AppShadows._();

  // =========================
  // ظلال الوضع الفاتح (Light Mode)
  // =========================

  /// ظل خفيف للبطاقات[cite: 9]
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, 8)), //[cite: 9]
  ];

  /// ظل متوسط[cite: 9]
  static const List<BoxShadow> medium = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 10)), //[cite: 9]
  ];

  /// ظل قوي[cite: 9]
  static const List<BoxShadow> large = [
    BoxShadow(color: Color(0x26000000), blurRadius: 32, offset: Offset(0, 14)), //[cite: 9]
  ];

  /// ظل خاص بالأزرار العائمة[cite: 9]
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x22000000), blurRadius: 20, offset: Offset(0, 6)), //[cite: 9]
  ];

  // =========================
  // ظلال التأثير الزجاجي (Glassmorphism)
  // =========================
  
  /// ظل ناعم مخصص لعناصر الزجاج (Glassmorphism) لإبرازها دون التأثير على شفافية الخلفية
  static const List<BoxShadow> glass = [
    BoxShadow(
      color: Color(0x0F000000), // ظل ناعم وشفاف جداً
      blurRadius: 30,
      spreadRadius: 2,
      offset: Offset(0, 10),
    ),
  ];

  // =========================
  // ظلال الوضع الداكن (Dark Mode)
  // =========================
  // تمت زيادة نسبة العتامة (Alpha/Opacity) للظلال لتكون مرئية بشكل أفضل على الخلفيات الداكنة

  /// ظل خفيف للبطاقات في الوضع الداكن
  static const List<BoxShadow> darkCard = [
    BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 8)),
  ];

  /// ظل متوسط في الوضع الداكن
  static const List<BoxShadow> darkMedium = [
    BoxShadow(color: Color(0x40000000), blurRadius: 24, offset: Offset(0, 10)),
  ];

  /// ظل قوي في الوضع الداكن
  static const List<BoxShadow> darkLarge = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 32, offset: Offset(0, 14)),
  ];

  /// ظل الزر العائم في الوضع الداكن
  static const List<BoxShadow> darkFloating = [
    BoxShadow(color: Color(0x59000000), blurRadius: 20, offset: Offset(0, 6)),
  ];

  /// ظل تأثير الزجاج للوضع الداكن
  static const List<BoxShadow> darkGlass = [
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 30,
      spreadRadius: 2,
      offset: Offset(0, 10),
    ),
  ];
}