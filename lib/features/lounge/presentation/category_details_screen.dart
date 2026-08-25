import 'dart:ui';

import 'package:flutter/material.dart' hide Text;
import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/widgets/adaptive_content_image.dart';
import 'package:alwan_hub/features/lounge/data/lounge_catalog_data.dart';
import 'package:alwan_hub/features/lounge/data/lounge_categories.dart';
import 'package:alwan_hub/features/lounge/domain/models/category_config.dart';
import 'package:alwan_hub/features/lounge/domain/models/lounge_catalog.dart';
import 'package:alwan_hub/features/lounge/presentation/artist_details_screen.dart';

class CategoryDetailsScreen extends StatefulWidget {
  const CategoryDetailsScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    final catalog = LoungeCatalogData.byCategoryId(widget.categoryId);
    if (catalog != null && catalog.groups.isNotEmpty) {
      _selectedGroupId = catalog.groups.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = _findCategory(widget.categoryId);
    final catalog = LoungeCatalogData.byCategoryId(widget.categoryId);
    if (category == null || catalog == null) {
      return const _MissingCategoryScreen();
    }

    final visibleItems = catalog.items
        .where(
          (item) =>
              item.isActive &&
              (_selectedGroupId == null || item.groupId == _selectedGroupId),
        )
        .toList()
      ..sort((first, second) => first.sortOrder.compareTo(second.sortOrder));
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _CategoryHeader(category: category),
          if (catalog.hasGroups)
            SliverToBoxAdapter(
              child: _GroupSelector(
                groups: catalog.groups,
                selectedId: _selectedGroupId,
                color: category.primaryColor,
                onSelected: (id) => setState(() => _selectedGroupId = id),
              ),
            ),
          SliverToBoxAdapter(
            child: _SectionTitle(
              title: catalog.sectionTitle,
              color: category.primaryColor,
            ),
          ),
          SliverPadding(
            padding: responsive.pagePadding.copyWith(top: 2, bottom: 0),
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
              delegate: SliverChildBuilderDelegate(
                (context, index) => _CatalogCard(
                  item: visibleItems[index],
                  onTap: () => _openItem(
                    context,
                    category,
                    catalog,
                    visibleItems[index],
                  ),
                ),
                childCount: visibleItems.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  CategoryConfig? _findCategory(String categoryId) {
    for (final category in LoungeCategoriesData.loungeCategories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  void _openItem(
    BuildContext context,
    CategoryConfig category,
    LoungeCategoryCatalog catalog,
    LoungeCatalogItem item,
  ) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ArtistDetailsScreen(
          artistId: item.id,
          artistName: item.displayTitle,
          artistImageUrl: item.imageUrl,
          primaryColor: Color(item.accentColorValue),
          categoryName: category.title,
          categoryId: category.id,
          trackItemLabel: catalog.trackItemLabel,
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category});

  final CategoryConfig category;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: context.responsive.value(
        compact: 200,
        medium: 230,
        expanded: 260,
      ),
      pinned: true,
      stretch: true,
      backgroundColor: category.primaryColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .88),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          category.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 21,
            shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            AdaptiveContentImage(
              source: category.bannerImage,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              semanticLabel: category.title,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: .08),
                    category.primaryColor.withValues(alpha: .9),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupSelector extends StatelessWidget {
  const _GroupSelector({
    required this.groups,
    required this.selectedId,
    required this.color,
    required this.onSelected,
  });

  final List<LoungeCatalogGroup> groups;
  final String? selectedId;
  final Color color;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsive.pagePadding.copyWith(top: 22, bottom: 4),
      child: Row(
        children: groups.map((group) {
          final selected = selectedId == group.id;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: InkWell(
                onTap: () => onSelected(group.id),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 66,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? LinearGradient(
                            colors: [
                              Color.lerp(color, Colors.white, .14)!,
                              color,
                            ],
                          )
                        : null,
                    color: selected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? Colors.white.withValues(alpha: .9)
                          : color.withValues(alpha: .18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: selected ? .22 : .07),
                        blurRadius: selected ? 14 : 8,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    group.title,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF30334A),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsive.pagePadding.copyWith(top: 22, bottom: 14),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 25,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.item, required this.onTap});

  final LoungeCatalogItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = Color(item.accentColorValue);
    final glassColor = Color.lerp(accentColor, Colors.white, .18)!;

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
                color: glassColor.withValues(alpha: .42),
                blurRadius: 18,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .72),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .92),
                    width: 1.4,
                  ),
                ),
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
                                  Colors.white.withValues(alpha: .1),
                                  Colors.transparent,
                                  accentColor.withValues(alpha: .2),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              glassColor.withValues(alpha: .9),
                              accentColor,
                            ],
                          ),
                          border: Border(
                            top: BorderSide(
                              color: Colors.white.withValues(alpha: .72),
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Center(
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
                                fontWeight: FontWeight.w800,
                                height: 1.18,
                                shadows: const [
                                  Shadow(color: Colors.black26, blurRadius: 5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingCategoryScreen extends StatelessWidget {
  const _MissingCategoryScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('تعذر العثور على بيانات هذا القسم.')),
    );
  }
}
