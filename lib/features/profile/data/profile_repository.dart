import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.city,
    required this.bio,
    required this.avatarTheme,
    required this.points,
  });

  const UserProfile.initial()
    : name = 'محمد العلواني',
      email = 'listener@alwan.fm',
      city = 'صنعاء، اليمن',
      bio = 'مستمع وعاشق لصوت وفن اليمن الأصيل 📻❤️',
      avatarTheme = 'الغروب 🌅',
      points = 350;

  final String name;
  final String email;
  final String city;
  final String bio;
  final String avatarTheme;
  final int points;

  UserProfile copyWith({
    String? name,
    String? email,
    String? city,
    String? bio,
    String? avatarTheme,
    int? points,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      avatarTheme: avatarTheme ?? this.avatarTheme,
      points: points ?? this.points,
    );
  }
}

class ProfileRepository {
  static const _nameKey = 'alwan_profile_name';
  static const _emailKey = 'alwan_profile_email';
  static const _cityKey = 'alwan_profile_city';
  static const _bioKey = 'alwan_profile_bio';
  static const _avatarThemeKey = 'alwan_profile_avatar_theme';
  static const _qualityKey = 'alwan_stream_quality';
  static const _languageKey = 'alwan_app_language';

  Future<UserProfile> load() async {
    final preferences = await SharedPreferences.getInstance();
    const fallback = UserProfile.initial();
    return UserProfile(
      name: preferences.getString(_nameKey) ?? fallback.name,
      email: preferences.getString(_emailKey) ?? fallback.email,
      city: preferences.getString(_cityKey) ?? fallback.city,
      bio: preferences.getString(_bioKey) ?? fallback.bio,
      avatarTheme:
          preferences.getString(_avatarThemeKey) ?? fallback.avatarTheme,
      points: fallback.points,
    );
  }

  Future<void> save(UserProfile profile) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setString(_nameKey, profile.name),
      preferences.setString(_emailKey, profile.email),
      preferences.setString(_cityKey, profile.city),
      preferences.setString(_bioKey, profile.bio),
      preferences.setString(_avatarThemeKey, profile.avatarTheme),
    ]);
  }

  Future<String> loadStreamQuality() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_qualityKey) ?? 'عالية';
  }

  Future<void> saveStreamQuality(String quality) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_qualityKey, quality);
  }

  Future<String> loadLanguage() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_languageKey) ?? 'العربية';
  }

  Future<void> saveLanguage(String language) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, language);
  }
}
