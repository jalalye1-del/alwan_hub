import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleController extends ValueNotifier<Locale> {
  AppLocaleController._() : super(const Locale('ar'));

  static final AppLocaleController instance = AppLocaleController._();

  static const String _languageKey = 'alwan_app_language';

  bool get isEnglish => value.languageCode == 'en';

  String get languageLabel => isEnglish ? 'English' : 'العربية';

  Future<void> initialize() async {
    final preferences = await SharedPreferences.getInstance();
    final savedLanguage = preferences.getString(_languageKey);
    value = _localeFor(savedLanguage);
  }

  Future<void> setLanguage(String language) async {
    final locale = _localeFor(language);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _languageKey,
      locale.languageCode == 'en' ? 'English' : 'العربية',
    );
    value = locale;
  }

  Locale _localeFor(String? language) {
    final normalized = language?.trim().toLowerCase();
    if (normalized == 'english' || normalized == 'en') {
      return const Locale('en');
    }
    return const Locale('ar');
  }
}
