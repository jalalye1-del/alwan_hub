import 'package:alwan_hub/features/podcasts/domain/entities/podcast_episode.dart';
import 'package:alwan_hub/features/podcasts/domain/repositories/podcast_repository.dart';

/// Local seed repository. A dashboard/API implementation can replace this
/// class without changing the presentation or playback layers.
class LocalPodcastRepository implements PodcastRepository {
  const LocalPodcastRepository();

  static final List<Map<String, dynamic>> _dashboardSeed = [
    {
      'id': 'podcast-consumer-behaviour',
      'title': 'فهم سلوك المستهلك وصدمات العرض والطلب',
      'description':
          'قراءة مبسطة في قرارات الشراء وكيف تغيّر الظروف اليومية سلوك الأسواق والمجتمع.',
      'hostName': 'أ. منير الشيباني',
      'seriesName': 'اقتصاد ببساطة',
      'audioUrl':
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'videoQualityUrls': {
        'تلقائي':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        '1080p HD':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        '720p HD':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        '480p SD':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      },
      'subtitlesUrl': '',
      'imageUrl': 'assets/images/quick_access/podcast.jpg',
      'durationSeconds': 910,
      'publishedAt': '2026-08-06T09:00:00.000Z',
      'listeners': 2400,
      'isFeatured': true,
    },
    {
      'id': 'podcast-digital-parenting',
      'title': 'تربية الأطفال في العصر الرقمي',
      'description':
          'دليل عملي للأسرة لفهم التطبيقات والألعاب وبناء عادات رقمية أكثر توازنًا.',
      'hostName': 'د. سارة العلواني',
      'seriesName': 'مساحة أسرة',
      'audioUrl':
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'videoQualityUrls': {
        'تلقائي':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        '1080p HD':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        '720p HD':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        '480p SD':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      },
      'subtitlesUrl': '',
      'imageUrl': 'assets/images/program.jpg',
      'durationSeconds': 1125,
      'publishedAt': '2026-08-03T12:00:00.000Z',
      'listeners': 1850,
      'isFeatured': false,
    },
    {
      'id': 'podcast-yemeni-creativity',
      'title': 'كيف يصنع الشباب اليمني فرصته؟',
      'description':
          'حوار ملهم حول تحويل الأفكار الصغيرة إلى مشاريع مؤثرة وقابلة للنمو.',
      'hostName': 'شروق أحمد',
      'seriesName': 'حكاية نجاح',
      'audioUrl':
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'videoQualityUrls': {
        'تلقائي':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        '1080p HD':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        '720p HD':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        '480p SD':
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      },
      'subtitlesUrl': '',
      'imageUrl': 'assets/images/shurooq.jpg',
      'durationSeconds': 1260,
      'publishedAt': '2026-07-30T15:30:00.000Z',
      'listeners': 3120,
      'isFeatured': false,
    },
  ];

  @override
  Future<List<PodcastEpisode>> fetchEpisodes() async {
    final episodes = _dashboardSeed
        .map(PodcastEpisode.fromDashboardMap)
        .toList(growable: false);
    return episodes..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }
}
