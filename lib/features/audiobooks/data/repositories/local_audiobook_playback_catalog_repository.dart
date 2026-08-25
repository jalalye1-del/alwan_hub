import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/features/audiobooks/domain/repositories/audiobook_playback_catalog_repository.dart';

/// بيانات تجريبية بنفس بنية لوحة التحكم، تستخدم إلى أن يُحقن مصدر بعيد.
class LocalAudiobookPlaybackCatalogRepository
    implements AudiobookPlaybackCatalogRepository {
  const LocalAudiobookPlaybackCatalogRepository();

  static const _sampleAudioUrl =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

  static const _books = <AudioTrack>[
    AudioTrack(
      id: 'audiobook-voice-art',
      title: 'فن الإلقاء الصوتي',
      subtitle: 'تطوير الذات',
      presenterName: 'أحمد الإبراهيمي',
      category: 'الكتب الصوتية',
      url: _sampleAudioUrl,
      imageUrl:
          'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?auto=format&fit=crop&w=640&q=85',
      rating: 4.5,
      description: 'دليل شامل لتعلّم مهارات الإلقاء والتأثير الصوتي.',
      durationText: '02:15:00',
      downloads: 850,
      sourceType: AudioSourceType.audiobook,
    ),
    AudioTrack(
      id: 'audiobook-management',
      title: 'أسرار الإدارة الناجحة',
      subtitle: 'إدارة',
      presenterName: 'د. خالد العمري',
      category: 'الكتب الصوتية',
      url: _sampleAudioUrl,
      imageUrl:
          'https://images.unsplash.com/photo-1512820790803-83ca734da794?auto=format&fit=crop&w=640&q=85',
      rating: 4.7,
      description: 'استراتيجيات حديثة في فن الإدارة والقيادة الفعالة.',
      durationText: '03:40:00',
      downloads: 1200,
      sourceType: AudioSourceType.audiobook,
    ),
    AudioTrack(
      id: 'audiobook-anxiety',
      title: 'دع القلق وابدأ الحياة',
      subtitle: 'الأدب',
      presenterName: 'ديل كارنيجي',
      category: 'الكتب الصوتية',
      url: _sampleAudioUrl,
      imageUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=640&q=85',
      rating: 4.8,
      description: 'طرق عملية للتخلص من القلق والعيش بسلام وطمأنينة.',
      durationText: '04:32:00',
      downloads: 3400,
      sourceType: AudioSourceType.audiobook,
    ),
    AudioTrack(
      id: 'audiobook-indifference',
      title: 'فن اللامبالاة',
      subtitle: 'التطوير',
      presenterName: 'مارك مانسون',
      category: 'الكتب الصوتية',
      url: _sampleAudioUrl,
      imageUrl:
          'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?auto=format&fit=crop&w=640&q=85',
      rating: 4.9,
      description: 'دليل عملي لحياة أكثر هدوءًا وسعادة.',
      durationText: '05:48:00',
      downloads: 5200,
      sourceType: AudioSourceType.audiobook,
    ),
    AudioTrack(
      id: 'audiobook-riyad',
      title: 'رياض الصالحين',
      subtitle: 'الكتب الدينية',
      presenterName: 'عبدالله الحكمي',
      category: 'الكتب الصوتية',
      url: _sampleAudioUrl,
      imageUrl:
          'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=640&q=85',
      rating: 4.9,
      description: 'مجموعة منتقاة من الأحاديث النبوية الشريفة.',
      durationText: '12:00:00',
      downloads: 8900,
      sourceType: AudioSourceType.audiobook,
    ),
  ];

  @override
  Future<List<AudioTrack>> fetchBooks() async => _books;

  @override
  Stream<List<AudioTrack>> watchBooks() => Stream.value(_books);
}
