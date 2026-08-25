import 'package:flutter/foundation.dart';

import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/router/app_router.dart';
import 'package:alwan_hub/features/audiobooks/data/repositories/local_audiobook_playback_catalog_repository.dart';
import 'package:alwan_hub/features/fm_radio/data/repositories/local_fm_station_repository.dart';
import 'package:alwan_hub/features/lounge/data/audio_repository.dart';
import 'package:alwan_hub/features/lounge/data/lounge_catalog_data.dart';
import 'package:alwan_hub/features/lounge/data/lounge_categories.dart';
import 'package:alwan_hub/features/lounge/domain/mappers/audio_item_mapper.dart';
import 'package:alwan_hub/features/podcasts/data/repositories/local_podcast_repository.dart';
import 'package:alwan_hub/features/podcasts/domain/mappers/podcast_episode_mapper.dart';

typedef AlwanAiMediaCatalogLoader = Future<List<AudioTrack>> Function();

enum AlwanAiCommandType {
  none,
  navigate,
  play,
  pause,
  resume,
  stop,
  next,
  previous,
}

enum AlwanAiSearchKind { destination, audio }

@immutable
class AlwanAiCommandResult {
  const AlwanAiCommandResult._({
    required this.type,
    required this.message,
    this.routeName,
    this.pathParameters = const {},
    this.queryParameters = const {},
    this.track,
  });

  const AlwanAiCommandResult.unhandled()
    : this._(type: AlwanAiCommandType.none, message: '');

  final AlwanAiCommandType type;
  final String message;
  final String? routeName;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final AudioTrack? track;

  bool get handled => type != AlwanAiCommandType.none;
}

@immutable
class AlwanAiSearchResult {
  const AlwanAiSearchResult({
    required this.kind,
    required this.title,
    required this.subtitle,
    this.routeName,
    this.pathParameters = const {},
    this.queryParameters = const {},
    this.track,
  });

  final AlwanAiSearchKind kind;
  final String title;
  final String subtitle;
  final String? routeName;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final AudioTrack? track;
}

@immutable
class _Destination {
  const _Destination({
    required this.title,
    required this.routeName,
    required this.aliases,
    this.pathParameters = const {},
    this.queryParameters = const {},
  });

  final String title;
  final String routeName;
  final List<String> aliases;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
}

class AlwanAiCommandService {
  AlwanAiCommandService({AlwanAiMediaCatalogLoader? loadMediaCatalog})
    : _loadMediaCatalog = loadMediaCatalog ?? loadBuiltInMediaCatalog;

  final AlwanAiMediaCatalogLoader _loadMediaCatalog;

  static const _liveTrack = AudioTrack(
    id: 'live_alwan_fm',
    title: 'البث المباشر',
    subtitle: 'إذاعة ألوان FM 88.7',
    url: 'https://s9.voscast.com:9617/stream',
    imageUrl: 'assets/images/splash_logo.png',
    presenterName: 'إذاعة ألوان',
    isLiveStream: true,
    isFm: true,
    sourceType: AudioSourceType.fm,
    category: 'البث المباشر',
  );

