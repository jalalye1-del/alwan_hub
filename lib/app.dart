// lib/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/app_locale_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_typography.dart';
import 'core/router/app_router.dart'; // 1. استيراد ملف الـ Router الذي أنشأناه
import 'core/theme/theme_mode_controller.dart';

class AlwanHubApp extends StatelessWidget {
  const AlwanHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeModeController.instance,
      builder: (context, themeMode, _) => ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.instance,
        builder: (context, locale, _) => MaterialApp.router(
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          locale: locale,
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(
                textScaler: AppTypography.textScalerFor(mediaQuery),
              ),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}
