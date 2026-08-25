import '../domain/repositories/library_category_repository.dart';
import '../domain/entities/library_category.dart';

class LibraryInitializer {
  final LibraryCategoryRepository _categoryRepository;

  LibraryInitializer(this._categoryRepository);

  Future<void> initialize() async {
    await _initializeCategories();
  }

  Future<void> _initializeCategories() async {
    for (final category in _defaultCategories) {
      await _categoryRepository.saveCategory(category);
    }
  }

  Future<void> resetSystemCategories() async {
    final categories = await _categoryRepository.getCategories();

    for (final category in categories) {
      await _categoryRepository.deleteCategory(category.id);
    }

    await _initializeCategories();
  }

  List<LibraryCategory> get _defaultCategories => [
    const LibraryCategory(
      id: 'recordings',
      name: 'التسجيلات',
      order: 1,
      icon: 'mic',
      acceptsItems: false,
    ),
    const LibraryCategory(
      id: 'folders',
      name: 'مجلداتي',
      order: 2,
      icon: 'folder',
      allowsChildren: true,
      acceptsItems: false,
    ),
    const LibraryCategory(
      id: 'alwan_lounge',
      name: 'استراحة ألوان',
      order: 3,
      icon: 'coffee',
      allowsChildren: true,
      acceptsItems: false,
    ),
    const LibraryCategory(
      id: 'yemeni-songs',
      name: 'الأغاني اليمنية',
      parentId: 'alwan_lounge',
      order: 4,
      icon: 'music_note',
    ),
    const LibraryCategory(
      id: 'arabic-songs',
      name: 'الأغاني العربية',
      parentId: 'alwan_lounge',
      order: 5,
      icon: 'music_note',
    ),
    const LibraryCategory(
      id: 'poetry-and-sheelat',
      name: 'الشيلات والقصائد الشعرية',
      parentId: 'alwan_lounge',
      order: 6,
      icon: 'lyrics',
      allowsChildren: true,
      acceptsItems: false,
    ),
    const LibraryCategory(
      id: 'sheelat',
      name: 'الشيلات',
      parentId: 'poetry-and-sheelat',
      order: 7,
      icon: 'mic',
    ),
    const LibraryCategory(
      id: 'zawamil',
      name: 'الزوامل',
      parentId: 'poetry-and-sheelat',
      order: 8,
      icon: 'groups',
    ),
    const LibraryCategory(
      id: 'poems',
      name: 'القصائد الشعرية',
      parentId: 'poetry-and-sheelat',
      order: 9,
      icon: 'edit_note',
    ),
    const LibraryCategory(
      id: 'religious-nasheed',
      name: 'الأناشيد الدينية',
      parentId: 'alwan_lounge',
      order: 10,
      icon: 'mosque',
    ),
    const LibraryCategory(
      id: 'music',
      name: 'الموسيقى',
      parentId: 'alwan_lounge',
      order: 11,
      icon: 'piano',
    ),
    const LibraryCategory(
      id: 'lounge-programs',
      name: 'برامج الاستراحة',
      parentId: 'alwan_lounge',
      order: 12,
      icon: 'radio',
      allowsChildren: true,
      acceptsItems: false,
    ),
    const LibraryCategory(
      id: 'documentary-programs',
      name: 'مسلسلات إذاعية',
      parentId: 'lounge-programs',
      order: 13,
      icon: 'radio',
    ),
    const LibraryCategory(
      id: 'cultural-programs',
      name: 'البرامج الثقافية',
      parentId: 'lounge-programs',
      order: 14,
      icon: 'menu_book',
    ),
    const LibraryCategory(
      id: 'art-programs',
      name: 'البرامج الفنية',
      parentId: 'lounge-programs',
      order: 15,
      icon: 'palette',
    ),
    const LibraryCategory(
      id: 'medical-programs',
      name: 'البرامج الطبية',
      parentId: 'lounge-programs',
      order: 16,
      icon: 'medical_services',
    ),
    const LibraryCategory(
      id: 'religious-programs',
      name: 'البرامج الدينية',
      parentId: 'lounge-programs',
      order: 17,
      icon: 'mosque',
    ),
    const LibraryCategory(
      id: 'social-programs',
      name: 'البرامج الاجتماعية',
      parentId: 'lounge-programs',
      order: 18,
      icon: 'groups',
    ),
    const LibraryCategory(
      id: 'quran',
      name: 'القرآن الكريم',
      order: 19,
      icon: 'menu_book',
    ),
    const LibraryCategory(
      id: 'audio_books',
      name: 'الكتب الصوتية',
      order: 20,
      icon: 'library_books',
    ),
    const LibraryCategory(
      id: 'podcasts',
      name: 'بودكاست ألوان',
      order: 21,
      icon: 'podcasts',
    ),
  ];
}
