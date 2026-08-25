import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeModeController extends ValueNotifier<ThemeMode> {
  AppThemeModeController._() : super(ThemeMode.system);

  static final AppThemeModeController instance = AppThemeModeController._();
  static const _key = 'alwan_theme_mode';

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    value = switch (preferences.getString(_key)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> update(ThemeMode mode) async {
    value = mode;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, mode.name);
  }
}
