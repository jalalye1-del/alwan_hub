// lib/features/home/presentation/widgets/quick_access/quick_access_section.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart' hide Text;
import 'package:go_router/go_router.dart';

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/features/interaction/presentation/share_and_chat_screen.dart';
import 'package:alwan_hub/features/favorites/presentation/pages/favorites_screen.dart';
import 'package:alwan_hub/features/podcasts/presentation/pages/podcasts_screen.dart';
import 'package:alwan_hub/features/audiobooks/presentation/audiobooks_screen.dart';
import 'package:alwan_hub/features/lounge/presentation/lounge_screen.dart';
import 'package:alwan_hub/features/games/presentation/pages/games_screen.dart';

class QuickAccessSection extends StatelessWidget {
  const QuickAccessSection({super.key});

  final List<Map<String, dynamic>> quickAccessData = const [
    {
      "title": "بودكاست ألوان",
      "sub": "حلقات ممتعة",
      "icon": Icons.mic_rounded,
      "route": "/podcast",
      "gradient": [Color(0xFF6A5AE0), Color(0xFF9E92FF)],
      "accentColor": Color(0xFF4C3EC2),
    },
    {
      "title": "الكتب الصوتية",
      "sub": "استمع للروايات",
      "icon": Icons.menu_book_rounded,
      "route": "/audiobooks",
      "gradient": [Color(0xFFFF7A00), Color(0xFFFFB053)],
      "accentColor": Color(0xFFD66000),
    },
    {
      "title": "شارك ودردش",
      "sub": "تواصل الآن",
      "icon": Icons.chat_bubble_rounded,
      "route": "/chat",
      "gradient": [Color(0xFF00C6FF), Color(0xFF0072FF)],
      "accentColor": Color(0xFF0056B3),
    },
    {
      "title": "المفضلة",
      "sub": "اختياراتك",
      "icon": Icons.favorite_rounded,
      "route": "/favorites",
      "gradient": [Color(0xFFFF3366), Color(0xFFFF6B8B)],
      "accentColor": Color(0xFFD91448),
    },
    {
      "title": "استراحة ألوان",
      "sub": "أغاني وبرامج",
      "icon": Icons.coffee_rounded,
      "route": "/lounge",
      "gradient": [Color(0xFF00B09B), Color(0xFF96C93D)],
      "accentColor": Color(0xFF00806F),
    },
    {
      "title": "ألعاب ومسابقات",
      "sub": "تحديات وجوائز",
      "icon": Icons.sports_esports_rounded,
      "route": "/games",
      "gradient": [Color(0xFFE0F2FE), Color(0xFFF3E8FF)],
      "accentColor": Color(0xFF7E57C2),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = responsive.columns(
          compact: constraints.maxWidth < 340 ? 1 : 2,
          medium: 3,
          expanded: 3,
          large: 4,
        );
        final aspectRatio = responsive.value(
          compact: columns == 1 ? 3.2 : 1.75,
          medium: 2,
          expanded: 2.15,
          large: 2.2,
        );
        const cardHeightScale = .75;
        return GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: quickAccessData.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: aspectRatio / cardHeightScale,
          ),
          itemBuilder: (context, index) {
            final item = quickAccessData[index];
            return _buildModernCard(context, item);
          },
        );
      },
    );
  }

  Widget _buildModernCard(BuildContext context, Map<String, dynamic> item) {
    if (item['route'] == '/games') {
      return _buildGamesCard(context, item);
    }
    final List<Color> gradientColors = item['gradient'];
    final String title = item['title'];
    final isPodcastCard = item['route'] == '/podcast';
    final responsive = context.responsive;
    final iconSize = responsive.value(compact: 42, medium: 48, expanded: 52);

    return InkWell(
      onTap: () {
        if (item['route'] == '/chat') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShareAndChatScreen()),
          );
        } else if (item['route'] == '/favorites') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesScreen()),
          );
        } else if (item['route'] == '/audiobooks') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AudiobooksScreen()),
          );
        } else if (item['route'] == '/podcast') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PodcastsScreen()),
          );
        } else if (item['route'] == '/lounge') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoungeScreen()),
          );
        } else if (item['route'] == '/games') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const GamesScreen()),
          );
        } else {
          try {
            context.push(item['route']);
          } catch (e) {
            debugPrint('Route not found: ${item['route']}');
          }
        }
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.85),
              Colors.white.withValues(alpha: 0.55),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.9),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 10.0,
              ),
              child: Row(
                children: [
                  Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gradientColors[0].withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      item['icon'],
                      color: Colors.white,
                      size: iconSize * .5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontFamily: isPodcastCard
                                ? 'MohammadBoldArt'
                                : null,
                            fontWeight: FontWeight.bold,
                            fontSize: responsive.value(
                              compact: 12,
                              medium: 13,
                              expanded: 14,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['sub'],
                          style: TextStyle(
                            fontFamily: isPodcastCard
                                ? 'MohammadBoldArt'
                                : null,
                            fontWeight: isPodcastCard
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildGamesCard(BuildContext context, Map<String, dynamic> item) {
    final responsive = context.responsive;
    final iconSize = responsive.value(compact: 42, medium: 46, expanded: 50);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const GamesScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFE0F2FE), Color(0xFFF3E8FF)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7E57C2).withValues(alpha: .16),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .92),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7E57C2), Color(0xFF42A5F5)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7E57C2).withValues(alpha: .32),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  item['icon'] as IconData,
                  color: Colors.white,
                  size: iconSize * .52,
                  semanticLabel: 'ألعاب ومسابقات',
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'MohammadBoldArt',
                        color: const Color(0xFF173B70),
                        fontSize: responsive.value(
                          compact: 11,
                          medium: 12,
                          expanded: 13,
                        ),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item['sub'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'MohammadBoldArt',
                        color: Color(0xFF6B7280),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
