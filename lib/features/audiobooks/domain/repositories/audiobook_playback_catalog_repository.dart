import 'package:alwan_hub/core/audio/models/audio_track.dart';

/// مصدر قائمة الكتب التي يمكن تشغيلها من مشغل ألوان الموحد.
///
/// يبقى هذا العقد مستقلًا عن مزود لوحة التحكم، لذلك يمكن استبدال البيانات
/// التجريبية بواجهة API دون تغيير واجهة الكتب أو المشغل.
abstract interface class AudiobookPlaybackCatalogRepository {
  Future<List<AudioTrack>> fetchBooks();

  Stream<List<AudioTrack>> watchBooks();
}
