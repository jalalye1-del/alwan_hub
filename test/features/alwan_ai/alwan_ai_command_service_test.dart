import 'package:flutter_test/flutter_test.dart';

import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/router/app_router.dart';
import 'package:alwan_hub/features/alwan_ai/application/alwan_ai_command_service.dart';

void main() {
  late AlwanAiCommandService service;

  setUp(() {
    service = AlwanAiCommandService(
      loadMediaCatalog: () async => const [
        AudioTrack(
          id: 'delta',
          title: 'إذاعة دلتا',
          subtitle: 'البث المباشر من صنعاء',
          url: 'https://example.com/delta.mp3',
          sourceType: AudioSourceType.fm,
          category: 'إذاعات FM',
        ),
        AudioTrack(
          id: 'podcast-family',
          title: 'تربية الأطفال في العصر الرقمي',
          subtitle: 'مساحة أسرة',
          url: 'https://example.com/podcast.mp3',
          sourceType: AudioSourceType.podcast,
          category: 'بودكاست ألوان',
        ),
        AudioTrack(
          id: 'abubakr-salem-1',
          title: 'سر حبي',
          subtitle: 'أبوبكر سالم',
          url: 'https://example.com/abu-bakr-salem.mp3',
          sourceType: AudioSourceType.music,
          category: 'الأغاني اليمنية',
        ),
      ],
    );
  });

  test('recognizes Arabic navigation commands after normalization', () async {
    final result = await service.resolve('من فضلك افتح الأبراج اليومية');

    expect(result.handled, isTrue);
    expect(result.type, AlwanAiCommandType.navigate);
    expect(result.routeName, AppRoutes.dailyHoroscopes);
  });

  test('finds and selects an audio file from a voice command', () async {
    final result = await service.resolve('شغّل إذاعة دلتا');

    expect(result.type, AlwanAiCommandType.play);
    expect(result.track?.id, 'delta');
  });

  test('opens an artist song from a natural Arabic request', () async {
    final result = await service.resolve(
      'قم بفتح أغنية للفنان أبو بكر سالم',
    );

    expect(result.type, AlwanAiCommandType.play);
    expect(result.track?.id, 'abubakr-salem-1');
  });

  test('recognizes conversational navigation phrases', () async {
    final openNews = await service.resolve('قم بفتح الأخبار الرائجة');
    final openLibrary = await service.resolve('وديني إلى المكتبة');

    expect(openNews.type, AlwanAiCommandType.navigate);
    expect(openNews.routeName, AppRoutes.moreNews);
    expect(openLibrary.type, AlwanAiCommandType.navigate);
    expect(openLibrary.routeName, AppRoutes.library);
  });

  test('covers application sections and nested lounge categories', () async {
    final audiobooks = await service.resolve('افتح الكتب الصوتية');
    final favorites = await service.resolve('خذني إلى المفضلة');
    final chat = await service.resolve('افتح شارك ودردش');
    final category = await service.resolve('افتح الأغاني اليمنية');
    final news = await service.resolve('اعرض الأخبار الرياضية');

    expect(audiobooks.routeName, AppRoutes.audiobooks);
    expect(favorites.routeName, AppRoutes.favorites);
    expect(chat.routeName, AppRoutes.shareAndChat);
    expect(category.routeName, AppRoutes.category);
    expect(category.pathParameters, {'id': 'yemeni-songs'});
    expect(news.routeName, AppRoutes.moreNews);
    expect(news.queryParameters, {'category': 'الأخبار الرياضية'});
  });

  test('reloads the media catalog so newly added files are searchable', () async {
    var catalog = const <AudioTrack>[];
    final dynamicService = AlwanAiCommandService(
      loadMediaCatalog: () async => catalog,
    );

    final before = await dynamicService.resolve('شغل تسجيل اجتماع العمل');
    catalog = const [
      AudioTrack(
        id: 'recording-meeting',
        title: 'اجتماع العمل',
        subtitle: 'تسجيلاتي',
        url: 'C:/recordings/meeting.m4a',
        sourceType: AudioSourceType.local,
        category: 'التسجيلات',
      ),
    ];
    final after = await dynamicService.resolve('شغل تسجيل اجتماع العمل');

    expect(before.handled, isFalse);
    expect(after.type, AlwanAiCommandType.play);
    expect(after.track?.id, 'recording-meeting');
  });

  test('plays the main live stream when requested', () async {
    final result = await service.resolve('تشغيل البث المباشر');

    expect(result.type, AlwanAiCommandType.play);
    expect(result.track?.id, 'live_alwan_fm');
    expect(result.track?.url, isNotEmpty);
  });

  test('returns local destinations and audio in quick search', () async {
    final destinations = await service.search('الأخبار');
    final audio = await service.search('تربية الأطفال');

    expect(
      destinations.any((item) => item.routeName == AppRoutes.moreNews),
      isTrue,
    );
    expect(audio.any((item) => item.track?.id == 'podcast-family'), isTrue);
  });

  test('leaves general questions to the cloud chat', () async {
    final result = await service.resolve('كيف يمكنني تنظيم وقتي؟');

    expect(result.handled, isFalse);
  });
}
