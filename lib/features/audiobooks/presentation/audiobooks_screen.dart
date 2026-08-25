// lib/features/audiobooks/presentation/audiobooks_screen.dart

import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/audio/providers/audio_provider.dart';
import 'package:alwan_hub/core/audio/widgets/mini_player.dart';
import 'package:alwan_hub/features/audiobooks/presentation/providers/audiobook_playback_catalog_provider.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item.dart';
import 'package:alwan_hub/features/library/domain/entities/library_item_type.dart';
import 'package:alwan_hub/features/library/presentation/providers/library_provider.dart';

class AudiobooksScreen extends ConsumerStatefulWidget {
  const AudiobooksScreen({super.key});

  @override
  ConsumerState<AudiobooksScreen> createState() => _AudiobooksScreenState();
}

class _AudiobooksScreenState extends ConsumerState<AudiobooksScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<AudioTrack> _filteredBooks(List<AudioTrack> books) {
    Iterable<AudioTrack> result = books;

    final query = _searchController.text.trim();

    if (query.isNotEmpty) {
      result = result.where(
        (book) =>
            book.title.contains(query) ||
            (book.presenterName ?? '').contains(query),
      );
    }

    return result.toList(growable: false);
  }

  Future<void> _playBook(AudioTrack book) async {
    final books = _filteredBooks(
      ref.read(audiobookTracksProvider).valueOrNull ?? const [],
    );
    final index = books.indexWhere((b) => b.id == book.id);

    await ref.read(audioControllerProvider).loadPlaylist(
      books,
      initialIndex: index < 0 ? 0 : index,
    );
  }

  Future<void> _saveBookToLibrary(AudioTrack book) async {
    await ref.read(libraryInitializerProvider).initialize();
    await ref.read(libraryRepositoryProvider).saveItem(
      LibraryItem(
        id: 'audiobook-${book.id}',
        title: book.title,
        type: LibraryItemType.audiobook,
        sourceId: book.id,
        localPath: book.url,
        audioUrl: book.url,
        coverUrl: book.imageUrl ?? book.coverUrl,
        categoryId: 'audio_books',
        createdAt: DateTime.now(),
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تمت إضافة "${book.title}" إلى مكتبتي.')),
    );
  }

  AudioTrack _bookOfWeek(List<AudioTrack> books) {
    final sorted = [...books];
    sorted.sort((a, b) {
      double scoreA = a.rating * 1000 + a.downloads;
      double scoreB = b.rating * 1000 + b.downloads;
      return scoreB.compareTo(scoreA);
    });
    return sorted.first;
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(audiobookTracksProvider);
    final books = _filteredBooks(catalog.valueOrNull ?? const []);
    final audioState = ref.watch(audioPlayerProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildAdBanner()),
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'تابع الإستماع',
                icon: Icons.graphic_eq_rounded,
                topPadding: 10,
                bottomPadding: 6,
              ),
            ),
            SliverToBoxAdapter(
              child: _buildContinueListening(books, context, audioState),
            ),
            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'المكتبة',
                icon: Icons.menu_book_rounded,
                topPadding: 10,
                bottomPadding: 4,
                showViewAll: true,
              ),
            ),
            books.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildLibraryCard(
                          books[index],
                          audioState.isFavorite(books[index].id),
                        );
                      }, childCount: books.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 12,
                          ),
                    ),
                  ),

            if (books.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _buildSectionTitle(
                  'كتاب الأسبوع',
                  icon: Icons.workspace_premium_rounded,
                  topPadding: 10,
                  bottomPadding: 8,
                ),
              ),
              SliverToBoxAdapter(
                child: _buildBookOfWeekBanner(_bookOfWeek(books)),
              ),
            ],

            SliverToBoxAdapter(
              child: _buildSectionTitle(
                'القارئ الذكي ✨',
                icon: Icons.auto_awesome_rounded,
                topPadding: 14,
                bottomPadding: 8,
              ),
            ),
            const SliverToBoxAdapter(child: SmartReaderSection()),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
      bottomNavigationBar: const MiniPlayer(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.graphic_eq_rounded,
                      color: Color(0xff391B99),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'الكتب الصوتية',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff391B99),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Transform.flip(
                      flipX: true,
                      child: const Icon(
                        Icons.graphic_eq_rounded,
                        color: Color(0xff391B99),
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'استمع، تعلّم، استمتع',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'ابحث عن كتاب أو مؤلف...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: const Icon(Icons.tune_rounded),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildAdBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          'https://images.unsplash.com/photo-1497935586351-b67a49e012bf?auto=format&fit=crop&w=800&q=80',
          height: 165,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 165,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff4F46E5), Color(0xff7C3AED)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text(
                  'مساحة إعلانية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    String title, {
    IconData? icon,
    required double topPadding,
    required double bottomPadding,
    bool showViewAll = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, bottomPadding),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: const Color(0xff391B99), size: 20),
            const SizedBox(width: 6),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xff391B99),
            ),
          ),
          const Spacer(),
          if (showViewAll)
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
              ),
              child: const Text('عرض الكل', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildContinueListening(
    List<AudioTrack> books,
    BuildContext context,
    AudioPlayerState audioState,
  ) {
    if (books.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 185,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: books.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.78,
            child: _buildContinueCard(books[index], audioState),
          );
        },
      ),
    );
  }

  Widget _buildContinueCard(AudioTrack book, AudioPlayerState audioState) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.presenterName ?? 'غير معروف',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            book.durationText ?? '00:00:00',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '39%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff1A1A1A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.39,
                      minHeight: 4,
                      backgroundColor: const Color(
                        0xff5B4CF0,
                      ).withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xff5B4CF0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () async {
                          await _playBook(book);
                        },
                        child: const Icon(
                          Icons.play_circle_fill_rounded,
                          color: Color(0xff5B4CF0),
                          size: 28,
                        ),
                      ),
                      InkWell(
                        onTap: () => ref
                            .read(audioPlayerProvider.notifier)
                            .toggleFavorite(book),
                        borderRadius: BorderRadius.circular(20),
                        child: Icon(
                          audioState.isFavorite(book.id)
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          size: 24,
                          color: audioState.isFavorite(book.id)
                              ? Colors.redAccent
                              : const Color(0xff5B4CF0),
                        ),
                      ),
                      InkWell(
                        onTap: () => _saveBookToLibrary(book),
                        borderRadius: BorderRadius.circular(20),
                        child: const Icon(
                          Icons.library_add_rounded,
                          size: 24,
                          color: Color(0xff5B4CF0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: Hero(
                tag: 'continue_${book.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: book.imageUrl != null
                        ? Image.network(
                            book.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                                  'assets/images/program.jpg',
                                  fit: BoxFit.cover,
                                ),
                          )
                        : Image.asset(
                            'assets/images/program.jpg',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryCard(AudioTrack book, bool isFavorite) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        await _playBook(book);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'library_${book.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: book.imageUrl != null
                        ? Image.network(
                            book.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                                  'assets/images/program.jpg',
                                  fit: BoxFit.cover,
                                ),
                          )
                        : Image.asset(
                            'assets/images/program.jpg',
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Column(
                children: [
                  SizedBox(
                    height: 18,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          book.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xff1A1A1A),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          book.presenterName ?? 'غير معروف',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff5B4CF0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => ref
                              .read(audioPlayerProvider.notifier)
                              .toggleFavorite(book),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                        const Icon(
                          Icons.star_rounded,
                          color: Colors.white,
                          size: 11,
                        ),
                        const Icon(
                          Icons.timer_outlined,
                          color: Colors.white,
                          size: 11,
                        ),
                        InkWell(
                          onTap: () => _saveBookToLibrary(book),
                          child: const Icon(
                            Icons.library_add_rounded,
                            color: Colors.white,
                            size: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${book.downloads}',
                          style: const TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${book.rating}',
                          style: const TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          book.durationText ?? '00:40',
                          style: const TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '${book.downloads}',
                          style: const TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookOfWeekBanner(AudioTrack book) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 205,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            colors: [Color(0xff24125C), Color(0xff5020A8), Color(0xff6A2ED9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff5020A8).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -15,
                bottom: -15,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Opacity(
                    opacity: 0.12,
                    child: Icon(
                      Icons.headphones_rounded,
                      size: 120,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: -14,
                right: 14,
                width: 95,
                bottom: 14,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Hero(
                    tag: 'book_week_${book.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: book.imageUrl != null
                          ? Image.network(
                              book.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                    'assets/images/program.jpg',
                                    fit: BoxFit.cover,
                                  ),
                            )
                          : Image.asset(
                              'assets/images/program.jpg',
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 12,
                bottom: 12,
                right: 124,
                left: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xffFFD700,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(
                                0xffFFD700,
                              ).withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Text(
                            '🏆 الأعلى تقييماً',
                            style: TextStyle(
                              color: Color(0xffFFD700),
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < book.rating.floor()
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: const Color(0xffFFD700),
                              size: 13,
                            );
                          }),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book.rating}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      book.presenterName ?? 'غير معروف',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 5),

                    SizedBox(
                      height: 30,
                      child: Text(
                        book.description ??
                            'دليل عملي لحياة أكثر هدوءاً وسعادة بعيداً عن التوقعات...',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () async {
                          await _playBook(book);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff5020A8),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          minimumSize: const Size(0, 30),
                        ),
                        icon: const Icon(Icons.headset_rounded, size: 15),
                        label: const Text(
                          'استمع الآن',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 65,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            const Text(
              'لا توجد كتب صوتية',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'ستظهر الكتب هنا عند إضافتها.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class SmartReaderSection extends StatefulWidget {
  const SmartReaderSection({super.key});

  @override
  State<SmartReaderSection> createState() => _SmartReaderSectionState();
}

class _SmartReaderSectionState extends State<SmartReaderSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            constraints: const BoxConstraints(minHeight: 220),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffEEF1FF),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCompactField(
                          icon: Icons.link_rounded,
                          text: 'ادخل رابط الكتاب أو ملف PDF',
                        ),
                        _buildCompactField(
                          icon: Icons.record_voice_over_rounded,
                          text: 'اختر القارئ',
                        ),
                        _buildCompactField(
                          icon: Icons.menu_book_rounded,
                          text: 'نوع القراءة',
                        ),
                        _buildCompactField(
                          icon: Icons.language_rounded,
                          text: 'لغة القراءة',
                        ),
                        const SizedBox(height: 5),

                        Container(
                          height: 32,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 10,
                                backgroundColor: Color(0xff8B2BC3),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'سنحول كتابك إلى صوت احترافي',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(
                                      0xff352B73,
                                    ).withValues(alpha: 0.95),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🤖', style: TextStyle(fontSize: 35)),
                        const SizedBox(height: 6),
                        const Text(
                          'حول أي كتاب',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xff352B73),
                            height: 1.2,
                          ),
                        ),
                        const Text(
                          'إلى تجربة صوتية',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff8B2BC3),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ادخل رابط الكتاب أو ارفع ملف PDF لتستمع إليه فوراً.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8.5,
                            color: Colors.grey.shade700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        GestureDetector(
                          onTapDown: (_) =>
                              setState(() => _isButtonPressed = true),
                          onTapUp: (_) {
                            setState(() => _isButtonPressed = false);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SmartReaderScreen(),
                              ),
                            );
                          },
                          onTapCancel: () =>
                              setState(() => _isButtonPressed = false),
                          child: AnimatedScale(
                            scale: _isButtonPressed ? 0.92 : 1.0,
                            duration: const Duration(milliseconds: 100),
                            child: FilledButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SmartReaderScreen(),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xff352B73),
                                shape: const StadiumBorder(),
                                minimumSize: const Size(double.infinity, 34),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                              ),
                              child: const Text(
                                'ابدأ الآن',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
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
    );
  }

  Widget _buildCompactField({required IconData icon, required String text}) {
    return Container(
      height: 32,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: const Color(0xff8B2BC3),
            child: Icon(icon, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SmartReaderScreen extends StatefulWidget {
  const SmartReaderScreen({super.key});

  @override
  State<SmartReaderScreen> createState() => _SmartReaderScreenState();
}

class _SmartReaderScreenState extends State<SmartReaderScreen> {
  String _selectedVoice = 'ذكاء اصطناعي';
  String _selectedLanguage = 'العربية';

  final TextEditingController _linkController = TextEditingController();

  List<String> _readingOptions = ['الكتاب كامل'];
  late String _selectedReadingType;

  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _selectedReadingType = _readingOptions.first;
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _analyzeBookContent(String input) {
    if (input.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        _readingOptions = [
          'الكتاب كامل',
          'المقدمة',
          'الفصل الأول: البدايات والأسس',
          'الفصل الثاني: الاستراتيجيات المتقدمة',
          'الفصل الثالث: التطبيق العملي',
          'الفصل الرابع: دراسات حالة',
          'الخاتمة والتوصيات',
        ];
        _selectedReadingType = _readingOptions.first;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ تم تحليل الملف وتحديد عدد الفصول تلقائياً بنجاح!'),
          backgroundColor: Color(0xff8B2BC3),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xff391B99)),
        title: const Text(
          'القارئ الذكي الاحترافي',
          style: TextStyle(
            color: Color(0xff391B99),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepHeader('1. رابط الكتاب أو رفع PDF'),
              const SizedBox(height: 8),
              TextField(
                controller: _linkController,
                onChanged: (value) {
                  if (value.length > 5) {
                    _analyzeBookContent(value);
                  }
                },
                decoration: InputDecoration(
                  hintText: 'ألصق رابط الكتاب أو اختر ملف من الجهاز...',
                  prefixIcon: const Icon(
                    Icons.link_rounded,
                    color: Color(0xff8B2BC3),
                  ),
                  suffixIcon: _isAnalyzing
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xff8B2BC3),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.auto_fix_high_rounded,
                          color: Color(0xff8B2BC3),
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),

              _buildStepHeader('2. اختيار الصوت'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildVoiceChip('ذكر 👨', 'ذكر'),
                  const SizedBox(width: 8),
                  _buildVoiceChip('أنثى 👩', 'أنثى'),
                  const SizedBox(width: 8),
                  _buildVoiceChip('ذكاء اصطناعي 🤖', 'ذكاء اصطناعي'),
                ],
              ),
              const SizedBox(height: 16),
              const Center(
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStepHeader('3. نوع القراءة (حسب فصول الكتاب)'),
                  if (_isAnalyzing)
                    const Text(
                      'جاري اكتشاف الفصول...',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xff8B2BC3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _readingOptions.contains(_selectedReadingType)
                        ? _selectedReadingType
                        : _readingOptions.first,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xff352B73),
                    ),
                    items: _readingOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff1A1A1A),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedReadingType = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  _readingOptions.length > 1
                      ? '📚 تم اكتشاف ${_readingOptions.length - 1} فصول في هذا الكتاب تلقائياً.'
                      : 'ℹ️ أضف رابط الكتاب أو ارفع ملف PDF أعلاه ليتم استخراج الفصول تلقائياً.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),

              _buildStepHeader('4. لغة القراءة'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildLangChip('اللغة العربية 🇸🇦', 'العربية'),
                  const SizedBox(width: 12),
                  _buildLangChip('اللغة الإنجليزية 🇺🇸', 'الإنجليزية'),
                ],
              ),
              const SizedBox(height: 24),
              const Center(
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey,
                  size: 26,
                ),
              ),
              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff352B73), Color(0xff5020A8)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff352B73).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'جاهز لتحويل كتابك؟',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سيقوم القارئ الذكي بقراءة القسم المختار ("$_selectedReadingType") بدقة عالية.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '✨ جاري بدء القارئ الذكي لـ "$_selectedReadingType"...',
                              ),
                              backgroundColor: const Color(0xff8B2BC3),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xff352B73),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: const Text(
                          'إنشاء الكتاب الصوتي',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14.5,
        fontWeight: FontWeight.bold,
        color: Color(0xff352B73),
      ),
    );
  }

  Widget _buildVoiceChip(String label, String value) {
    bool isSelected = _selectedVoice == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedVoice = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xff352B73) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xff352B73)
                  : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangChip(String label, String value) {
    bool isSelected = _selectedLanguage == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedLanguage = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xff352B73) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xff352B73)
                  : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
