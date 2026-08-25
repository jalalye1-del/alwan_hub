import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/router/app_router.dart';
import 'package:alwan_hub/features/games/domain/games_catalog.dart';
import 'package:alwan_hub/features/games/presentation/pages/competition_flow_screens.dart';
import 'package:alwan_hub/features/games/presentation/pages/entertainment_game_screen.dart';
import 'package:alwan_hub/features/games/presentation/pages/quiz_challenge_screen.dart';

const _gamesFont = 'MohammadBoldArt';
const _pageBackground = Color(0xFFF8FAFF);
const _surface = Colors.white;
const _ink = Color(0xFF17164F);
const _purple = Color(0xFF8E2DE2);
const _blue = Color(0xFF334FEA);
const _muted = Color(0xFF74788F);
const _line = Color(0xFFE7E9F6);

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  static const _filters = [
    ('مسابقات برامج الـ FM', Icons.radio_rounded),
    ('مسابقة سين جيم', Icons.quiz_rounded),
    ('المسابقة الثقافية', Icons.public_rounded),
  ];

  int _selectedTab = 0;
  int _selectedFilter = 0;
  final Set<int> _favorites = {};
  final Set<int> _reminders = {};

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: _gamesFont,
              fontWeight: FontWeight.w700,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _ink,
        ),
      );
  }

  void _handleBack() {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    context.go(AppRoutes.homePath);
  }

  Future<void> _openChallenge(QuizChallenge challenge) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizChallengeScreen(challenge: challenge),
      ),
    );
  }

  Future<void> _openEntertainmentGame(EntertainmentGame game) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EntertainmentGameScreen(game: game)),
    );
  }

  Future<void> _handleProgramAction(
    CompetitionProgram program,
    String action,
  ) async {
    if (action.contains('اتصل')) {
      if (program.contactLines.isEmpty) {
        _showMessage('لا توجد أرقام اتصال متاحة حالياً');
        return;
      }
      await CallParticipationSheet.show(context, program);
      return;
    }

    if (action.contains('استمع')) {
      await ref
          .read(audioControllerProvider)
          .play(
            const AudioTrack(
              id: 'live_alwan_fm',
              title: 'البث المباشر',
              subtitle: 'إذاعة ألوان FM 88.7',
              url: GamesCatalog.liveStreamUrl,
              imageUrl: 'assets/images/splash_logo.png',
              presenterName: 'إذاعة ألوان',
              isLiveStream: true,
              isFm: true,
              sourceType: AudioSourceType.fm,
              category: 'البث المباشر',
            ),
          );
      if (mounted) _showMessage('تم تشغيل البث المباشر الرئيسي');
      return;
    }

    if (action.contains('اشتراك') || action.contains('التفاصيل')) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CompetitionDetailsScreen(
            program: program,
            returnToGamesBuilder: (_) => const GamesScreen(),
          ),
        ),
      );
      return;
    }

    _showMessage('$action — ${program.title}');
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: _gamesFont),
        primaryTextTheme: baseTheme.primaryTextTheme.apply(
          fontFamily: _gamesFont,
        ),
      ),
      child: Scaffold(
        backgroundColor: _pageBackground,
        floatingActionButton: FloatingActionButton(
          heroTag: 'games-help',
          onPressed: () => context.pushNamed(
            AppRoutes.alwanAi,
            queryParameters: const {'listen': '1'},
          ),
          tooltip: 'مساعد ألوان',
          backgroundColor: _purple,
          foregroundColor: Colors.white,
          child: const Icon(Icons.support_agent_rounded),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 96),
            child: ResponsiveContent(
              maxWidth: 980,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _GamesHeader(onBack: _handleBack),
                  const SizedBox(height: 12),
                  const _SponsorBanner(),
                  const SizedBox(height: 12),
                  _MainTabs(
                    selectedIndex: _selectedTab,
                    onSelected: (index) => setState(() => _selectedTab = index),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: _selectedTab == 0
                        ? _CompetitionsContent(
                            key: const ValueKey('competitions'),
                            filters: _filters,
                            selectedFilter: _selectedFilter,
                            onFilterSelected: (index) =>
                                setState(() => _selectedFilter = index),
                            favorites: _favorites,
                            reminders: _reminders,
                            onFavorite: (index) => setState(() {
                              _favorites.contains(index)
                                  ? _favorites.remove(index)
                                  : _favorites.add(index);
                            }),
                            onReminder: (index) => setState(() {
                              _reminders.contains(index)
                                  ? _reminders.remove(index)
                                  : _reminders.add(index);
                            }),
                            onProgramAction: _handleProgramAction,
                            onOpenChallenge: _openChallenge,
                          )
                        : _GamesContent(
                            key: const ValueKey('games'),
                            onPlay: _openEntertainmentGame,
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
}

class _GamesHeader extends StatelessWidget {
  const _GamesHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.responsive.value(compact: 100, medium: 106),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 72),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [_blue, _purple]),
                      ),
                      child: const Icon(
                        Icons.sports_esports_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'مسابقات وألعاب ألوان',
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: _gamesFont,
                          color: _ink,
                          fontSize: context.responsive.value(
                            compact: 21,
                            medium: 26,
                          ),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                const Text(
                  'حلبة التحدي المباشر وبث الإشعارات الجماعية',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: _gamesFont,
                    color: _muted,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: context.responsive.pagePadding.left,
            top: 12,
            child: Material(
              color: const Color(0xFFF0F2FF),
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: onBack,
                tooltip: 'العودة',
                icon: const Icon(Icons.arrow_back_rounded),
                color: _blue,
                iconSize: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SponsorBanner extends StatelessWidget {
  const _SponsorBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsive.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SizedBox(
            width: double.infinity,
            height: 200,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD9D9F5)),
                boxShadow: [
                  BoxShadow(
                    color: _blue.withValues(alpha: .12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/banners/banner1.jpg',
                fit: BoxFit.cover,
                semanticLabel: 'بنر إعلاني',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MainTabs extends StatelessWidget {
  const _MainTabs({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsive.pagePadding,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              _purple.withValues(alpha: .18),
              _blue.withValues(alpha: .1),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _purple.withValues(alpha: .22)),
          boxShadow: [
            BoxShadow(
              color: _purple.withValues(alpha: .08),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            _TabButton(
              label: 'المسابقات',
              icon: Icons.quiz_rounded,
              selected: selectedIndex == 0,
              onTap: () => onSelected(0),
            ),
            _TabButton(
              label: 'الألعاب والتسلية',
              icon: Icons.sports_esports_rounded,
              selected: selectedIndex == 1,
              onTap: () => onSelected(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: [_blue, _purple])
                : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: _purple.withValues(alpha: .24),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? Colors.white : _purple, size: 21),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: _gamesFont,
                    color: selected ? Colors.white : _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompetitionsContent extends StatelessWidget {
  const _CompetitionsContent({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.favorites,
    required this.reminders,
    required this.onFavorite,
    required this.onReminder,
    required this.onProgramAction,
    required this.onOpenChallenge,
  });

  final List<(String, IconData)> filters;
  final int selectedFilter;
  final ValueChanged<int> onFilterSelected;
  final Set<int> favorites;
  final Set<int> reminders;
  final ValueChanged<int> onFavorite;
  final ValueChanged<int> onReminder;
  final Future<void> Function(CompetitionProgram, String) onProgramAction;
  final Future<void> Function(QuizChallenge) onOpenChallenge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: context.responsive.pagePadding,
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final selected = selectedFilter == index;
              return ChoiceChip(
                selected: selected,
                onSelected: (_) => onFilterSelected(index),
                showCheckmark: false,
                avatar: Icon(
                  filters[index].$2,
                  size: 17,
                  color: selected ? Colors.white : _blue,
                ),
                label: Text(
                  filters[index].$1,
                  style: const TextStyle(
                    fontFamily: _gamesFont,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                labelStyle: TextStyle(
                  fontFamily: _gamesFont,
                  color: selected ? Colors.white : _ink,
                  fontWeight: FontWeight.w700,
                ),
                backgroundColor: Colors.white,
                selectedColor: _purple,
                side: BorderSide(
                  color: selected ? _purple : const Color(0xFFD8DAEF),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              );
            },
          ),
        ),
        if (selectedFilter == 0) ...[
          const SizedBox(height: 20),
          Padding(
            padding: context.responsive.pagePadding,
            child: const Row(
              children: [
                Icon(Icons.radio_rounded, color: _blue, size: 22),
                SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'مسابقات البث الإذاعي المباشر',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: _gamesFont,
                      color: _ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < GamesCatalog.programs.length; index++)
            Padding(
              padding: EdgeInsets.fromLTRB(
                context.responsive.pagePadding.left,
                0,
                context.responsive.pagePadding.right,
                14,
              ),
              child: _CompetitionCard(
                program: GamesCatalog.programs[index],
                favorite: favorites.contains(index),
                reminder: reminders.contains(index),
                onFavorite: () => onFavorite(index),
                onReminder: () => onReminder(index),
                onAction: (action) =>
                    onProgramAction(GamesCatalog.programs[index], action),
              ),
            ),
        ] else ...[
          const SizedBox(height: 20),
          Padding(
            padding: context.responsive.pagePadding,
            child: _ChallengeCategorySelector(
              showSinJimCategories: selectedFilter == 1,
              challenges: selectedFilter == 1
                  ? GamesCatalog.sinJimChallenges
                  : const [GamesCatalog.culturalChallenge],
              onOpenChallenge: onOpenChallenge,
            ),
          ),
        ],
      ],
    );
  }
}

class _ChallengeCategorySelector extends StatelessWidget {
  const _ChallengeCategorySelector({
    required this.showSinJimCategories,
    required this.challenges,
    required this.onOpenChallenge,
  });

  final bool showSinJimCategories;
  final List<QuizChallenge> challenges;
  final Future<void> Function(QuizChallenge) onOpenChallenge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [_blue, _purple],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: _purple.withValues(alpha: .2),
                blurRadius: 22,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: .2)),
                ),
                child: Icon(
                  showSinJimCategories
                      ? Icons.category_rounded
                      : Icons.public_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .17),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'المرحلة الثانية • اختر التصنيف',
                        style: TextStyle(
                          fontFamily: _gamesFont,
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      showSinJimCategories
                          ? 'تصنيفات مسابقة سين جيم'
                          : 'المسابقة الثقافية العامة',
                      style: const TextStyle(
                        fontFamily: _gamesFont,
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      showSinJimCategories
                          ? 'اختر مجالاً وابدأ جولة معرفية مباشرة'
                          : 'أسئلة متنوعة وتحديات مفتوحة للجميع',
                      style: const TextStyle(
                        fontFamily: _gamesFont,
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = showSinJimCategories || constraints.maxWidth >= 650
                ? 2
                : 1;
            const gap = 12.0;
            final width =
                (constraints.maxWidth - ((columns - 1) * gap)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: challenges
                  .map(
                    (challenge) => SizedBox(
                      width: width,
                      child: _ChallengeCategoryCard(
                        challenge: challenge,
                        onTap: () => onOpenChallenge(challenge),
                      ),
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _ChallengeCategoryCard extends StatelessWidget {
  const _ChallengeCategoryCard({required this.challenge, required this.onTap});

  final QuizChallenge challenge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accentFor(challenge.id);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 190),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, accent.withValues(alpha: .045)],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: accent.withValues(alpha: .3)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: .09),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 51,
                    height: 51,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accent, Color.lerp(accent, _purple, .45)!],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: .22),
                          blurRadius: 11,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      _iconFor(challenge.id),
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 33,
                    height: 33,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .09),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: accent,
                      size: 19,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                challenge.category,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: _gamesFont,
                  color: _ink,
                  fontSize: 16,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                challenge.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: _gamesFont,
                  color: _muted,
                  fontSize: 10,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 5,
                runSpacing: 4,
                children: [
                  _CategoryMetric(
                    icon: Icons.quiz_outlined,
                    label: '${challenge.questions.length} أسئلة',
                    color: accent,
                  ),
                  _CategoryMetric(
                    icon: Icons.groups_2_outlined,
                    label: '${challenge.participants.length} لاعبين',
                    color: accent,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(String id) {
    if (id.contains('history')) return Icons.travel_explore_rounded;
    if (id.contains('science')) return Icons.science_rounded;
    if (id.contains('religion')) return Icons.menu_book_rounded;
    if (id.contains('arts')) return Icons.sports_soccer_rounded;
    return Icons.public_rounded;
  }

  Color _accentFor(String id) {
    if (id.contains('history')) return _blue;
    if (id.contains('science')) return const Color(0xFF168F7B);
    if (id.contains('religion')) return _purple;
    if (id.contains('arts')) return const Color(0xFF5B43E4);
    return _blue;
  }
}

class _CategoryMetric extends StatelessWidget {
  const _CategoryMetric({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: _gamesFont,
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  const _CompetitionCard({
    required this.program,
    required this.favorite,
    required this.reminder,
    required this.onFavorite,
    required this.onReminder,
    required this.onAction,
  });

  final CompetitionProgram program;
  final bool favorite;
  final bool reminder;
  final VoidCallback onFavorite;
  final VoidCallback onReminder;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final compact = context.responsive.isCompact;
    return Container(
      padding: EdgeInsets.all(compact ? 15 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [program.color.withValues(alpha: .1), _surface],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: program.color.withValues(alpha: .38)),
        boxShadow: [
          BoxShadow(
            color: program.color.withValues(alpha: .1),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: compact ? 54 : 68,
                height: compact ? 54 : 68,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      program.color,
                      Color.lerp(program.color, _purple, .38)!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _programIcon(program.title),
                  color: Colors.white,
                  size: compact ? 27 : 33,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title,
                      style: TextStyle(
                        fontFamily: _gamesFont,
                        color: _ink,
                        fontSize: compact ? 18 : 21,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      program.sponsor,
                      style: TextStyle(
                        fontFamily: _gamesFont,
                        color: program.color,
                        fontSize: compact ? 11 : 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(program: program),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              _RoundAction(
                icon: favorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: favorite ? program.color : _muted,
                tooltip: 'المفضلة',
                onTap: onFavorite,
              ),
              const SizedBox(width: 6),
              _RoundAction(
                icon: reminder
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: reminder ? program.color : _muted,
                tooltip: 'التذكير',
                onTap: onReminder,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            program.description,
            style: TextStyle(
              fontFamily: _gamesFont,
              color: _muted,
              fontSize: compact ? 12 : 14,
              height: 1.65,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: _ProgramButton(
                  label: program.actions.first,
                  icon: _primaryIcon(program.actions.first),
                  color: program.color,
                  onPressed: () =>
                      onAction('${program.actions.first} — ${program.title}'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProgramButton(
                  label: program.actions.last,
                  icon: _secondaryIcon(program.actions.last),
                  color: Color.lerp(program.color, _blue, .45)!,
                  onPressed: () {
                    if (program.actions.last.contains('تذكير') ||
                        program.actions.last.contains('ذكرني')) {
                      onReminder();
                    }
                    onAction('${program.actions.last} — ${program.title}');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _primaryIcon(String label) => label.contains('اتصل')
      ? Icons.call_rounded
      : label.contains('اشتراك')
      ? Icons.how_to_reg_rounded
      : Icons.visibility_rounded;

  IconData _secondaryIcon(String label) =>
      label.contains('بث') ? Icons.volume_up_rounded : Icons.alarm_rounded;

  IconData _programIcon(String title) {
    if (title.contains('صندوق')) return Icons.redeem_rounded;
    if (title.contains('الليلة')) return Icons.nightlife_rounded;
    return Icons.mic_rounded;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.program});

  final CompetitionProgram program;

  @override
  Widget build(BuildContext context) {
    final live = program.status.contains('مباشر');
    final statusColor = live ? const Color(0xFFE53935) : program.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: .22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            live
                ? Icons.fiber_manual_record_rounded
                : Icons.calendar_month_rounded,
            color: statusColor,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            program.status,
            style: TextStyle(
              fontFamily: _gamesFont,
              color: statusColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, color: color, size: 22),
    );
  }
}

class _ProgramButton extends StatelessWidget {
  const _ProgramButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontFamily: _gamesFont,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

class _GamesContent extends StatelessWidget {
  const _GamesContent({super.key, required this.onPlay});

  final Future<void> Function(EntertainmentGame) onPlay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsive.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.extension_rounded, color: _blue, size: 23),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'ألعاب ألوان التفاعلية',
                  style: TextStyle(
                    fontFamily: _gamesFont,
                    color: _ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1AA984).withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Color(0xFF1AA984), size: 8),
                    const SizedBox(width: 5),
                    Text(
                      '${GamesCatalog.games.length} متاحة الآن',
                      style: const TextStyle(
                        fontFamily: _gamesFont,
                        color: Color(0xFF168F7B),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'اختر لعبتك، اجمع النقاط وتقدّم في لوحة الصدارة',
            style: TextStyle(
              fontFamily: _gamesFont,
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 780
                  ? 3
                  : constraints.maxWidth >= 520
                  ? 2
                  : 1;
              const gap = 14.0;
              final cardWidth =
                  (constraints.maxWidth - (columns - 1) * gap) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: GamesCatalog.games
                    .map(
                      (game) => SizedBox(
                        width: cardWidth,
                        child: _GameCard(
                          game: game,
                          onPlay: () => onPlay(game),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.onPlay});

  final EntertainmentGame game;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPlay,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: game.color.withValues(alpha: .32)),
            boxShadow: [
              BoxShadow(
                color: game.color.withValues(alpha: .07),
                blurRadius: 17,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: game.color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_gameIcon(game.id), color: game.color, size: 30),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontFamily: _gamesFont,
                        color: _ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      game.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: _gamesFont,
                        color: _muted,
                        fontSize: 11,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        _GameMetric(
                          icon: Icons.group_outlined,
                          label: game.mode,
                          color: game.color,
                        ),
                        _GameMetric(
                          icon: Icons.timer_outlined,
                          label: '${game.estimatedMinutes} د',
                          color: game.color,
                        ),
                        _GameMetric(
                          icon: Icons.stars_rounded,
                          label: '+${game.rewardPoints} نقطة',
                          color: game.color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 37,
                height: 37,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: game.color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _gameIcon(String id) {
    if (id == 'memory_match') return Icons.extension_rounded;
    if (id == 'tic_tac_toe') return Icons.grid_3x3_rounded;
    return Icons.edit_note_rounded;
  }
}

class _GameMetric extends StatelessWidget {
  const _GameMetric({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: _gamesFont,
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
