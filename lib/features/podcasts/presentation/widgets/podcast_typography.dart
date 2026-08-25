import 'package:flutter/material.dart';

class PodcastTypography extends StatelessWidget {
  const PodcastTypography({super.key, required this.child});

  static const fontFamily = 'MohammadBoldArt';

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final theme = base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: fontFamily),
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: fontFamily),
    );

    return Theme(
      data: theme,
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontFamily: fontFamily),
        child: child,
      ),
    );
  }
}
