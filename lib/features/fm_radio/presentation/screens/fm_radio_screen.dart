// lib/features/fm_radio/presentation/screens/fm_radio_screen.dart

import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/providers/audio_provider.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import '../../domain/models/fm_filter.dart';
import '../providers/fm_station_provider.dart';
import '../widgets/fm_station_card.dart';
import '../widgets/live_station_banner.dart';
import '../widgets/fm_filter_bar.dart';

class FmRadioScreen extends ConsumerStatefulWidget {
  const FmRadioScreen({super.key});

  @override
  ConsumerState<FmRadioScreen> createState() => _FmRadioScreenState();
}

class _FmRadioScreenState extends ConsumerState<FmRadioScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFilter = ref.watch(fmFilterProvider);
    final filteredStations = ref.watch(visibleStationsProvider);
    final filteredFavorites = ref.watch(visibleFavoriteStationsProvider);

    final activeStation = ref.watch(activeStationProvider);
    final audioState = ref.watch(audioPlayerProvider);
    final responsive = context.responsive;
    final stationColumns = responsive.columns(
      compact: 3,
      medium: 4,
      expanded: 6,
      large: 7,
    );
    final stationAspectRatio = responsive.value(
      compact: .56,
      medium: .62,
      expanded: .68,
    );

    final isActiveStationPlaying =
        activeStation != null &&
        audioState.isPlaying &&
        audioState.currentTrack?.id == activeStation.id;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FC),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(fmStationsProvider);
            ref.invalidate(favoriteFmStationsProvider);
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              /// 1. Header & Search
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 8,
                    20,
                    6,
                  ),
                  child: Column(
                    children: [
                      // 🟢 التعديل الجذري: وضع العناوين بين الأزرار لتوفير المساحة وتوسيطها
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _headerButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                          ),

                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  "إذاعات FM",
                                  style: TextStyle(
                                    fontSize: 16, // 🟢 تعديل الحجم إلى 16
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xff391B99),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  "اكتشف أفضل الإذاعات في اليمن وحول العالم",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12, // 🟢 تعديل الحجم إلى 12
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Stack(
                            children: [
                              _headerButton(
                                icon: Icons.notifications_none_rounded,
                                onTap: () {},
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  width: 9,
                                  height: 9,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 16), // مسافة أنيقة قبل مربع البحث

                      Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .04),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) =>
                              ref.read(fmSearchQueryProvider.notifier).state =
                                  value,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "ابحث عن محطة إذاعية...",
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.grey,
                            ),
                            suffixIcon: Icon(
                              Icons.mic_none_rounded,
                              color: Color(0xff5C39E6),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              /// 2. Live Station Banner
              if (activeStation != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LiveStationBanner(
                      station: activeStation,
                      isPlaying: isActiveStationPlaying,
                      onPlayToggle: () {
                        if (isActiveStationPlaying) {
                          ref.read(audioControllerProvider).pause();
                        } else {
                          ref
                              .read(audioControllerProvider)
                              .play(activeStation.toAudioTrack());
                        }
                      },
                    ),
                  ),
                ),

              if (activeStation != null)
                const SliverToBoxAdapter(child: SizedBox(height: 10)),

              /// 3. Ad Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xff8B5CF6), Color(0xffC4B5FD)],
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -30,
                            top: -20,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: .08),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "مساحتك الإعلانية هنا",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        "تواصل مع آلاف المستمعين يومياً",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  width: 130,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff5C39E6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      "اعلن الآن",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              /// 4. Filter Bar (Sticky Header)
              SliverPersistentHeader(
                pinned: true,
                delegate: _FilterBarDelegate(
                  child: FmFilterBar(
                    key: ValueKey(selectedFilter),
                    selectedFilter: selectedFilter,
                    onChanged: (newFilter) {
                      ref.read(fmFilterProvider.notifier).state = newFilter;
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              /// 5. Favorite Stations Section
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "المحطات المفضلة",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff391B99),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              if (filteredFavorites.isEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 80,
                    child: Center(
                      child: Text(
                        "لا توجد محطات مفضلة ضمن تصنيف (${selectedFilter.title})",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredFavorites.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: stationColumns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 16,
                        childAspectRatio: stationAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final station = filteredFavorites[index];
                        return FmStationCard(
                          station: station,
                          isSelected: activeStation?.id == station.id,
                          onTap: () {
                            ref
                                .read(activeStationProvider.notifier)
                                .setActiveStation(station);
                          },
                          onFavoriteToggle: () async {
                            await ref
                                .read(favoriteNotifierProvider.notifier)
                                .toggleFavorite(station.id);
                          },
                        );
                      },
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              /// 6. Explore Stations Section
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "استكشاف المحطات",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff391B99),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              if (filteredStations.isEmpty)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 150,
                    child: Center(
                      child: Text(
                        "لم يتم العثور على محطات مطابقة",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredStations.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: stationColumns,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 16,
                        childAspectRatio: stationAspectRatio,
                      ),
                      itemBuilder: (context, index) {
                        final station = filteredStations[index];
                        return FmStationCard(
                          station: station,
                          isSelected: activeStation?.id == station.id,
                          onTap: () {
                            ref
                                .read(activeStationProvider.notifier)
                                .setActiveStation(station);
                          },
                          onFavoriteToggle: () async {
                            await ref
                                .read(favoriteNotifierProvider.notifier)
                                .toggleFavorite(station.id);
                          },
                        );
                      },
                    ),
                  ),
                ),

              /// 7. Bottom Spacing
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: .08),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: const Color(0xff391B99), size: 22),
        ),
      ),
    );
  }
}

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _FilterBarDelegate({required this.child});

  @override
  double get minExtent => 52.0;

  @override
  double get maxExtent => 52.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xffF7F8FC),
        boxShadow: overlapsContent
            ? const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _FilterBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
