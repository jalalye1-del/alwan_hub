// lib/features/home/presentation/home_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:alwan_hub/core/audio/providers/audio_provider.dart';
import 'package:alwan_hub/core/router/app_router.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/widgets/bottom_navigation/bottom_nav_bar.dart';
import 'package:alwan_hub/core/audio/widgets/mini_player.dart';
import '../../fm_radio/presentation/screens/fm_radio_screen.dart';
import 'widgets/banner_slider.dart';

import 'widgets/home_header.dart';
import 'widgets/live_program_card.dart';
import 'widgets/quick_access/quick_access_section.dart';
import 'widgets/home_feature_links.dart';
import 'web_home_design.dart';
import 'package:alwan_hub/features/more/presentation/pages/news_screen.dart';
import 'package:alwan_hub/features/alwan_ai/presentation/widgets/alwan_ai_floating_button.dart';
// استخدام الاستيراد المطلق لتجنب أخطاء مسارات المجلدات نهائياً
import 'package:alwan_hub/features/library/presentation/pages/library_screen.dart';
import '../../programs/presentation/pages/fm_programs_screen.dart';
import 'package:alwan_hub/features/more/presentation/pages/more_screen.dart';
import 'package:alwan_hub/features/notifications/presentation/pages/notifications_screen.dart';
import 'package:alwan_hub/features/profile/presentation/pages/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  // قائمة الشاشات الـ 5 المرتبطة بدقة بأزرار الشريط السفلي
  List<Widget> get _screens => [
    _HomeContent(
      onNotificationTap: () => _openPage(const NotificationsScreen()),
      onProfileTap: () => _openPage(const ProfileScreen()),
    ), // الفهرس 0: الرئيسية
    const FmProgramsScreen(), // الفهرس 1: برامج FM
    const FmRadioScreen(), // 🟢 الفهرس 2: إذاعات FM (تم الربط بنجاح!)
    LibraryScreen(onBack: () => _onTabTapped(0)), // الفهرس 3: مكتبتي
    MoreScreen(onBack: () => _onTabTapped(0)), // الفهرس 4: المزيد
  ];

  void _openPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final hasMiniPlayer = ref.watch(
      audioPlayerProvider.select((state) => state.currentTrack != null),
    );
    final useReferenceWebDesign =
        kIsWeb && size.width >= 900 && size.height >= 500;

    if (useReferenceWebDesign && _currentIndex == 0) {
      return Scaffold(
        key: const ValueKey('desktop-web-home'),
        backgroundColor: Colors.white,
        body: WebHomeDesign(
          onHomeTap: () => _onTabTapped(0),
          onProgramsTap: () => _onTabTapped(1),
          onStationsTap: () => _onTabTapped(2),
          onLibraryTap: () => _onTabTapped(3),
          onMoreTap: () => _onTabTapped(4),
          onNotificationsTap: () => _openPage(const NotificationsScreen()),
          onProfileTap: () => _openPage(const ProfileScreen()),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(index: _currentIndex, children: _screens),
                ),
                const MiniPlayer(),
              ],
            ),
          ),
          if (_currentIndex == 0)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              right: 14,
              bottom: hasMiniPlayer ? 116 : 18,
              child: AlwanAiFloatingButton(
                onTap: () => context.pushNamed(
                  AppRoutes.alwanAi,
                  queryParameters: const {'listen': '1'},
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: ResponsiveContent(
        maxWidth: 1180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeHeader(
              onNotificationTap: onNotificationTap,
              onProfileTap: onProfileTap,
            ),
            const SizedBox(height: 16),
            const BannerSlider(),
            const SizedBox(height: 24),
            const LiveProgramCard(),
            const SizedBox(height: 24),
            const QuickAccessSection(),
            const SizedBox(height: 20),
            HomeFeatureLinks(
              onTrendingNewsTap: () => context.pushNamed(
                AppRoutes.moreNews,
                queryParameters: const {
                  'category': NewsScreen.trendingCategory,
                },
              ),
              onDailyHoroscopesTap: () =>
                  context.pushNamed(AppRoutes.dailyHoroscopes),
            ),
          ],
        ),
      ),
    );
  }
}
