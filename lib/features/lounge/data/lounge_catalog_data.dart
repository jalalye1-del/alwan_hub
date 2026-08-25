import 'package:alwan_hub/features/lounge/domain/models/lounge_catalog.dart';

class LoungeCatalogData {
  const LoungeCatalogData._();

  static const _concertImage =
      'https://images.pexels.com/photos/1763075/pexels-photo-1763075.jpeg?auto=compress&cs=tinysrgb&w=800';
  static const _microphoneImage =
      'https://images.pexels.com/photos/164829/pexels-photo-164829.jpeg?auto=compress&cs=tinysrgb&w=800';
  static const _booksImage =
      'https://images.pexels.com/photos/159711/books-bookstore-book-reading-159711.jpeg?auto=compress&cs=tinysrgb&w=800';
  static const _quranImage =
      'https://images.pexels.com/photos/8164380/pexels-photo-8164380.jpeg?auto=compress&cs=tinysrgb&w=800';
  static const _studioImage =
      'https://images.pexels.com/photos/164936/pexels-photo-164936.jpeg?auto=compress&cs=tinysrgb&w=800';
  static const _medicalImage =
      'https://images.pexels.com/photos/40568/medical-appointment-doctor-healthcare-40568.jpeg?auto=compress&cs=tinysrgb&w=800';
  static const _socialImage =
      'https://images.pexels.com/photos/3184180/pexels-photo-3184180.jpeg?auto=compress&cs=tinysrgb&w=800';

