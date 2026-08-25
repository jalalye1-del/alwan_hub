import 'library_item.dart';
import 'library_item_type.dart';

class LibraryTaxonomyNode {
  const LibraryTaxonomyNode({
    required this.id,
    required this.title,
    required this.iconKey,
    required this.colorValue,
    required this.order,
    this.parentId,
    this.categoryIds = const {},
    this.sourceIdPrefixes = const {},
    this.itemTypes = const {},
    this.alwaysVisible = false,
  });

  final String id;
  final String title;
  final String iconKey;
  final int colorValue;
  final int order;
  final String? parentId;
  final Set<String> categoryIds;
  final Set<String> sourceIdPrefixes;
  final Set<LibraryItemType> itemTypes;
  final bool alwaysVisible;

  bool matches(LibraryItem item) {
    final categoryMatches = categoryIds.contains(item.categoryId);
    final sourceMatches = sourceIdPrefixes.any(item.sourceId.startsWith);
    final typeMatches = itemTypes.contains(item.type);
    return categoryMatches || sourceMatches || typeMatches;
  }
}

class LibraryTaxonomy {
  const LibraryTaxonomy._();

  static const loungeCategoryIds = {
    'yemeni-songs',
    'arabic-songs',
    'poetry-and-sheelat',
    'religious-nasheed',
    'music',
    'documentary-programs',
    'cultural-programs',
    'art-programs',
    'medical-programs',
    'religious-programs',
    'social-programs',
    'alwan_lounge',
  };

  static const programCategoryIds = {
    'documentary-programs',
    'cultural-programs',
    'art-programs',
    'medical-programs',
    'religious-programs',
    'social-programs',
  };