  static final _destinations = <_Destination>[
    const _Destination(
      title: 'الواجهة الرئيسية',
      routeName: AppRoutes.home,
      aliases: ['الرئيسية', 'الصفحة الرئيسية', 'الواجهة الرئيسية', 'البداية'],
    ),
    const _Destination(
      title: 'برامج FM',
      routeName: AppRoutes.fmPrograms,
      aliases: ['البرامج', 'برامج اف ام', 'برامج fm', 'برامج الاذاعة'],
    ),
    const _Destination(
      title: 'إذاعات FM',
      routeName: AppRoutes.fmRadio,
      aliases: ['الاذاعات', 'اذاعة', 'اذاعة اف ام', 'محطات الراديو'],
    ),
    const _Destination(
      title: 'استراحة ألوان',
      routeName: AppRoutes.lounge,
      aliases: ['الاستراحة', 'استراحة الوان', 'الصوتيات'],
    ),
    const _Destination(
      title: 'مكتبتي',
      routeName: AppRoutes.library,
      aliases: ['مكتبتي', 'المكتبة', 'مكتبة الصوت'],
    ),
    const _Destination(
      title: 'التسجيلات',
      routeName: AppRoutes.recordings,
      aliases: ['التسجيلات', 'تسجيلاتي', 'المسجل'],
    ),
    const _Destination(
      title: 'مشغل الصوت',
      routeName: AppRoutes.player,
      aliases: ['المشغل', 'مشغل الصوت', 'قيد التشغيل'],
    ),
    const _Destination(
      title: 'المسابقات والألعاب',
      routeName: AppRoutes.games,
      aliases: ['الالعاب', 'المسابقات', 'العاب ومسابقات'],
    ),
    const _Destination(
      title: 'بودكاست ألوان',
      routeName: AppRoutes.podcasts,
      aliases: ['البودكاست', 'بودكاست', 'الحلقات'],
    ),
    const _Destination(
      title: 'الكتب الصوتية',
      routeName: AppRoutes.audiobooks,
      aliases: ['الكتب الصوتيه', 'كتاب صوتي', 'الروايات الصوتيه'],
    ),
    const _Destination(
      title: 'المفضلة',
      routeName: AppRoutes.favorites,
      aliases: ['المفضله', 'المواد المفضله', 'اختياراتي'],
    ),
    const _Destination(
      title: 'شارك ودردش',
      routeName: AppRoutes.shareAndChat,
      aliases: ['شارك ودردش', 'الدردشه المباشره', 'تواصل مع البرنامج'],
    ),
    const _Destination(
      title: 'الأخبار الرائجة',
      routeName: AppRoutes.moreNews,
      aliases: ['الاخبار', 'الاخبار الرائجة', 'الترند', 'اخر الاخبار'],
      queryParameters: {'category': 'الأخبار الرائجة'},
    ),
    for (final category in const [
      'الأخبار الفنية',
      'الأخبار الثقافية',
      'الأخبار الرياضية',
      'الأخبار العالمية',
    ])
      _Destination(
        title: category,
        routeName: AppRoutes.moreNews,
        aliases: [category],
        queryParameters: {'category': category},
      ),
    const _Destination(
      title: 'الأبراج اليومية',
      routeName: AppRoutes.dailyHoroscopes,
      aliases: ['الابراج', 'الابراج اليومية', 'برج اليوم'],
    ),
    const _Destination(
      title: 'الإشعارات',
      routeName: AppRoutes.notifications,
      aliases: ['الاشعارات', 'التنبيهات'],
    ),
    const _Destination(
      title: 'الملف الشخصي',
      routeName: AppRoutes.profile,
      aliases: ['الملف الشخصي', 'حسابي', 'الحساب'],
    ),
    const _Destination(
      title: 'القبلة ومواقيت الصلاة',
      routeName: AppRoutes.prayerQibla,
      aliases: ['القبلة', 'مواقيت الصلاة', 'الصلاة'],
    ),
    const _Destination(
      title: 'جودة البث',
      routeName: AppRoutes.streamQuality,
      aliases: ['جودة البث', 'جودة الصوت'],
    ),
    const _Destination(
      title: 'اللغة',
      routeName: AppRoutes.language,
      aliases: ['اللغة', 'تغيير اللغة'],
    ),
    const _Destination(
      title: 'المظهر',
      routeName: AppRoutes.appearance,
      aliases: ['المظهر', 'الوضع الليلي', 'الثيم'],
    ),
    const _Destination(
      title: 'المزيد',
      routeName: AppRoutes.more,
      aliases: ['المزيد', 'القائمة'],
    ),
    const _Destination(
      title: 'فريق ألوان',
      routeName: AppRoutes.moreTeam,
      aliases: ['فريق الوان', 'فريق العمل', 'صناع الوان'],
    ),
    const _Destination(
      title: 'من نحن',
      routeName: AppRoutes.moreAboutUs,
      aliases: ['من نحن', 'عن اذاعه الوان', 'رؤيه الوان'],
    ),
    const _Destination(
      title: 'تواصل معنا',
      routeName: AppRoutes.moreContact,
      aliases: ['تواصل معنا', 'اتصل بنا', 'الدعم'],
    ),
    const _Destination(
      title: 'عن التطبيق',
      routeName: AppRoutes.moreAboutApp,
      aliases: ['عن التطبيق', 'معلومات التطبيق'],
    ),
    const _Destination(
      title: 'آخر تحديثات التطبيق',
      routeName: AppRoutes.moreUpdates,
      aliases: ['تحديثات التطبيق', 'اخر التحديثات', 'ما الجديد'],
    ),
    const _Destination(
      title: 'تقييم التطبيق',
      routeName: AppRoutes.appRating,
      aliases: ['تقييم التطبيق', 'قيم التطبيق', 'اضف تقييم'],
    ),
    const _Destination(
      title: 'مشاركة التطبيق',
      routeName: AppRoutes.shareApp,
      aliases: ['مشاركه التطبيق', 'شارك التطبيق'],
    ),
    for (final category in LoungeCategoriesData.loungeCategories)
      _Destination(
        title: category.title,
        routeName: AppRoutes.category,
        aliases: [category.title, category.gridTitle, category.bannerTitle],
        pathParameters: {'id': category.id},
      ),
  ];