  static const Map<String, LoungeCategoryCatalog> catalogs = {
    'yemeni-songs': LoungeCategoryCatalog(
      categoryId: 'yemeni-songs',
      sectionTitle: 'الفنانون',
      trackItemLabel: 'أغنية',
      items: [
        LoungeCatalogItem(id: 'ayoub-tarish', name: 'أيوب طارش', roleLabel: 'الفنان', imageUrl: _concertImage, accentColorValue: 0xFF2EAD69, sortOrder: 1),
        LoungeCatalogItem(id: 'abubakr-salem', name: 'أبو بكر سالم', roleLabel: 'الفنان', imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=700&q=85', accentColorValue: 0xFFD83B52, sortOrder: 2),
        LoungeCatalogItem(id: 'ahmed-fathi', name: 'أحمد فتحي', roleLabel: 'الفنان', imageUrl: _studioImage, accentColorValue: 0xFF2878D4, sortOrder: 3),
        LoungeCatalogItem(id: 'fouad-abdelwahed', name: 'فؤاد عبدالواحد', roleLabel: 'الفنان', imageUrl: _microphoneImage, accentColorValue: 0xFFF09A22, sortOrder: 4),
      ],
    ),
    'arabic-songs': LoungeCategoryCatalog(
      categoryId: 'arabic-songs',
      sectionTitle: 'الفنانون',
      trackItemLabel: 'أغنية',
      items: [
        LoungeCatalogItem(id: 'arabic-artist-1', name: 'محمد عبده', roleLabel: 'الفنان', imageUrl: _concertImage, accentColorValue: 0xFF1976D2, sortOrder: 1),
        LoungeCatalogItem(id: 'arabic-artist-2', name: 'كاظم الساهر', roleLabel: 'الفنان', imageUrl: _microphoneImage, accentColorValue: 0xFF5C6BC0, sortOrder: 2),
        LoungeCatalogItem(id: 'arabic-artist-3', name: 'ماجدة الرومي', roleLabel: 'الفنانة', imageUrl: _studioImage, accentColorValue: 0xFFEC407A, sortOrder: 3),
      ],
    ),
    'poetry-and-sheelat': LoungeCategoryCatalog(
      categoryId: 'poetry-and-sheelat',
      sectionTitle: 'الأصوات والشعراء',
      trackItemLabel: 'ملف',
      groups: [
        LoungeCatalogGroup(id: 'sheelat', title: 'الشيلات'),
        LoungeCatalogGroup(id: 'zawamil', title: 'الزوامل'),
        LoungeCatalogGroup(id: 'poems', title: 'القصائد الشعرية'),
      ],
      items: [
        LoungeCatalogItem(id: 'sheelat-1', name: 'فهد بن فصلا', roleLabel: 'منشد الشيلة', imageUrl: _microphoneImage, accentColorValue: 0xFFE64A19, groupId: 'sheelat', sortOrder: 1),
        LoungeCatalogItem(id: 'sheelat-2', name: 'عبدالله آل مخلص', roleLabel: 'منشد الشيلة', imageUrl: _concertImage, accentColorValue: 0xFFF57C00, groupId: 'sheelat', sortOrder: 2),
        LoungeCatalogItem(id: 'zamil-1', name: 'الصوت الأول', roleLabel: 'منشد الزامل', imageUrl: _studioImage, accentColorValue: 0xFF8D6E63, groupId: 'zawamil', sortOrder: 3),
        LoungeCatalogItem(id: 'zamil-2', name: 'الصوت الثاني', roleLabel: 'منشد الزامل', imageUrl: _microphoneImage, accentColorValue: 0xFF6D4C41, groupId: 'zawamil', sortOrder: 4),
        LoungeCatalogItem(id: 'poet-1', name: 'عبدالله البردوني', roleLabel: 'الشاعر/', imageUrl: _booksImage, accentColorValue: 0xFF546E7A, groupId: 'poems', sortOrder: 5),
        LoungeCatalogItem(id: 'poet-2', name: 'عبدالعزيز المقالح', roleLabel: 'الشاعر/', imageUrl: _booksImage, accentColorValue: 0xFF455A64, groupId: 'poems', sortOrder: 6),
      ],
    ),
    'religious-nasheed': LoungeCategoryCatalog(
      categoryId: 'religious-nasheed',
      sectionTitle: 'المنشدون',
      trackItemLabel: 'أنشودة',
      items: [
        LoungeCatalogItem(id: 'nasheed-1', name: 'مشاري العفاسي', roleLabel: 'المنشد', imageUrl: _quranImage, accentColorValue: 0xFF388E3C, sortOrder: 1),
        LoungeCatalogItem(id: 'nasheed-2', name: 'ماهر زين', roleLabel: 'المنشد', imageUrl: _concertImage, accentColorValue: 0xFF43A047, sortOrder: 2),
        LoungeCatalogItem(id: 'nasheed-3', name: 'سامي يوسف', roleLabel: 'المنشد', imageUrl: _studioImage, accentColorValue: 0xFF00897B, sortOrder: 3),
      ],
    ),
    'holy-quran': LoungeCategoryCatalog(
      categoryId: 'holy-quran',
      sectionTitle: 'القراء',
      trackItemLabel: 'تلاوة',
      items: [
        LoungeCatalogItem(id: 'qari-1', name: 'عبدالباسط عبدالصمد', roleLabel: 'القارئ', imageUrl: _quranImage, accentColorValue: 0xFF00796B, sortOrder: 1),
        LoungeCatalogItem(id: 'qari-2', name: 'محمود خليل الحصري', roleLabel: 'القارئ', imageUrl: _quranImage, accentColorValue: 0xFF00897B, sortOrder: 2),
        LoungeCatalogItem(id: 'qari-3', name: 'ماهر المعيقلي', roleLabel: 'القارئ', imageUrl: _quranImage, accentColorValue: 0xFF26A69A, sortOrder: 3),
      ],
    ),
    'music': LoungeCategoryCatalog(
      categoryId: 'music',
      sectionTitle: 'التصنيفات الموسيقية',
      trackItemLabel: 'مقطوعة',
      items: [
        LoungeCatalogItem(id: 'music-calm', name: 'الموسيقى الهادئة', roleLabel: '', imageUrl: _studioImage, accentColorValue: 0xFF8E24AA, sortOrder: 1),
        LoungeCatalogItem(id: 'music-classic', name: 'الموسيقى الكلاسيكية', roleLabel: '', imageUrl: _concertImage, accentColorValue: 0xFF7B1FA2, sortOrder: 2),
        LoungeCatalogItem(id: 'music-score', name: 'الموسيقى التصويرية', roleLabel: '', imageUrl: _microphoneImage, accentColorValue: 0xFFAB47BC, sortOrder: 3),
      ],
    ),
    'documentary-programs': LoungeCategoryCatalog(
      categoryId: 'documentary-programs',
      sectionTitle: 'المسلسلات الإذاعية',
      trackItemLabel: 'حلقة',
      groups: [
        LoungeCatalogGroup(id: 'arabic-radio-series', title: 'المسلسلات العربية'),
        LoungeCatalogGroup(id: 'yemeni-radio-series', title: 'المسلسلات اليمنية'),
      ],
      items: [
        LoungeCatalogItem(id: 'arabic-radio-series-1', name: 'أيام لا تُنسى', roleLabel: 'مسلسل إذاعي', imageUrl: _microphoneImage, accentColorValue: 0xFF455A64, groupId: 'arabic-radio-series', sortOrder: 1),
        LoungeCatalogItem(id: 'arabic-radio-series-2', name: 'حكايات من الزمن الجميل', roleLabel: 'مسلسل إذاعي', imageUrl: _studioImage, accentColorValue: 0xFF607D8B, groupId: 'arabic-radio-series', sortOrder: 2),
        LoungeCatalogItem(id: 'arabic-radio-series-3', name: 'رحلة إلى المجهول', roleLabel: 'مسلسل إذاعي', imageUrl: _microphoneImage, accentColorValue: 0xFF546E7A, groupId: 'arabic-radio-series', sortOrder: 3),
        LoungeCatalogItem(id: 'yemeni-radio-series-1', name: 'حكايات صنعاء', roleLabel: 'مسلسل إذاعي', imageUrl: _studioImage, accentColorValue: 0xFF37474F, groupId: 'yemeni-radio-series', sortOrder: 1),
        LoungeCatalogItem(id: 'yemeni-radio-series-2', name: 'ليالي عدن', roleLabel: 'مسلسل إذاعي', imageUrl: _microphoneImage, accentColorValue: 0xFF546E7A, groupId: 'yemeni-radio-series', sortOrder: 2),
        LoungeCatalogItem(id: 'yemeni-radio-series-3', name: 'دروب اليمن', roleLabel: 'مسلسل إذاعي', imageUrl: _studioImage, accentColorValue: 0xFF607D8B, groupId: 'yemeni-radio-series', sortOrder: 3),
      ],
    ),
    'cultural-programs': LoungeCategoryCatalog(categoryId: 'cultural-programs', sectionTitle: 'البرامج', trackItemLabel: 'حلقة', items: [
      LoungeCatalogItem(id: 'cultural-1', name: 'كتاب وحكاية', roleLabel: 'برنامج', imageUrl: _booksImage, accentColorValue: 0xFF795548, sortOrder: 1),
      LoungeCatalogItem(id: 'cultural-2', name: 'نوافذ ثقافية', roleLabel: 'برنامج', imageUrl: _booksImage, accentColorValue: 0xFF8D6E63, sortOrder: 2),
      LoungeCatalogItem(id: 'cultural-3', name: 'لغة وفكر', roleLabel: 'برنامج', imageUrl: _studioImage, accentColorValue: 0xFFA1887F, sortOrder: 3),
    ]),
    'art-programs': LoungeCategoryCatalog(categoryId: 'art-programs', sectionTitle: 'البرامج', trackItemLabel: 'حلقة', items: [
      LoungeCatalogItem(id: 'art-1', name: 'ألوان فنية', roleLabel: 'برنامج', imageUrl: _studioImage, accentColorValue: 0xFFC2185B, sortOrder: 1),
      LoungeCatalogItem(id: 'art-2', name: 'ليالي الفن', roleLabel: 'برنامج', imageUrl: _concertImage, accentColorValue: 0xFFD81B60, sortOrder: 2),
      LoungeCatalogItem(id: 'art-3', name: 'خلف الكواليس', roleLabel: 'برنامج', imageUrl: _microphoneImage, accentColorValue: 0xFFEC407A, sortOrder: 3),
    ]),
    'medical-programs': LoungeCategoryCatalog(categoryId: 'medical-programs', sectionTitle: 'البرامج', trackItemLabel: 'حلقة', items: [
      LoungeCatalogItem(id: 'medical-1', name: 'صحتك أولاً', roleLabel: 'برنامج', imageUrl: _medicalImage, accentColorValue: 0xFF0288D1, sortOrder: 1),
      LoungeCatalogItem(id: 'medical-2', name: 'دقيقة طبية', roleLabel: 'برنامج', imageUrl: _medicalImage, accentColorValue: 0xFF039BE5, sortOrder: 2),
      LoungeCatalogItem(id: 'medical-3', name: 'اسأل الطبيب', roleLabel: 'برنامج', imageUrl: _medicalImage, accentColorValue: 0xFF29B6F6, sortOrder: 3),
    ]),
    'social-programs': LoungeCategoryCatalog(categoryId: 'social-programs', sectionTitle: 'البرامج', trackItemLabel: 'حلقة', items: [
      LoungeCatalogItem(id: 'social-1', name: 'حديث المجتمع', roleLabel: 'برنامج', imageUrl: _socialImage, accentColorValue: 0xFFF57C00, sortOrder: 1),
      LoungeCatalogItem(id: 'social-2', name: 'بين الناس', roleLabel: 'برنامج', imageUrl: _socialImage, accentColorValue: 0xFFFB8C00, sortOrder: 2),
      LoungeCatalogItem(id: 'social-3', name: 'قضية وحوار', roleLabel: 'برنامج', imageUrl: _studioImage, accentColorValue: 0xFFFFA726, sortOrder: 3),
    ]),
    'religious-programs': LoungeCategoryCatalog(categoryId: 'religious-programs', sectionTitle: 'البرامج', trackItemLabel: 'حلقة', items: [
      LoungeCatalogItem(id: 'religious-program-1', name: 'نور القلوب', roleLabel: 'برنامج', imageUrl: _quranImage, accentColorValue: 0xFF00897B, sortOrder: 1),
      LoungeCatalogItem(id: 'religious-program-2', name: 'نفحات إيمانية', roleLabel: 'برنامج', imageUrl: _quranImage, accentColorValue: 0xFF009688, sortOrder: 2),
      LoungeCatalogItem(id: 'religious-program-3', name: 'فقه الحياة', roleLabel: 'برنامج', imageUrl: _booksImage, accentColorValue: 0xFF26A69A, sortOrder: 3),
    ]),
  };

  static LoungeCategoryCatalog? byCategoryId(String categoryId) {
    return catalogs[categoryId];
  }
}
