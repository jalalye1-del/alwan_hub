import '../domain/models/audio_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// تعريف المزود ليتم استخدامه في جميع أنحاء التطبيق بأمان
final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  return const AudioRepository();
});

class AudioRepository {
  const AudioRepository();

  List<AudioItem> getByCategoryItem(
    String itemId, {
    String itemTitle = '',
    String trackItemLabel = 'أغنية',
  }) {
    switch (itemId) {
      case 'abubakr-salem':
      case 'abu_bakr_salem':
        return [
          const AudioItem(
            id: 'abubakr-salem-1',
            title: 'سر حبي',
            artist: 'أبوبكر سالم',
            audioUrl: '',
            artworkUrl: '',
            duration: Duration(minutes: 8, seconds: 12),
          ),
          const AudioItem(
            id: 'abubakr-salem-2',
            title: 'متى أنا أشوفك',
            artist: 'أبوبكر سالم',
            audioUrl: '',
            artworkUrl: '',
            duration: Duration(minutes: 6, seconds: 48),
          ),
        ];

      default:
        final ownerName = itemTitle
            .replaceFirst(
              RegExp(r'^(الفنانة?|المنشد|القارئ|برنامج|الشاعر/)\s*'),
              '',
            )
            .trim();
        return List<AudioItem>.generate(6, (index) {
          final number = index + 1;
          return AudioItem(
            id: '$itemId-$number',
            title: _trackTitle(trackItemLabel, number),
            artist: ownerName.isEmpty ? itemTitle : ownerName,
            audioUrl: '',
            artworkUrl: '',
            duration: Duration(
              minutes: 3 + (index % 5),
              seconds: (index * 11 + 9) % 60,
            ),
          );
        });
    }
  }

  String _trackTitle(String label, int number) {
    return switch (label) {
      'حلقة' => 'الحلقة $number',
      'تلاوة' => 'تلاوة مختارة $number',
      'أنشودة' => 'أنشودة مختارة $number',
      'مقطوعة' => 'مقطوعة موسيقية $number',
      'ملف' => 'الملف الصوتي $number',
      _ => 'أغنية مختارة $number',
    };
  }
}
