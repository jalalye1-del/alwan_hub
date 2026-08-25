import 'package:flutter/material.dart';

class MoreTypography extends StatelessWidget {
  const MoreTypography({super.key, required this.child});

  static const arabicFontFamily = 'MohammadBoldArt';
  static const englishFontFamily = 'MohammadBoldArt';

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.light(useMaterial3: true);
    final fontFamily = Localizations.localeOf(context).languageCode == 'en'
        ? englishFontFamily
        : arabicFontFamily;
    final theme = base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF7F8FD),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5D35A4),
        brightness: Brightness.light,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: fontFamily,
        bodyColor: const Color(0xFF28305F),
        displayColor: const Color(0xFF28305F),
      ),
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: fontFamily),
      cardColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD9E0EA)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFD9E0EA)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF8530A5), width: 1.7),
        ),
      ),
    );

    return Theme(
      data: theme,
      child: DefaultTextStyle.merge(
        style: TextStyle(fontFamily: fontFamily),
        child: child,
      ),
    );
  }
}
