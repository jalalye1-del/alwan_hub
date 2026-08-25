import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// استيراد الشاشات الأساسية في المشروع
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/lounge/presentation/lounge_screen.dart';
import '../../features/lounge/presentation/category_details_screen.dart';
import '../../features/lounge/presentation/artist_details_screen.dart';

import 'package:alwan_hub/features/library/presentation/pages/library_screen.dart';
import 'package:alwan_hub/features/library/presentation/pages/folder_details_screen.dart';
import 'package:alwan_hub/features/library/domain/entities/user_folder.dart';
import 'package:alwan_hub/core/recording/presentation/recordings_screen.dart';
import 'package:alwan_hub/core/audio/screens/now_playing_screen.dart';
import 'package:alwan_hub/features/games/presentation/pages/games_screen.dart';
import 'package:alwan_hub/features/alwan_ai/presentation/alwan_ai_screen.dart';
import 'package:alwan_hub/features/audiobooks/presentation/audiobooks_screen.dart';
import 'package:alwan_hub/features/favorites/presentation/pages/favorites_screen.dart';
import 'package:alwan_hub/features/fm_radio/presentation/screens/fm_radio_screen.dart';
import 'package:alwan_hub/features/interaction/presentation/share_and_chat_screen.dart';
import 'package:alwan_hub/features/programs/presentation/pages/fm_programs_screen.dart';
import 'package:alwan_hub/features/podcasts/presentation/pages/podcasts_screen.dart';
import 'package:alwan_hub/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/profile_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/appearance_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/app_rating_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/language_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/prayer_qibla_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/share_app_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/stream_quality_screen.dart';
import 'package:alwan_hub/features/more/presentation/pages/more_screen.dart';
import 'package:alwan_hub/features/more/presentation/pages/news_screen.dart';
import 'package:alwan_hub/features/more/presentation/pages/team_screen.dart';
import 'package:alwan_hub/features/more/presentation/pages/about_us_screen.dart';
import 'package:alwan_hub/features/more/presentation/pages/contact_us_screen.dart';
import 'package:alwan_hub/features/more/presentation/pages/about_app_screen.dart';
import 'package:alwan_hub/features/more/presentation/pages/app_updates_screen.dart';
import 'package:alwan_hub/features/horoscopes/presentation/daily_horoscopes_screen.dart';

/// ثوابت المسارات (Constants) لتجنب الأخطاء الإملائية وتسهيل الصيانة
class AppRoutes {
  AppRoutes._();

  static const String splash = 'splash';
  static const String splashPath = '/';

  static const String home = 'home';
  static const String homePath = '/home';

  static const String lounge = 'lounge';
  static const String loungePath = '/lounge';

  static const String library = 'library';
  static const String libraryPath = '/library';

  static const String recordings = 'recordings';
  static const String recordingsPath = '/library/recordings';

  static const String player = 'player';
  static const String playerPath = '/player';

  static const String category = 'category';
  static const String categoryPath = '/category/:id';

  static const String artistDetails = 'artist-details';
  static const String artistDetailsPath = '/artist-details';

  static const String folderDetails = 'folder-details';
  static const String folderDetailsPath = '/library/folder';

  static const String games = 'games';
  static const String gamesPath = '/games';

  static const String audiobooks = 'audiobooks';
  static const String audiobooksPath = '/audiobooks';

  static const String favorites = 'favorites';
  static const String favoritesPath = '/favorites';

  static const String shareAndChat = 'share-and-chat';
  static const String shareAndChatPath = '/share-and-chat';

  static const String alwanAi = 'alwan-ai';
  static const String alwanAiPath = '/alwan-ai';

  static const String fmPrograms = 'fm-programs';
  static const String fmProgramsPath = '/programs';

  static const String fmRadio = 'fm-radio';
  static const String fmRadioPath = '/stations';

  static const String podcasts = 'podcasts';
  static const String podcastsPath = '/podcasts';

  static const String notifications = 'notifications';
  static const String notificationsPath = '/notifications';

  static const String profile = 'profile';
  static const String profilePath = '/profile';

