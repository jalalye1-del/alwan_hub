import 'package:flutter/material.dart';

class ProfileTypography extends StatelessWidget {
  const ProfileTypography({super.key, required this.child});

  static const arabicFontFamily = 'MohammadBoldArt';
  static const englishFontFamily = 'MohammadBoldArt';

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fontFamily = Localizations.localeOf(context).languageCode == 'en'
        ? englishFontFamily
        : arabicFontFamily;
    final profileTheme = theme.copyWith(
      textTheme: theme.textTheme.apply(fontFamily: fontFamily),
      primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: fontFamily),
    );

    return Theme(
      data: profileTheme,
      child: DefaultTextStyle.merge(
        style: TextStyle(fontFamily: fontFamily),
        child: child,
      ),
    );
  }
}
