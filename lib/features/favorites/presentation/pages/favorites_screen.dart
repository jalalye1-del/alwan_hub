import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/audio/providers/audio_provider.dart';
import 'package:alwan_hub/core/models/favorite_item.dart';
import 'package:alwan_hub/core/providers/favorites_provider.dart';
import 'package:alwan_hub/core/recording/models/recording_file.dart';
import 'package:alwan_hub/core/recording/providers/recording_providers.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/widgets/adaptive_content_image.dart';
import 'package:alwan_hub/features/fm_radio/domain/models/fm_station.dart';
import 'package:alwan_hub/features/fm_radio/presentation/providers/fm_station_provider.dart';
import 'package:alwan_hub/features/lounge/data/lounge_categories.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String? _selectedRootId;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(recordingNotifierProvider.notifier).loadRecordings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _collectEntries();
    final title =
        _selectedCategory ?? _rootById(_selectedRootId)?.title ?? 'المفضلة';

    return PopScope(
      canPop: _selectedRootId == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        body: SafeArea(
          child: Column(
            children: [
              _FavoritesHeader(
                title: title,
                onBack: _handleBack,
                onNotifications: _showNotificationsMessage,
              ),
              Expanded(child: _buildContent(entries)),
            ],
          ),
        ),
      ),
    );
  }

  List<_FavoriteEntry> _collectEntries() {
    final entries = <_FavoriteEntry>[];
    final audioFavorites = ref.watch(audioPlayerProvider).favoritesByCategory;
    final loungeTitles = LoungeCategoriesData.loungeCategories
        .where((category) => category.id != 'holy-quran')
        .map((category) => category.title)
        .toSet();

    for (final categoryEntry in audioFavorites.entries) {
      for (final track in categoryEntry.value) {
        final category = track.category.trim().isEmpty
            ? categoryEntry.key
            : track.category.trim();
        final root = _rootForAudioTrack(track, category, loungeTitles);
        entries.add(
          _FavoriteEntry(
            key: 'audio:${track.id}',
            title: track.title,
            subtitle: track.subtitle,
            imageUrl: track.imageUrl ?? track.coverUrl ?? '',
            rootId: root.id,
            category: root.id == 'lounge' ? category : root.title,
            payload: track,
          ),
        );
      }
    }

    final favoriteStations =
        ref.watch(favoriteFmStationsProvider).valueOrNull ??
        const <FmStation>[];
    for (final station in favoriteStations) {
      entries.add(
        _FavoriteEntry(
          key: 'fm:${station.id}',
          title: station.name,
          subtitle: station.currentProgram.isNotEmpty
              ? station.currentProgram
              : '${station.displayFrequency} • ${station.country}',
          imageUrl: station.displayImage,
          rootId: 'fm',
          category: 'إذاعات FM',
          payload: station,
        ),
      );
    }

    for (final recording in ref.watch(recordingNotifierProvider).favorites) {
      entries.add(
        _FavoriteEntry(
          key: 'recording:${recording.id}',
          title: recording.title,
          subtitle: recording.programName ?? recording.stationName,
          imageUrl: recording.imageUrl ?? '',
          rootId: 'recordings',
          category: 'التسجيلات',
          payload: recording,
        ),
      );
    }

    for (final item in ref.watch(favoritesProvider)) {
      final root = _rootForLegacyItem(item);
      entries.add(
        _FavoriteEntry(
          key: 'legacy:${item.id}',
          title: item.title,
          subtitle: item.subtitle,
          imageUrl: item.imageUrl,
          rootId: root.id,
          category: item.subCategory ?? root.title,
          payload: item,
        ),
      );
    }

    final uniqueEntries = <String, _FavoriteEntry>{};
    for (final entry in entries) {
      uniqueEntries[entry.key] = entry;
    }
    return uniqueEntries.values.toList();
  }

  _FavoriteRoot _rootForAudioTrack(
    AudioTrack track,
    String category,
    Set<String> loungeTitles,
  ) {
    if (track.isFm || track.sourceType == AudioSourceType.fm) {
      return _rootById('fm')!;
    }
    if (track.sourceType == AudioSourceType.audiobook) {
      return _rootById('audio_books')!;
    }
    if (track.sourceType == AudioSourceType.podcast) {
      return _rootById('podcasts')!;
    }
    if (category.contains('القرآن') || category.contains('تلاوة')) {
      return _rootById('quran')!;
    }
    if (loungeTitles.contains(category)) {
      return _rootById('lounge')!;
    }
    if (track.sourceType == AudioSourceType.program) {
      return _rootById('programs')!;
    }
    return _rootById('other')!;
  }

  _FavoriteRoot _rootForLegacyItem(FavoriteItem item) {
    return switch (item.type) {
      FavoriteType.yemeniSongs ||
      FavoriteType.arabicSongs ||
      FavoriteType.islamicNasheed ||
      FavoriteType.poemsAndZamil => _rootById('lounge')!,
      FavoriteType.quran => _rootById('quran')!,
      FavoriteType.programs => _rootById('programs')!,
      FavoriteType.audioBooks => _rootById('audio_books')!,
      FavoriteType.podcasts => _rootById('podcasts')!,
      FavoriteType.other => _rootById('other')!,
    };
  }

  Widget _buildContent(List<_FavoriteEntry> entries) {
    if (_selectedRootId == null) return _buildHome(entries);
    final rootEntries = entries
        .where((entry) => entry.rootId == _selectedRootId)
        .toList();
    if (_selectedRootId == 'lounge' && _selectedCategory == null) {
      return _buildLoungeCategories(rootEntries);
    }
    final visibleEntries = _selectedCategory == null
        ? rootEntries
        : rootEntries
              .where((entry) => entry.category == _selectedCategory)
              .toList();
    return _buildEntriesList(visibleEntries);
  }

  Widget _buildHome(List<_FavoriteEntry> entries) {
    final roots = _favoriteRoots
        .where((root) => entries.any((entry) => entry.rootId == root.id))
        .toList();
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: _FavoritesBanner()),
        SliverToBoxAdapter(
          child: Padding(
            padding: context.responsive.pagePadding.copyWith(
              top: 24,
              bottom: 14,
            ),
            child: const _FavoritesHeading(
              title: 'تصنيفات المفضلة',
              subtitle: 'كل عنصر يظهر داخل القسم الذي أُضيف منه فقط',
            ),
          ),
        ),
        if (roots.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyFavorites(),
          )
        else
          _rootGrid(roots, entries),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  SliverPadding _rootGrid(
    List<_FavoriteRoot> roots,
    List<_FavoriteEntry> entries,
  ) {
    final responsive = context.responsive;
    return SliverPadding(
      padding: responsive.pagePadding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: responsive.columns(
            compact: 2,
            medium: 3,
            expanded: 4,
            large: 5,
          ),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: responsive.value(
            compact: 1.2,
            medium: 1.3,
            expanded: 1.4,
          ),
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final root = roots[index];
          final count = entries
              .where((entry) => entry.rootId == root.id)
              .length;
          return _FavoriteCategoryCard(
            title: root.title,
            icon: root.icon,
            color: root.color,
            count: count,
            onTap: () => setState(() => _selectedRootId = root.id),
          );
        }, childCount: roots.length),
      ),
    );
  }

  Widget _buildLoungeCategories(List<_FavoriteEntry> entries) {
    final categories = entries.map((entry) => entry.category).toSet().toList()
      ..sort();
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: context.responsive.pagePadding.copyWith(
              top: 20,
              bottom: 14,
            ),
            child: const _FavoritesHeading(
              title: 'استراحة ألوان',
              subtitle: 'اختر القسم الأصلي للمحتوى المفضل',
            ),
          ),
        ),
        SliverPadding(
          padding: context.responsive.pagePadding,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final category = categories[index];
              final count = entries
                  .where((entry) => entry.category == category)
                  .length;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _FavoriteCategoryCard(
                  title: category,
                  icon: Icons.library_music_rounded,
                  color: const Color(0xFF5B4CF0),
                  count: count,
                  compact: true,
                  onTap: () => setState(() => _selectedCategory = category),
                ),
              );
            }, childCount: categories.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildEntriesList(List<_FavoriteEntry> entries) {
    if (entries.isEmpty) return const _EmptyFavorites();
    return ListView.separated(
      padding: context.responsive.pagePadding.copyWith(top: 18, bottom: 80),
      physics: const BouncingScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final entry = entries[index];
        return _FavoriteItemCard(
          entry: entry,
          onPlay: () => _playEntry(entry),
          onRemove: () => _removeEntry(entry),
        );
      },
    );
  }

  Future<void> _playEntry(_FavoriteEntry entry) async {
    final payload = entry.payload;
    final controller = ref.read(audioControllerProvider);
    if (payload is AudioTrack) {
      await controller.play(payload);
    } else if (payload is FmStation) {
      await controller.play(payload.toAudioTrack());
    } else if (payload is RecordingFile) {
      await controller.play(
        AudioTrack(
          id: 'recording-${payload.id}',
          title: payload.title,
          subtitle: payload.folderName,
          url: payload.filePath,
          imageUrl: payload.imageUrl,
          sourceType: AudioSourceType.local,
          category: 'التسجيلات',
          duration: payload.duration,
        ),
      );
    } else if (payload is FavoriteItem) {
      await controller.play(
        AudioTrack(
          id: payload.id,
          title: payload.title,
          subtitle: payload.subtitle ?? '',
          url: payload.audioUrl,
          imageUrl: payload.imageUrl,
          sourceType: _sourceTypeForLegacy(payload.type),
          category: entry.category,
        ),
      );
    }
  }

  Future<void> _removeEntry(_FavoriteEntry entry) async {
    final payload = entry.payload;
    if (payload is AudioTrack) {
      await ref.read(audioControllerProvider).toggleFavorite(payload);
    } else if (payload is FmStation) {
      await ref
          .read(favoriteNotifierProvider.notifier)
          .toggleFavorite(payload.id);
    } else if (payload is RecordingFile) {
      await ref
          .read(recordingNotifierProvider.notifier)
          .toggleFavorite(payload.id);
    } else if (payload is FavoriteItem) {
      await ref.read(favoritesProvider.notifier).toggleFavorite(payload);
    }
  }

  AudioSourceType _sourceTypeForLegacy(FavoriteType type) {
    return switch (type) {
      FavoriteType.audioBooks => AudioSourceType.audiobook,
      FavoriteType.podcasts => AudioSourceType.podcast,
      FavoriteType.programs => AudioSourceType.program,
      _ => AudioSourceType.music,
    };
  }

  void _handleBack() {
    if (_selectedCategory != null) {
      setState(() => _selectedCategory = null);
      return;
    }
    if (_selectedRootId != null) {
      setState(() => _selectedRootId = null);
      return;
    }
    Navigator.maybePop(context);
  }

  void _showNotificationsMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لا توجد إشعارات جديدة حالياً.')),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  const _FavoritesHeader({
    required this.title,
    required this.onBack,
    required this.onNotifications,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsive.pagePadding.copyWith(top: 10, bottom: 10),
      child: Row(
        children: [
          _HeaderButton(
            icon: Icons.arrow_forward_ios_rounded,
            tooltip: 'العودة',
            onTap: onBack,
          ),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF171827),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _HeaderButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'الإشعارات',
            onTap: onNotifications,
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF25263D), size: 21),
        ),
      ),
    );
  }
}

