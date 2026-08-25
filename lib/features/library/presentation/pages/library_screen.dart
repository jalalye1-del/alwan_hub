import 'package:flutter/material.dart' hide Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';

import 'package:alwan_hub/core/recording/presentation/recordings_screen.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/router/app_router.dart';
import 'package:alwan_hub/core/widgets/adaptive_content_image.dart';
import 'package:alwan_hub/features/library/domain/entities/folder_type.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item_type.dart';
import 'package:alwan_hub/features/library/domain/entities/library_taxonomy_node.dart';
import 'package:alwan_hub/features/library/domain/entities/user_folder.dart';
import 'package:alwan_hub/features/library/presentation/providers/library_provider.dart';
import 'package:alwan_hub/features/lounge/data/lounge_catalog_data.dart';
import 'package:alwan_hub/features/lounge/domain/models/lounge_catalog.dart';
import 'package:alwan_hub/features/podcasts/domain/entities/podcast_episode.dart';
import 'package:alwan_hub/features/podcasts/domain/mappers/podcast_episode_mapper.dart';
import 'package:alwan_hub/features/podcasts/presentation/pages/podcast_video_player_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final List<String> _navigationPath = [];
  final Set<String> _selectedItemIds = {};
  bool _initialized = false;

  String? get _currentNodeId =>
      _navigationPath.isEmpty ? null : _navigationPath.last;

  LibraryTaxonomyNode? get _currentNode {
    final nodeId = _currentNodeId;
    return nodeId == null ? null : LibraryTaxonomy.byId(nodeId);
  }

  _CollectionRoute? get _currentCollectionRoute {
    final nodeId = _currentNodeId;
    return nodeId == null ? null : _CollectionRoute.tryParse(nodeId);
  }

  String get _currentTitle {
    if (_selectedItemIds.isNotEmpty) {
      return '${_selectedItemIds.length} ملف محدد';
    }
    final collectionRoute = _currentCollectionRoute;
    if (collectionRoute != null) {
      return collectionRoute.item.displayTitle;
    }
    return _currentNode?.title ?? 'مكتبتي';
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _initialized = true;
      Future<void>.microtask(
        () => ref.read(libraryInitializerProvider).initialize(),
      );
    }

    final itemsAsync = ref.watch(libraryItemsProvider);
    final foldersAsync = ref.watch(libraryFoldersProvider);

    return PopScope(
      canPop: _navigationPath.isEmpty && _selectedItemIds.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectedItemIds.isNotEmpty) {
          setState(() => _selectedItemIds.clear());
        } else if (!didPop && _navigationPath.isNotEmpty) {
          setState(() => _navigationPath.removeLast());
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        body: SafeArea(
          child: itemsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _LibraryError(message: error.toString()),
            data: (items) => Column(
              children: [
                _LibraryHeader(
                  title: _currentTitle,
                  onBack: _handleBack,
                  onNotifications: _showNotificationsMessage,
                  onCreateFolder: _currentNodeId == 'folders'
                      ? _showCreateFolderDialog
                      : null,
                ),
                Expanded(child: _buildCurrentContent(items, foldersAsync)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentContent(
    List<LibraryItem> items,
    AsyncValue<List<UserFolder>> foldersAsync,
  ) {
    final nodeId = _currentNodeId;
    if (nodeId == null) return _buildLibraryHome(items, foldersAsync);
    final collectionRoute = _currentCollectionRoute;
    if (collectionRoute != null) {
      return _buildItemsList(
        _itemsForCollection(items, collectionRoute.item),
        emptyTitle: collectionRoute.item.displayTitle,
        accentColor: Color(collectionRoute.item.accentColorValue),
      );
    }
    if (nodeId == 'recordings') {
      return const RecordingsScreen(embedded: true);
    }
    if (nodeId == 'folders') return _buildFoldersView(foldersAsync);

    final node = _currentNode;
    if (node == null) return const SizedBox.shrink();
    final children = _visibleChildren(node.id, items);
    if (children.isNotEmpty) {
      return _buildNodeGrid(children, items, foldersAsync);
    }
    final collections = _visibleCollections(node, items);
    if (collections.isNotEmpty) {
      return _buildCollectionGrid(node, collections, items);
    }
    return _buildItemsList(
      items.where(node.matches).toList(),
      emptyTitle: node.title,
      accentColor: Color(node.colorValue),
    );
  }

  Widget _buildCollectionGrid(
    LibraryTaxonomyNode node,
    List<LoungeCatalogItem> collections,
    List<LibraryItem> items,
  ) {
    final responsive = context.responsive;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: responsive.pagePadding.copyWith(top: 20, bottom: 14),
            child: _SectionHeading(
              title: node.title,
              subtitle: 'اختر صاحب المحتوى لعرض ملفاته المحفوظة',
            ),
          ),
        ),
        SliverPadding(
          padding: responsive.pagePadding,
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: responsive.columns(
                compact: 3,
                medium: 4,
                expanded: 5,
                large: 6,
              ),
              crossAxisSpacing: responsive.value(compact: 10, medium: 16),
              mainAxisSpacing: responsive.value(compact: 16, medium: 22),
              childAspectRatio: responsive.value(
                compact: .70,
                medium: .74,
                expanded: .78,
              ),
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final collection = collections[index];
              final count = _itemsForCollection(items, collection).length;
              return _LibraryCollectionCard(
                item: collection,
                itemCount: count,
                onTap: () => setState(
                  () => _navigationPath.add(
                    _CollectionRoute.encode(node.id, collection),
                  ),
                ),
              );
            }, childCount: collections.length),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildLibraryHome(
    List<LibraryItem> items,
    AsyncValue<List<UserFolder>> foldersAsync,
  ) {
    final rootNodes = _visibleChildren(null, items);
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: _LibraryBanner()),
        SliverToBoxAdapter(
          child: Padding(
            padding: context.responsive.pagePadding.copyWith(
              top: 24,
              bottom: 14,
            ),
            child: const _SectionHeading(
              title: 'تصنيفات مكتبتي',
              subtitle: 'تظهر الأقسام تلقائياً عند حفظ محتواها',
            ),
          ),
        ),
        _nodeGridSliver(rootNodes, items, foldersAsync),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  Widget _buildNodeGrid(
    List<LibraryTaxonomyNode> nodes,
    List<LibraryItem> items,
    AsyncValue<List<UserFolder>> foldersAsync,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: context.responsive.pagePadding.copyWith(
              top: 20,
              bottom: 14,
            ),
            child: _SectionHeading(
              title: _currentNode?.title ?? 'التصنيفات',
              subtitle: 'اختر التصنيف لعرض الملفات المحفوظة بداخله',
            ),
          ),
        ),
        _nodeGridSliver(nodes, items, foldersAsync),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }

  SliverPadding _nodeGridSliver(
    List<LibraryTaxonomyNode> nodes,
    List<LibraryItem> items,
    AsyncValue<List<UserFolder>> foldersAsync,
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
            expanded: 1.38,
          ),
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final node = nodes[index];
          return _LibraryCategoryCard(
            node: node,
            itemCount: _nodeCount(node, items, foldersAsync),
            onTap: () => setState(() => _navigationPath.add(node.id)),
          );
        }, childCount: nodes.length),
      ),
    );
  }

  List<LibraryTaxonomyNode> _visibleChildren(
    String? parentId,
    List<LibraryItem> items,
  ) {
    return LibraryTaxonomy.childrenOf(parentId).where((node) {
      if (node.alwaysVisible) return true;
      return items.any(node.matches);
    }).toList();
  }

  List<LoungeCatalogItem> _visibleCollections(
    LibraryTaxonomyNode node,
    List<LibraryItem> items,
  ) {
    final catalogId = _catalogIdForNode(node);
    if (catalogId == null) return const [];
    final catalog = LoungeCatalogData.byCategoryId(catalogId);
    if (catalog == null) return const [];

    final nodeItems = items.where(node.matches).toList();
    final collections =
        catalog.items.where((item) {
          if (!item.isActive) return false;
          if (node.parentId == 'poetry-and-sheelat' &&
              item.groupId != node.id) {
            return false;
          }
          return nodeItems.any(
            (savedItem) => _collectionMatches(savedItem, item),
          );
        }).toList()..sort(
          (first, second) => first.sortOrder.compareTo(second.sortOrder),
        );
    return collections;
  }

  String? _catalogIdForNode(LibraryTaxonomyNode node) {
    if (node.parentId == 'poetry-and-sheelat') return 'poetry-and-sheelat';
    if (node.id == 'quran') return 'holy-quran';
    return LoungeCatalogData.byCategoryId(node.id) == null ? null : node.id;
  }

  List<LibraryItem> _itemsForCollection(
    List<LibraryItem> items,
    LoungeCatalogItem collection,
  ) {
    return items.where((item) => _collectionMatches(item, collection)).toList();
  }

  bool _collectionMatches(LibraryItem savedItem, LoungeCatalogItem collection) {
    if (savedItem.sourceId == collection.id ||
        savedItem.sourceId.startsWith('${collection.id}-')) {
      return true;
    }
    if (collection.id == 'abubakr-salem' &&
        {'سر حبي', 'متى أنا أشوفك'}.contains(savedItem.title)) {
      return true;
    }
    return false;
  }

  int _nodeCount(
    LibraryTaxonomyNode node,
    List<LibraryItem> items,
    AsyncValue<List<UserFolder>> foldersAsync,
  ) {
    if (node.id == 'folders') {
      return foldersAsync.valueOrNull?.length ?? 0;
    }
    return items.where(node.matches).length;
  }

  Widget _buildFoldersView(AsyncValue<List<UserFolder>> foldersAsync) {
    return foldersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _LibraryError(message: error.toString()),
      data: (folders) {
        if (folders.isEmpty) {
          return _LibraryEmptyState(
            icon: Icons.create_new_folder_outlined,
            title: 'لا توجد مجلدات حالياً',
            subtitle: 'أنشئ مجلداً جديداً لحفظ ملفاتك المفضلة',
            actionLabel: 'إنشاء مجلد',
            onAction: _showCreateFolderDialog,
          );
        }

        final responsive = context.responsive;
        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: responsive.pagePadding.copyWith(top: 18, bottom: 120),
          itemCount: folders.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: responsive.columns(
              compact: 2,
              medium: 3,
              expanded: 4,
              large: 5,
            ),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.08,
          ),
          itemBuilder: (_, index) => _FolderCard(folder: folders[index]),
        );
      },
    );
  }

  Widget _buildItemsList(
    List<LibraryItem> items, {
    required String emptyTitle,
    required Color accentColor,
  }) {
    if (items.isEmpty) {
      return _LibraryEmptyState(
        icon: Icons.library_music_outlined,
        title: 'لا توجد ملفات في $emptyTitle',
        subtitle: 'ستظهر الملفات هنا بعد حفظها أو تحميلها',
      );
    }

    items.sort((first, second) => second.createdAt.compareTo(first.createdAt));
    return ListView.separated(
      padding: context.responsive.pagePadding.copyWith(top: 18, bottom: 120),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final item = items[index];
        return _LibraryItemCard(
          item: item,
          accentColor: accentColor,
          isSelected: _selectedItemIds.contains(item.id),
          onShare: () => _shareLibraryItem(item),
          onMove: () => _moveLibraryItem(item),
          onDelete: () => _deleteLibraryItem(item),
          onSelect: () => _toggleItemSelection(item.id),
          onPlay: () => _playLibraryItem(item),
        );
      },
    );
  }

  Future<void> _shareLibraryItem(LibraryItem item) async {
    final source = item.localPath.trim();
    final isRemoteSource =
        source.startsWith('http://') || source.startsWith('https://');
    await SharePlus.instance.share(
      source.isNotEmpty && !isRemoteSource
          ? ShareParams(text: item.title, files: [XFile(source)])
          : ShareParams(
              text: source.isEmpty
                  ? 'استمع إلى "${item.title}" على تطبيق ألوان.'
                  : 'استمع إلى "${item.title}" على تطبيق ألوان. $source',
            ),
    );
  }

  Future<void> _playLibraryItem(LibraryItem item) async {
    if (item.type == LibraryItemType.audiobook) {
      final audioUrl = item.audioUrl ?? item.localPath;
      if (audioUrl.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('رابط الكتاب الصوتي غير متوفر حالياً.')),
        );
        return;
      }
      await ref.read(audioControllerProvider).play(
        AudioTrack(
          id: item.sourceId,
          title: item.title,
          subtitle: 'الكتب الصوتية',
          url: audioUrl,
          imageUrl: item.coverUrl,
          coverUrl: item.coverUrl,
          category: 'الكتب الصوتية',
          sourceType: AudioSourceType.audiobook,
        ),
      );
      return;
    }

    if (item.type != LibraryItemType.podcast) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سيتم ربط تشغيل هذا النوع في مرحلته الخاصة'),
        ),
      );
      return;
    }

    final audioUrl = item.audioUrl ?? item.localPath;
    final videoUrl = item.videoUrl ?? '';
    final episode = PodcastEpisode(
      id: item.sourceId,
      title: item.title,
      description: 'حلقة محفوظة في مكتبتي',
      hostName: 'بودكاست ألوان',
      seriesName: 'بودكاست ألوان',
      audioUrl: audioUrl,
      videoUrl: videoUrl,
      videoQualityUrls: videoUrl.isEmpty
          ? const {}
          : {
              'تلقائي': videoUrl,
              '1080p HD': videoUrl,
              '720p HD': videoUrl,
              '480p SD': videoUrl,
            },
      imageAsset: item.coverUrl ?? 'assets/images/quick_access/podcast.jpg',
      duration: Duration.zero,
      publishedAt: item.createdAt,
      listeners: 0,
    );

    final choice = await showModalBottomSheet<_PodcastMediaChoice>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر طريقة تشغيل الحلقة',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (videoUrl.isNotEmpty)
                ListTile(
                  leading: const Icon(
                    Icons.ondemand_video_rounded,
                    color: Color(0xFFE64273),
                  ),
                  title: const Text('مشاهدة الفيديو'),
                  subtitle: const Text('جودة وسرعة وترجمة ووضع سينمائي'),
                  onTap: () =>
                      Navigator.pop(sheetContext, _PodcastMediaChoice.video),
                ),
              ListTile(
                leading: const Icon(
                  Icons.headphones_rounded,
                  color: Color(0xFF7131A1),
                ),
                title: const Text('الاستماع إلى MP3'),
                subtitle: const Text(
                  'تشغيل في الخلفية عبر منظومة ألوان الصوتية',
                ),
                onTap: () =>
                    Navigator.pop(sheetContext, _PodcastMediaChoice.audio),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == _PodcastMediaChoice.video) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              PodcastVideoPlayerScreen(episode: episode, playlist: [episode]),
        ),
      );
      return;
    }
    await ref.read(audioControllerProvider).play(episode.toAudioTrack());
  }

  Future<void> _moveLibraryItem(LibraryItem item) async {
    final repository = ref.read(libraryRepositoryProvider);
    final folders = (await repository.getFolders())
        .where((folder) => folder.type == FolderType.user)
        .toList();
    if (!mounted) return;
    if (folders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أنشئ مجلداً أولاً لنقل الملف إليه.')),
      );
      return;
    }

    final selectedFolder = await showModalBottomSheet<UserFolder>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * .65,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 14),
                child: Text(
                  'نقل الملف إلى',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: folders.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final folder = folders[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.folder_rounded,
                        color: Color(0xFFF59E0B),
                      ),
                      title: Text(folder.name),
                      trailing: const Icon(Icons.chevron_left_rounded),
                      onTap: () => Navigator.pop(sheetContext, folder),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selectedFolder == null || !mounted) return;

    if (item.folderId != null && item.folderId != selectedFolder.id) {
      await repository.moveItem(
        fromFolderId: item.folderId!,
        toFolderId: selectedFolder.id,
        itemId: item.id,
      );
    } else {
      await repository.addItemToFolder(
        folderId: selectedFolder.id,
        itemId: item.id,
      );
    }
    await repository.updateItem(item.copyWith(folderId: selectedFolder.id));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نقل "${item.title}" إلى "${selectedFolder.name}".'),
      ),
    );
  }

  Future<void> _deleteLibraryItem(LibraryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'حذف الملف',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text('هل تريد حذف "${item.title}" من مكتبتي؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final repository = ref.read(libraryRepositoryProvider);
    if (item.folderId != null) {
      await repository.removeItemFromFolder(
        folderId: item.folderId!,
        itemId: item.id,
      );
    }
    await repository.deleteItem(item.id);
    if (!mounted) return;
    setState(() => _selectedItemIds.remove(item.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حذف "${item.title}" من مكتبتي.')),
    );
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (!_selectedItemIds.add(itemId)) {
        _selectedItemIds.remove(itemId);
      }
    });
  }

  Future<void> _showCreateFolderDialog() async {
    final controller = TextEditingController();
    final folderName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'إنشاء مجلد جديد',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'اسم المجلد',
            prefixIcon: Icon(Icons.create_new_folder_rounded),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (folderName == null || folderName.isEmpty) return;

    await ref
        .read(libraryActionsProvider)
        .createFolder(name: folderName, type: FolderType.user);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('تم إنشاء المجلد "$folderName"')));
  }

  void _handleBack() {
    if (_selectedItemIds.isNotEmpty) {
      setState(() => _selectedItemIds.clear());
      return;
    }
    if (_navigationPath.isNotEmpty) {
      setState(() => _navigationPath.removeLast());
      return;
    }
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.homePath);
    }
  }

  void _showNotificationsMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('لا توجد إشعارات جديدة حالياً.')),
    );
  }
}