  Future<AlwanAiCommandResult> resolve(String input) async {
    final query = normalizeArabic(input);
    if (query.isEmpty) return const AlwanAiCommandResult.unhandled();

    if (_containsAny(query, const ['التالي', 'المقطع التالي', 'شغل التالي'])) {
      return const AlwanAiCommandResult._(
        type: AlwanAiCommandType.next,
        message: 'تم الانتقال إلى المقطع التالي.',
      );
    }
    if (_containsAny(query, const ['السابق', 'المقطع السابق', 'شغل السابق'])) {
      return const AlwanAiCommandResult._(
        type: AlwanAiCommandType.previous,
        message: 'تم الرجوع إلى المقطع السابق.',
      );
    }
    if (_containsAny(query, const [
      'انه التشغيل',
      'اغلق الصوت',
      'ايقاف كامل',
    ])) {
      return const AlwanAiCommandResult._(
        type: AlwanAiCommandType.stop,
        message: 'تم إيقاف التشغيل.',
      );
    }
    if (_containsAny(query, const [
      'اوقف',
      'توقف',
      'ايقاف موقت',
      'وقف الصوت',
    ])) {
      return const AlwanAiCommandResult._(
        type: AlwanAiCommandType.pause,
        message: 'تم إيقاف الصوت مؤقتًا.',
      );
    }
    if (_containsAny(query, const [
      'استكمل',
      'اكمل التشغيل',
      'واصل',
      'تابع التشغيل',
    ])) {
      return const AlwanAiCommandResult._(
        type: AlwanAiCommandType.resume,
        message: 'تم استئناف التشغيل.',
      );
    }

    final hasOpenIntent = _containsAny(query, const [
      'افتح',
      'فتح',
      'اذهب',
      'انتقل',
      'اعرض',
      'روح',
      'وديني',
      'خذني',
      'شغل الواجهه',
    ]);
    final hasPlayIntent = _containsAny(query, const [
      'شغل',
      'تشغيل',
      'استمع',
      'اسمع',
      'ابدأ الصوت',
    ]);
    final hasDirectMediaRequest = _containsAny(query, const [
      'اغنيه',
      'انشوده',
      'تلاوه',
      'حلقه',
      'ملف صوتي',
      'مقطع صوتي',
    ]);
    final hasMediaRequest = hasDirectMediaRequest ||
        _containsAny(query, const [
          'اغاني',
          'موسيقى',
          'موسيقي',
          'بودكاست',
          'كتاب صوتي',
          'تسجيل',
          'اذاعة',
          'اذاعه',
          'برنامج',
        ]);

    final destination = _matchDestination(query);
    if (destination != null &&
        !hasDirectMediaRequest &&
        (hasOpenIntent || _isExactDestination(query, destination))) {
      return AlwanAiCommandResult._(
        type: AlwanAiCommandType.navigate,
        routeName: destination.routeName,
        pathParameters: destination.pathParameters,
        queryParameters: destination.queryParameters,
        message: 'تم فتح ${destination.title}.',
      );
    }

    if (hasPlayIntent || (hasOpenIntent && hasMediaRequest)) {
      final requested = _removeCommandWords(query);
      final tracks = await _mediaCatalog();
      final track = _bestTrack(requested, tracks);
      if (track != null) {
        return AlwanAiCommandResult._(
          type: AlwanAiCommandType.play,
          track: track,
          message: track.url.trim().isEmpty
              ? 'تم فتح ${track.title} بصوت ${track.subtitle} في المشغل.'
              : 'تم تشغيل ${track.title} بصوت ${track.subtitle}.',
        );
      }
    }

    return const AlwanAiCommandResult.unhandled();
  }