class _FavoritesBanner extends StatelessWidget {
  const _FavoritesBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsive.pagePadding.copyWith(top: 4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: AspectRatio(
            aspectRatio: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const AdaptiveContentImage(
                    source: 'assets/images/lounge/الأغاني العربية.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    semanticLabel: 'بنر المفضلة الإعلاني',
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          const Color(0xFFC8174F).withValues(alpha: .94),
                          const Color(0xFFFF3366).withValues(alpha: .64),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'اختياراتك الأقرب إليك',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'محفوظة ومنظمة حسب مصدرها',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
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
}

class _FavoritesHeading extends StatelessWidget {
  const _FavoritesHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF171827),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF77798C), fontSize: 12),
        ),
      ],
    );
  }
}

class _FavoriteCategoryCard extends StatelessWidget {
  const _FavoriteCategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.count,
    required this.onTap,
    this.compact = false,
  });

  final String title;
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Color.lerp(Colors.white, color, .09)!],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .15),
                blurRadius: 17,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF25263D),
                        fontSize: compact ? 14 : 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count عنصر',
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_back_ios_new_rounded, color: color, size: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteItemCard extends StatelessWidget {
  const _FavoriteItemCard({
    required this.entry,
    required this.onPlay,
    required this.onRemove,
  });

  final _FavoriteEntry entry;
  final VoidCallback onPlay;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF3366).withValues(alpha: .07),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AdaptiveContentImage(
              source: entry.imageUrl,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              semanticLabel: entry.title,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if ((entry.subtitle ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    entry.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'تشغيل',
            onPressed: onPlay,
            icon: const Icon(
              Icons.play_circle_fill_rounded,
              color: Color(0xFF5B4CF0),
              size: 34,
            ),
          ),
          IconButton(
            tooltip: 'إزالة من المفضلة',
            onPressed: onRemove,
            icon: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFFF3366),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border_rounded,
              size: 74,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 14),
            const Text(
              'لا توجد عناصر مفضلة حالياً',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'اضغط أيقونة القلب في أي واجهة لتظهر هنا داخل قسمها الصحيح',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteEntry {
  const _FavoriteEntry({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.rootId,
    required this.category,
    required this.payload,
  });

  final String key;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final String rootId;
  final String category;
  final Object payload;
}

class _FavoriteRoot {
  const _FavoriteRoot({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });

  final String id;
  final String title;
  final IconData icon;
  final Color color;
}

const _favoriteRoots = <_FavoriteRoot>[
  _FavoriteRoot(
    id: 'lounge',
    title: 'استراحة ألوان',
    icon: Icons.headphones_rounded,
    color: Color(0xFF5B4CF0),
  ),
  _FavoriteRoot(
    id: 'fm',
    title: 'إذاعات FM',
    icon: Icons.radio_rounded,
    color: Color(0xFF0288D1),
  ),
  _FavoriteRoot(
    id: 'quran',
    title: 'القرآن الكريم',
    icon: Icons.auto_stories_rounded,
    color: Color(0xFF00796B),
  ),
  _FavoriteRoot(
    id: 'audio_books',
    title: 'الكتب الصوتية',
    icon: Icons.library_books_rounded,
    color: Color(0xFFF57C00),
  ),
  _FavoriteRoot(
    id: 'podcasts',
    title: 'بودكاست ألوان',
    icon: Icons.podcasts_rounded,
    color: Color(0xFFDB2777),
  ),
  _FavoriteRoot(
    id: 'programs',
    title: 'البرامج',
    icon: Icons.video_library_rounded,
    color: Color(0xFF455A64),
  ),
  _FavoriteRoot(
    id: 'recordings',
    title: 'التسجيلات',
    icon: Icons.mic_rounded,
    color: Color(0xFFE53955),
  ),
  _FavoriteRoot(
    id: 'other',
    title: 'أخرى',
    icon: Icons.favorite_rounded,
    color: Color(0xFF7C3AED),
  ),
];

_FavoriteRoot? _rootById(String? id) {
  for (final root in _favoriteRoots) {
    if (root.id == id) return root;
  }
  return null;
}