class _LibraryHeader extends StatelessWidget {
  const _LibraryHeader({
    required this.title,
    required this.onBack,
    required this.onNotifications,
    this.onCreateFolder,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback onNotifications;
  final VoidCallback? onCreateFolder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsive.pagePadding.copyWith(top: 10, bottom: 10),
      child: Row(
        children: [
          _HeaderButton(
            tooltip: 'العودة',
            icon: Icons.arrow_forward_ios_rounded,
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
          if (onCreateFolder != null)
            _HeaderButton(
              tooltip: 'إنشاء مجلد',
              icon: Icons.create_new_folder_rounded,
              onTap: onCreateFolder!,
            )
          else
            _HeaderButton(
              tooltip: 'الإشعارات',
              icon: Icons.notifications_none_rounded,
              onTap: onNotifications,
            ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
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
          child: Icon(icon, size: 21, color: const Color(0xFF25263D)),
        ),
      ),
    );
  }
}

class _LibraryBanner extends StatelessWidget {
  const _LibraryBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsive.pagePadding.copyWith(top: 4),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: AspectRatio(
            aspectRatio: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const AdaptiveContentImage(
                    source: 'assets/images/lounge/الموسيقى.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    semanticLabel: 'بنر مكتبتي الإعلاني',
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          const Color(0xFF3527C8).withValues(alpha: .94),
                          const Color(0xFF5B4CF0).withValues(alpha: .62),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مساحتك الصوتية الخاصة',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'كل ما تحفظه من ألوان في مكان واحد',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70, fontSize: 11),
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

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

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

class _LibraryCategoryCard extends StatelessWidget {
  const _LibraryCategoryCard({
    required this.node,
    required this.itemCount,
    required this.onTap,
  });

  final LibraryTaxonomyNode node;
  final int itemCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(node.colorValue);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.white, Color.lerp(Colors.white, color, .09)!],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .16),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_iconFor(node.iconKey), color: color, size: 23),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: color,
                    size: 16,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                node.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF25263D),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                node.id == 'recordings' && itemCount == 0
                    ? 'تسجيلاتك الصوتية'
                    : '$itemCount ملف',
                style: TextStyle(
                  color: color.withValues(alpha: .82),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryCollectionCard extends StatelessWidget {
  const _LibraryCollectionCard({
    required this.item,
    required this.itemCount,
    required this.onTap,
  });

  final LoungeCatalogItem item;
  final int itemCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(item.accentColorValue);
    final glassColor = Color.lerp(color, Colors.white, .18)!;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: .28),
                blurRadius: 17,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AdaptiveContentImage(
                        source: item.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        semanticLabel: item.displayTitle,
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              color.withValues(alpha: .24),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          margin: const EdgeInsets.all(7),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$itemCount',
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [glassColor, color],
                      ),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: .72),
                        ),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.displayTitle,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.responsive.value(
                          compact: 10,
                          medium: 12,
                        ),
                        fontWeight: FontWeight.w900,
                        height: 1.18,
                        shadows: const [
                          Shadow(color: Colors.black26, blurRadius: 5),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectionRoute {
  const _CollectionRoute({required this.nodeId, required this.item});

  final String nodeId;
  final LoungeCatalogItem item;

  static String encode(String nodeId, LoungeCatalogItem item) {
    return 'collection::$nodeId::${item.id}';
  }

  static _CollectionRoute? tryParse(String value) {
    final parts = value.split('::');
    if (parts.length != 3 || parts.first != 'collection') return null;
    final itemId = parts[2];
    for (final catalog in LoungeCatalogData.catalogs.values) {
      for (final item in catalog.items) {
        if (item.id == itemId) {
          return _CollectionRoute(nodeId: parts[1], item: item);
        }
      }
    }
    return null;
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({required this.folder});

  final UserFolder folder;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoutes.folderDetails,
          pathParameters: {'id': folder.id},
          extra: folder,
        ),
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: .14),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.folder_rounded,
                color: Color(0xFFF59E0B),
                size: 42,
              ),
              const Spacer(),
              Text(
                folder.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'مجلد مستخدم',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryItemCard extends StatelessWidget {
  const _LibraryItemCard({
    required this.item,
    required this.accentColor,
    required this.isSelected,
    required this.onShare,
    required this.onMove,
    required this.onDelete,
    required this.onSelect,
    required this.onPlay,
  });

  final LibraryItem item;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onShare;
  final VoidCallback onMove;
  final VoidCallback onDelete;
  final VoidCallback onSelect;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? accentColor.withValues(alpha: .08) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? accentColor : Colors.transparent,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: .08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.audio_file_rounded,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  item.type.name,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'تشغيل',
            onPressed: onPlay,
            icon: Icon(
              Icons.play_circle_fill_rounded,
              color: accentColor,
              size: 34,
            ),
          ),
          PopupMenuButton<_LibraryItemAction>(
            tooltip: 'المزيد',
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            onSelected: (action) {
              switch (action) {
                case _LibraryItemAction.share:
                  onShare();
                  break;
                case _LibraryItemAction.move:
                  onMove();
                  break;
                case _LibraryItemAction.delete:
                  onDelete();
                  break;
                case _LibraryItemAction.select:
                  onSelect();
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: _LibraryItemAction.share,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.share_rounded),
                  title: Text('مشاركة الملف'),
                ),
              ),
              const PopupMenuItem(
                value: _LibraryItemAction.move,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.drive_file_move_rounded),
                  title: Text('نقل الملف'),
                ),
              ),
              PopupMenuItem(
                value: _LibraryItemAction.select,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    isSelected
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                  ),
                  title: Text(isSelected ? 'إلغاء التحديد' : 'تحديد الملف'),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: _LibraryItemAction.delete,
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  title: Text('حذف الملف', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _LibraryItemAction { share, move, delete, select }

enum _PodcastMediaChoice { video, audio }

class _LibraryEmptyState extends StatelessWidget {
  const _LibraryEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 68, color: Colors.grey.shade300),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.create_new_folder_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LibraryError extends StatelessWidget {
  const _LibraryError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}

IconData _iconFor(String key) {
  return switch (key) {
    'mic' => Icons.mic_rounded,
    'folder' => Icons.folder_rounded,
    'headphones' => Icons.headphones_rounded,
    'music' => Icons.music_note_rounded,
    'lyrics' => Icons.lyrics_rounded,
    'groups' => Icons.groups_rounded,
    'poem' => Icons.edit_note_rounded,
    'mosque' => Icons.mosque_rounded,
    'piano' => Icons.piano_rounded,
    'radio' => Icons.radio_rounded,
    'documentary' => Icons.movie_filter_rounded,
    'book' => Icons.menu_book_rounded,
    'palette' => Icons.palette_rounded,
    'medical' => Icons.medical_services_rounded,
    'quran' => Icons.auto_stories_rounded,
    'audiobook' => Icons.library_books_rounded,
    'podcast' => Icons.podcasts_rounded,
    _ => Icons.audio_file_rounded,
  };
}