  Future<List<AlwanAiSearchResult>> search(String input) async {
    final query = normalizeArabic(input);
    if (query.isEmpty) return const [];

    final results = <({int score, AlwanAiSearchResult result})>[];
    for (final destination in _destinations) {
      final score = _destinationScore(query, destination);
      if (score > 0) {
        results.add((
          score: score,
          result: AlwanAiSearchResult(
            kind: AlwanAiSearchKind.destination,
            title: destination.title,
            subtitle: 'فتح الواجهة',
            routeName: destination.routeName,
            pathParameters: destination.pathParameters,
            queryParameters: destination.queryParameters,
          ),
        ));
      }
    }

    for (final track in await _mediaCatalog()) {
      final haystack = normalizeArabic(
        '${track.title} ${track.subtitle} ${track.category} ${track.presenterName ?? ''}',
      );
      final score = _textScore(query, haystack);
      if (score > 0) {
        results.add((
          score: score,
          result: AlwanAiSearchResult(
            kind: AlwanAiSearchKind.audio,
            title: track.title,
            subtitle: track.subtitle,
            track: track,
          ),
        ));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(10).map((item) => item.result).toList(growable: false);
  }

  _Destination? _matchDestination(String query) {
    _Destination? best;
    var bestScore = 0;
    for (final destination in _destinations) {
      final score = _destinationScore(query, destination);
      if (score > bestScore) {
        best = destination;
        bestScore = score;
      }
    }
    return bestScore >= 60 ? best : null;
  }

  bool _isExactDestination(String query, _Destination destination) {
    final values = [destination.title, ...destination.aliases];
    return values.any((value) => normalizeArabic(value) == query);
  }

  int _destinationScore(String query, _Destination destination) {
    return [destination.title, ...destination.aliases]
        .map((value) {
          final normalized = normalizeArabic(value);
          final score = _textScore(query, normalized);
          if (!query.contains(normalized)) return score;
          final specificity = normalized.length > 25 ? 25 : normalized.length;
          final enriched = score + specificity;
          return enriched > 100 ? 100 : enriched;
        })
        .fold<int>(0, (best, score) => score > best ? score : best);
  }

  AudioTrack? _bestTrack(String query, List<AudioTrack> tracks) {
    if (query.isEmpty || _containsAny(query, const ['البث', 'الوان اف ام'])) {
      return _liveTrack;
    }

    AudioTrack? best;
    var bestScore = 0;
    for (final track in tracks) {
      final haystack = normalizeArabic(
        '${track.title} ${track.subtitle} ${track.category} ${track.presenterName ?? ''}',
      );
      final score = _textScore(query, haystack);
      final preferPlayable = score == bestScore &&
          best != null &&
          best.url.trim().isEmpty &&
          track.url.trim().isNotEmpty;
      if (score > bestScore || preferPlayable) {
        bestScore = score;
        best = track;
      }
    }
    return bestScore >= 40 ? best : null;
  }

  Future<List<AudioTrack>> _mediaCatalog() => _loadMediaCatalog();

  static Future<List<AudioTrack>> loadBuiltInMediaCatalog() async {
    final tracks = <AudioTrack>[_liveTrack];

    try {
      const repository = AudioRepository();
      for (final catalog in LoungeCatalogData.catalogs.values) {
        for (final item in catalog.items.where((item) => item.isActive)) {
          final artistTracks = repository.getByCategoryItem(
            item.id,
            itemTitle: item.name,
            trackItemLabel: catalog.trackItemLabel,
          );
          tracks.addAll(
            artistTracks.map(
              (track) => track
                  .toAudioTrack(category: catalog.categoryId)
                  .copyWith(
                    imageUrl: item.imageUrl,
                    presenterName: item.name,
                  ),
            ),
          );
        }
      }
    } catch (_) {
      // تبقى بقية المصادر متاحة إذا تعذر تحميل فهرس استراحة ألوان.
    }

    try {
      final stations = await LocalFmStationRepository().getStations();
      tracks.addAll(
        stations
            .where((station) => station.url.trim().isNotEmpty)
            .map((station) => station.toAudioTrack()),
      );
    } catch (_) {
      // يبقى البث الرئيسي والمصادر الأخرى متاحاً عند تعذر التخزين المحلي.
    }

    try {
      final episodes = await const LocalPodcastRepository().fetchEpisodes();
      tracks.addAll(
        episodes
            .where((episode) => episode.audioUrl.trim().isNotEmpty)
            .map((episode) => episode.toAudioTrack()),
      );
    } catch (_) {
      // لا يمنع تعذر مصدر واحد بقية الأوامر من العمل.
    }

    try {
      final books = await const LocalAudiobookPlaybackCatalogRepository()
          .fetchBooks();
      tracks.addAll(books.where((book) => book.url.trim().isNotEmpty));
    } catch (_) {
      // لا يمنع تعذر مصدر واحد بقية الأوامر من العمل.
    }

    final unique = <String, AudioTrack>{};
    for (final track in tracks) {
      unique[track.id] = track;
    }
    return unique.values.toList(growable: false);
  }

  static int _textScore(String needle, String haystack) {
    if (needle == haystack) return 100;
    if (haystack.contains(needle)) return 80;
    if (needle.contains(haystack) && haystack.length >= 3) return 65;

    final tokens = needle
        .split(' ')
        .where((token) => token.length >= 2)
        .toSet();
    if (tokens.isEmpty) return 0;
    final matches = tokens.where(haystack.contains).length;
    return matches == 0 ? 0 : ((matches / tokens.length) * 60).round();
  }

  static bool _containsAny(String value, List<String> candidates) {
    return candidates.any((candidate) => value.contains(candidate));
  }

  static String _removeCommandWords(String value) {
    var result = value;
    for (final word in const [
      'من فضلك',
      'لو سمحت',
      'قم بتشغيل',
      'قم بفتح',
      'شغل لي',
      'افتح لي',
      'شغل',
      'تشغيل',
      'بفتح',
      'افتح',
      'استمع الى',
      'استمع',
      'اسمع',
      'ابدأ الصوت',
      'من اغاني',
      'من اعمال',
      'للفنانه',
      'للفنان',
      'للمطربه',
      'للمطرب',
      'الفنانه',
      'الفنان',
      'المطربه',
      'المطرب',
      'اغنيه',
      'اغاني',
      'انشوده',
      'تلاوه',
      'موسيقى',
      'موسيقي',
      'بودكاست',
      'حلقه',
      'كتاب صوتي',
      'تسجيل صوتي',
      'تسجيل',
      'اذاعة',
      'اذاعه',
      'برنامج',
      'ملف صوتي',
      'مقطع صوتي',
      'الرجاء',
      'رجاء',
      'قم',
    ]) {
      result = result.replaceAll(word, ' ');
    }
    return result.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

String normalizeArabic(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
      .replaceAll(RegExp('[أإآٱ]'), 'ا')
      .replaceAll('ؤ', 'و')
      .replaceAll('ئ', 'ي')
      .replaceAll('ى', 'ي')
      .replaceAll('ة', 'ه')
      .replaceAll(RegExp(r'[^a-z0-9\u0600-\u06FF ]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
