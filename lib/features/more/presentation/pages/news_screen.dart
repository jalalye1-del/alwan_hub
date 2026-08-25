import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';

import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/theme/app_colors.dart';
import 'package:alwan_hub/core/widgets/alwan_page_header.dart';
import 'package:alwan_hub/features/more/presentation/widgets/more_typography.dart';
import 'package:alwan_hub/features/notifications/presentation/pages/notifications_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key, this.initialCategory = trendingCategory});

  static const String trendingCategory = 'الأخبار الرائجة';

  final String initialCategory;

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  static const _categories = [
    NewsScreen.trendingCategory,
    'الأخبار الفنية',
    'الأخبار الثقافية',
    'الأخبار الرياضية',
    'الأخبار العالمية',
  ];

  static const _newsByCategory = <String, List<_NewsItem>>{
    NewsScreen.trendingCategory: [
      _NewsItem(
        title: 'مهرجان ألوان للموسيقى العربية يعود في نسخته العاشرة',
        summary:
            'استعدادات واسعة لإطلاق نسخة جديدة تجمع الأصوات اليمنية والعربية على مسرح واحد.',
        image: 'assets/images/lounge/الموسيقى.png',
        time: 'منذ 15 دقيقة',
      ),
      _NewsItem(
        title: 'حفل الفنانة روبي يحقق نجاحًا كبيرًا في ليلة استثنائية',
        summary: 'تفاعل جماهيري واسع مع برنامج فني متنوع.',
        image: 'assets/images/lounge/البرامج الفنية.png',
        time: 'منذ ساعة',
      ),
      _NewsItem(
        title: 'ألوان تطلق خريطة برامجها الجديدة لهذا الموسم',
        summary: 'برامج مباشرة ومسابقات ومحتوى صوتي جديد.',
        image: 'assets/images/quick_access/podcast.jpg',
        time: 'منذ ساعتين',
      ),
    ],
    'الأخبار الفنية': [
      _NewsItem(
        title: 'أصوات يمنية شابة تتألق في المشهد الفني العربي',
        summary: 'مواهب جديدة تمزج التراث بالإنتاج الموسيقي الحديث.',
        image: 'assets/images/lounge/البرامج الفنية.png',
        time: 'اليوم',
      ),
      _NewsItem(
        title: 'جلسة غنائية خاصة تبث مباشرة عبر منصة ألوان',
        summary: 'لقاء فني يجمع الموسيقى والحديث مع الجمهور.',
        image: 'assets/images/lounge/الأغاني اليمنية.png',
        time: 'منذ 3 ساعات',
      ),
    ],
    'الأخبار الثقافية': [
      _NewsItem(
        title: 'الكتاب الصوتي العربي يفتح آفاقًا جديدة للقراء',
        summary: 'إصدارات جديدة وتجارب استماع أكثر قربًا وسهولة.',
        image: 'assets/images/lounge/البرامج الثقافية.png',
        time: 'اليوم',
      ),
      _NewsItem(
        title: 'ألوان تحتفي بالموروث الشعبي اليمني في برنامج وثائقي',
        summary: 'رحلة صوتية بين الحكايات والموسيقى والذاكرة.',
        image: 'assets/images/lounge/البرامج الوثائقية.png',
        time: 'أمس',
      ),
    ],
    'الأخبار الرياضية': [
      _NewsItem(
        title: 'موجز ألوان الرياضي يعود بتغطية يومية موسعة',
        summary: 'نتائج وتحليلات وأبرز أخبار الملاعب العربية والعالمية.',
        image: 'assets/images/quick_access/games.jpg',
        time: 'منذ 30 دقيقة',
      ),
      _NewsItem(
        title: 'مواهب يمنية واعدة تخطف الأنظار في البطولات المحلية',
        summary: 'قصص نجاح رياضية تستحق المتابعة.',
        image: 'assets/images/quick_access/games.jpg',
        time: 'اليوم',
      ),
    ],
    'الأخبار العالمية': [
      _NewsItem(
        title: 'جولة سريعة في أبرز أحداث العالم اليوم',
        summary: 'ملخص موثوق لأهم الأخبار الدولية والتطورات الجديدة.',
        image: 'assets/images/fm/covers/BBC World Service_cover.png',
        time: 'منذ 20 دقيقة',
      ),
      _NewsItem(
        title: 'كيف تغير المنصات الرقمية مستقبل الإعلام الصوتي؟',
        summary: 'تجارب عالمية جديدة في البث والبودكاست.',
        image: 'assets/images/fm/covers/Voice of America_cover.png',
        time: 'منذ 4 ساعات',
      ),
    ],
  };

  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.contains(widget.initialCategory)
        ? widget.initialCategory
        : _categories.first;
  }

  List<_NewsItem> get _visibleNews =>
      _newsByCategory[_selectedCategory] ?? const [];

  @override
  Widget build(BuildContext context) {
    final news = _visibleNews;
    return MoreTypography(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FD),
        body: Column(
          children: [
            AlwanPageHeader(
              title: 'الأخبار',
              subtitle: 'آخر الأخبار والتحديثات من إذاعة ألوان',
              onNotificationTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 30),
                child: ResponsiveContent(
                  maxWidth: 820,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 43,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return ChoiceChip(
                              key: ValueKey('news-category-$category'),
                              selected: category == _selectedCategory,
                              label: Text(category),
                              labelStyle: TextStyle(
                                color: category == _selectedCategory
                                    ? const Color(0xFF77299C)
                                    : const Color(0xFF505A72),
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                              selectedColor: const Color(0xFFF2E5FB),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: category == _selectedCategory
                                    ? const Color(0xFFD9BCEB)
                                    : const Color(0xFFDDE2EA),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              onSelected: (_) =>
                                  setState(() => _selectedCategory = category),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _NewsStats(),
                      const SizedBox(height: 16),
                      if (news.isNotEmpty) _FeaturedNews(item: news.first),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'آخر الأخبار',
                              style: TextStyle(
                                color: Color(0xFF292F70),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECE8FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${news.length} أخبار',
                              style: const TextStyle(
                                color: Color(0xFF6B3BA0),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      for (var index = 0; index < news.length; index++) ...[
                        _NewsListCard(item: news[index]),
                        if (index != news.length - 1) const SizedBox(height: 9),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewsItem {
  const _NewsItem({
    required this.title,
    required this.summary,
    required this.image,
    required this.time,
  });

  final String title;
  final String summary;
  final String image;
  final String time;
}

class _NewsStats extends StatelessWidget {
  const _NewsStats();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE2EA)),
      ),
      child: const Row(
        children: [
          Expanded(
            child: _NewsStat(value: '24', label: 'أخبار اليوم'),
          ),
          Expanded(
            child: _NewsStat(value: 'منذ 15 دقيقة', label: 'آخر تحديث'),
          ),
          Expanded(
            child: _NewsStat(value: '2.4K', label: 'الأكثر قراءة'),
          ),
        ],
      ),
    );
  }
}

class _NewsStat extends StatelessWidget {
  const _NewsStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 9),
        ),
        const SizedBox(height: 5),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF392576),
              fontFamily: 'MohammadBoldArt',
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeaturedNews extends StatelessWidget {
  const _FeaturedNews({required this.item});

  final _NewsItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFD9DFE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14101B30),
            blurRadius: 13,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 185,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(item.image, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xA8000000)],
                    ),
                  ),
                ),
                const Positioned(
                  top: 12,
                  right: 12,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0xEFFFFFFF),
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      child: Text(
                        'الأبرز الآن',
                        style: TextStyle(
                          color: Color(0xFF6A2E98),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Color(0xFF292F6E),
                    fontSize: 17,
                    height: 1.35,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  item.summary,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 11),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton.icon(
                    onPressed: () => _showArticle(context, item),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF8B28A8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back_rounded, size: 17),
                    label: const Text('اقرأ المزيد'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsListCard extends StatelessWidget {
  const _NewsListCard({required this.item});

  final _NewsItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: () => _showArticle(context, item),
        borderRadius: BorderRadius.circular(17),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFDDE2EA)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(
                  item.image,
                  width: 74,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2B3269),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.time,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: Color(0xFF8A91A3)),
            ],
          ),
        ),
      ),
    );
  }
}

void _showArticle(BuildContext context, _NewsItem item) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => MoreTypography(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  color: Color(0xFF292F70),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.summary,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.time,
                style: const TextStyle(color: Color(0xFF8B28A8), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