  static const nodes = <LibraryTaxonomyNode>[
    LibraryTaxonomyNode(
      id: 'recordings',
      title: 'التسجيلات',
      iconKey: 'mic',
      colorValue: 0xFFE53955,
      order: 1,
      alwaysVisible: true,
    ),
    LibraryTaxonomyNode(
      id: 'folders',
      title: 'مجلداتي',
      iconKey: 'folder',
      colorValue: 0xFFF59E0B,
      order: 2,
      alwaysVisible: true,
    ),
    LibraryTaxonomyNode(
      id: 'alwan_lounge',
      title: 'استراحة ألوان',
      iconKey: 'headphones',
      colorValue: 0xFF5B4CF0,
      order: 3,
      categoryIds: loungeCategoryIds,
    ),
    LibraryTaxonomyNode(
      id: 'yemeni-songs',
      title: 'الأغاني اليمنية',
      iconKey: 'music',
      colorValue: 0xFFD32F2F,
      order: 1,
      parentId: 'alwan_lounge',
      categoryIds: {'yemeni-songs', 'alwan_lounge'},
    ),
    LibraryTaxonomyNode(
      id: 'arabic-songs',
      title: 'الأغاني العربية',
      iconKey: 'music',
      colorValue: 0xFF1976D2,
      order: 2,
      parentId: 'alwan_lounge',
      categoryIds: {'arabic-songs'},
    ),
    LibraryTaxonomyNode(
      id: 'poetry-and-sheelat',
      title: 'الشيلات والقصائد الشعرية',
      iconKey: 'lyrics',
      colorValue: 0xFFE64A19,
      order: 3,
      parentId: 'alwan_lounge',
      categoryIds: {'poetry-and-sheelat'},
    ),
    LibraryTaxonomyNode(
      id: 'sheelat',
      title: 'الشيلات',
      iconKey: 'mic',
      colorValue: 0xFFE64A19,
      order: 1,
      parentId: 'poetry-and-sheelat',
      sourceIdPrefixes: {'sheelat-'},
    ),
    LibraryTaxonomyNode(
      id: 'zawamil',
      title: 'الزوامل',
      iconKey: 'groups',
      colorValue: 0xFF8D6E63,
      order: 2,
      parentId: 'poetry-and-sheelat',
      sourceIdPrefixes: {'zamil-'},
    ),
    LibraryTaxonomyNode(
      id: 'poems',
      title: 'القصائد الشعرية',
      iconKey: 'poem',
      colorValue: 0xFF546E7A,
      order: 3,
      parentId: 'poetry-and-sheelat',
      sourceIdPrefixes: {'poet-'},
    ),
    LibraryTaxonomyNode(
      id: 'religious-nasheed',
      title: 'الأناشيد الدينية',
      iconKey: 'mosque',
      colorValue: 0xFF388E3C,
      order: 4,
      parentId: 'alwan_lounge',
      categoryIds: {'religious-nasheed'},
    ),
    LibraryTaxonomyNode(
      id: 'music',
      title: 'الموسيقى',
      iconKey: 'piano',
      colorValue: 0xFF8E24AA,
      order: 5,
      parentId: 'alwan_lounge',
      categoryIds: {'music'},
    ),
    LibraryTaxonomyNode(
      id: 'lounge-programs',
      title: 'برامج الاستراحة',
      iconKey: 'radio',
      colorValue: 0xFF455A64,
      order: 6,
      parentId: 'alwan_lounge',
      categoryIds: programCategoryIds,
    ),
    LibraryTaxonomyNode(
      id: 'documentary-programs',
      title: 'مسلسلات إذاعية',
      iconKey: 'radio',
      colorValue: 0xFF455A64,
      order: 1,
      parentId: 'lounge-programs',
      categoryIds: {'documentary-programs'},
    ),
    LibraryTaxonomyNode(
      id: 'cultural-programs',
      title: 'البرامج الثقافية',
      iconKey: 'book',
      colorValue: 0xFF795548,
      order: 2,
      parentId: 'lounge-programs',
      categoryIds: {'cultural-programs'},
    ),
    LibraryTaxonomyNode(
      id: 'art-programs',
      title: 'البرامج الفنية',
      iconKey: 'palette',
      colorValue: 0xFFC2185B,
      order: 3,
      parentId: 'lounge-programs',
      categoryIds: {'art-programs'},
    ),
    LibraryTaxonomyNode(
      id: 'medical-programs',
      title: 'البرامج الطبية',
      iconKey: 'medical',
      colorValue: 0xFF0288D1,
      order: 4,
      parentId: 'lounge-programs',
      categoryIds: {'medical-programs'},
    ),
    LibraryTaxonomyNode(
      id: 'religious-programs',
      title: 'البرامج الدينية',
      iconKey: 'mosque',
      colorValue: 0xFF00897B,
      order: 5,
      parentId: 'lounge-programs',
      categoryIds: {'religious-programs'},
    ),
    LibraryTaxonomyNode(
      id: 'social-programs',
      title: 'البرامج الاجتماعية',
      iconKey: 'groups',
      colorValue: 0xFFF57C00,
      order: 6,
      parentId: 'lounge-programs',
      categoryIds: {'social-programs'},
    ),
    LibraryTaxonomyNode(
      id: 'quran',
      title: 'القرآن الكريم',
      iconKey: 'quran',
      colorValue: 0xFF00796B,
      order: 4,
      categoryIds: {'quran', 'holy-quran'},
    ),
    LibraryTaxonomyNode(
      id: 'audio_books',
      title: 'الكتب الصوتية',
      iconKey: 'audiobook',
      colorValue: 0xFF7C3AED,
      order: 5,
      categoryIds: {'audio_books'},
      itemTypes: {LibraryItemType.audiobook},
    ),
    LibraryTaxonomyNode(
      id: 'podcasts',
      title: 'بودكاست ألوان',
      iconKey: 'podcast',
      colorValue: 0xFFDB2777,
      order: 6,
      categoryIds: {'podcasts'},
      itemTypes: {LibraryItemType.podcast},
    ),
  ];

  static List<LibraryTaxonomyNode> childrenOf(String? parentId) {
    final children = nodes.where((node) => node.parentId == parentId).toList();
    children.sort((first, second) => first.order.compareTo(second.order));
    return children;
  }

  static LibraryTaxonomyNode? byId(String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
    }
    return null;
  }
}