  static const String prayerQibla = 'prayer-qibla';
  static const String prayerQiblaPath = '/prayer-qibla';

  static const String streamQuality = 'stream-quality';
  static const String streamQualityPath = '/stream-quality';

  static const String language = 'language';
  static const String languagePath = '/language';

  static const String appearance = 'appearance';
  static const String appearancePath = '/appearance';

  static const String appRating = 'app-rating';
  static const String appRatingPath = '/app-rating';

  static const String shareApp = 'share-app';
  static const String shareAppPath = '/share-app';

  static const String more = 'more';
  static const String morePath = '/more';

  static const String moreNews = 'more-news';
  static const String moreNewsPath = '/more/news';

  static const String dailyHoroscopes = 'daily-horoscopes';
  static const String dailyHoroscopesPath = '/daily-horoscopes';

  static const String moreTeam = 'more-team';
  static const String moreTeamPath = '/more/team';

  static const String moreAboutUs = 'more-about-us';
  static const String moreAboutUsPath = '/more/about-us';

  static const String moreContact = 'more-contact';
  static const String moreContactPath = '/more/contact';

  static const String moreAboutApp = 'more-about-app';
  static const String moreAboutAppPath = '/more/about-app';

  static const String moreUpdates = 'more-updates';
  static const String moreUpdatesPath = '/more/updates';
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashPath,
    routes: [
      // ==========================================
      // 1. مسارات التطبيق الأساسية (Core Routes)
      // ==========================================

      // شاشة الترحيب (Splash Screen)
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // الشاشة الرئيسية للتطبيق (Home Screen)
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // مسار شاشة المكتبة
      GoRoute(
        path: AppRoutes.libraryPath,
        name: AppRoutes.library,
        builder: (context, state) => const LibraryScreen(),
      ),

      GoRoute(
        path: AppRoutes.recordingsPath,
        name: AppRoutes.recordings,
        builder: (context, state) => const RecordingsScreen(),
      ),

      GoRoute(
        path: AppRoutes.playerPath,
        name: AppRoutes.player,
        builder: (context, state) => const NowPlayingScreen(),
      ),

      GoRoute(
        path: AppRoutes.gamesPath,
        name: AppRoutes.games,
        builder: (context, state) => const GamesScreen(),
      ),

      GoRoute(
        path: AppRoutes.audiobooksPath,
        name: AppRoutes.audiobooks,
        builder: (context, state) => const AudiobooksScreen(),
      ),

      GoRoute(
        path: AppRoutes.favoritesPath,
        name: AppRoutes.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),

      GoRoute(
        path: AppRoutes.shareAndChatPath,
        name: AppRoutes.shareAndChat,
        builder: (context, state) => const ShareAndChatScreen(),
      ),

      GoRoute(
        path: AppRoutes.alwanAiPath,
        name: AppRoutes.alwanAi,
        builder: (context, state) => AlwanAiScreen(
          autoStartListening: state.uri.queryParameters['listen'] == '1',
        ),
      ),

      GoRoute(
        path: AppRoutes.fmProgramsPath,
        name: AppRoutes.fmPrograms,
        builder: (context, state) => const FmProgramsScreen(),
      ),

      GoRoute(
        path: AppRoutes.fmRadioPath,
        name: AppRoutes.fmRadio,
        builder: (context, state) => const FmRadioScreen(),
      ),

      GoRoute(
        path: AppRoutes.podcastsPath,
        name: AppRoutes.podcasts,
        builder: (context, state) => const PodcastsScreen(),
      ),

      GoRoute(
        path: AppRoutes.notificationsPath,
        name: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),

      GoRoute(
        path: AppRoutes.profilePath,
        name: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      GoRoute(
        path: AppRoutes.prayerQiblaPath,
        name: AppRoutes.prayerQibla,
        builder: (context, state) => const PrayerQiblaScreen(),
      ),

      GoRoute(
        path: AppRoutes.streamQualityPath,
        name: AppRoutes.streamQuality,
        builder: (context, state) => const StreamQualityScreen(),
      ),

      GoRoute(
        path: AppRoutes.languagePath,
        name: AppRoutes.language,
        builder: (context, state) => const LanguageScreen(),
      ),

      GoRoute(
        path: AppRoutes.appearancePath,
        name: AppRoutes.appearance,
        builder: (context, state) => const AppearanceScreen(),
      ),

      GoRoute(
        path: AppRoutes.appRatingPath,
        name: AppRoutes.appRating,
        builder: (context, state) => const AppRatingScreen(),
      ),

      GoRoute(
        path: AppRoutes.shareAppPath,
        name: AppRoutes.shareApp,
        builder: (context, state) => const ShareAppScreen(),
      ),

      GoRoute(
        path: AppRoutes.morePath,
        name: AppRoutes.more,
        builder: (context, state) =>
            MoreScreen(onBack: () => context.go(AppRoutes.homePath)),
      ),

      GoRoute(
        path: AppRoutes.moreNewsPath,
        name: AppRoutes.moreNews,
        builder: (context, state) => NewsScreen(
          initialCategory:
              state.uri.queryParameters['category'] ??
              NewsScreen.trendingCategory,
        ),
      ),

      GoRoute(
        path: AppRoutes.dailyHoroscopesPath,
        name: AppRoutes.dailyHoroscopes,
        builder: (context, state) => const DailyHoroscopesScreen(),
      ),

      GoRoute(
        path: AppRoutes.moreTeamPath,
        name: AppRoutes.moreTeam,
        builder: (context, state) => const TeamScreen(),
      ),

      GoRoute(
        path: AppRoutes.moreAboutUsPath,
        name: AppRoutes.moreAboutUs,
        builder: (context, state) => const AboutUsScreen(),
      ),

      GoRoute(
        path: AppRoutes.moreContactPath,
        name: AppRoutes.moreContact,
        builder: (context, state) => const ContactUsScreen(),
      ),

      GoRoute(
        path: AppRoutes.moreAboutAppPath,
        name: AppRoutes.moreAboutApp,
        builder: (context, state) => const AboutAppScreen(),
      ),

      GoRoute(
        path: AppRoutes.moreUpdatesPath,
        name: AppRoutes.moreUpdates,
        builder: (context, state) => const AppUpdatesScreen(),
      ),

      // مسار تفاصيل المجلد داخل المكتبة
      GoRoute(
        path: '${AppRoutes.folderDetailsPath}/:id',
        name: AppRoutes.folderDetails,
        builder: (context, state) {
          final folder = state.extra;

          if (folder is! UserFolder) {
            return const LibraryScreen();
          }

          return FolderDetailsScreen(folder: folder);
        },
      ),

      // ==========================================
      // 2. مسارات قسم الاستراحة (Lounge Feature Routes)
      // ==========================================

      // الشاشة الرئيسية لاستراحة ألوان (Lounge Screen)
      GoRoute(
        path: AppRoutes.loungePath,
        name: AppRoutes.lounge,
        builder: (context, state) => const LoungeScreen(),
      ),

      // مسار تفاصيل القسم
      GoRoute(
        path: AppRoutes.categoryPath,
        name: AppRoutes.category,
        builder: (context, state) {
          final categoryId = state.pathParameters['id'] ?? '';

          return CategoryDetailsScreen(categoryId: categoryId);
        },
      ),

      // مسار تفاصيل الفنان
      GoRoute(
        path: AppRoutes.artistDetailsPath,
        name: AppRoutes.artistDetails,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};

          return ArtistDetailsScreen(
            artistId: extra['artistId'] as String? ?? '',
            artistName: extra['artistName'] as String? ?? '',
            artistImageUrl: extra['artistImageUrl'] as String? ?? '',
            primaryColor:
                extra['primaryColor'] as Color? ?? const Color(0xFFD32F2F),
            categoryName: extra['categoryName'] as String? ?? 'مادة صوتية',
            categoryId: extra['categoryId'] as String? ?? 'alwan_lounge',
            trackItemLabel: extra['trackItemLabel'] as String? ?? 'أغنية',
          );
        },
      ),
    ],
  );
}
