import 'package:alwan_hub/core/content/models/managed_content.dart';
import 'package:alwan_hub/core/content/models/managed_media.dart';
import 'package:alwan_hub/core/content/repositories/content_repository.dart';
import 'package:alwan_hub/features/programs/data/repositories/dashboard_fm_program_repository.dart';
import 'package:alwan_hub/features/programs/domain/entities/fm_program.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps the FM dashboard payload including schedule and live state', () {
    final program = FmProgram.fromDashboardMap({
      'id': 'dashboard-live',
      'title': 'برنامج لوحة التحكم',
      'description': 'وصف البرنامج',
      'presenterName': 'تقديم: مذيع ألوان',
      'liveTime': '05:00 PM',
      'liveEndTime': '06:00 PM',
      'replayTimes': ['11:00 PM', '04:00 AM'],
      'broadcastSlots': [
        {'day': 'السبت', 'time': '05:00 PM'},
      ],
      'replaySlots': [
        {'day': 'الأحد', 'time': '11:00 PM'},
      ],
      'imageUrl': 'assets/images/program.jpg',
      'streamUrl': 'https://example.com/live',
      'accentColor': '#334FEA',
      'broadcastDays': [0, 3],
      'broadcastType': 'live',
      'sortOrder': 2,
    });

    expect(program.title, 'برنامج لوحة التحكم');
    expect(program.broadcastTimeLabel, '05:00 PM - 06:00 PM');
    expect(program.replayTimes, ['11:00 PM', '04:00 AM']);
    expect(program.broadcastSlots.single.dayLabel, 'السبت');
    expect(program.broadcastSlots.single.time, '05:00 PM');
    expect(program.replaySlots.single.dayLabel, 'الأحد');
    expect(program.airsOn(0), isTrue);
    expect(program.airsOn(1), isFalse);
    expect(program.isLive, isTrue);
    expect(program.toDashboardMap()['broadcastType'], 'live');
  });

  test('maps a recorded dashboard selection into the program status', () {
    final program = FmProgram.fromDashboardMap({
      'id': 'dashboard-recorded',
      'title': 'برنامج مسجل',
      'broadcastType': 'recorded',
      'isLive': true,
    });

    expect(program.isLive, isFalse);
    expect(program.toDashboardMap()['broadcastType'], 'recorded');
  });

  test('connects managed dashboard content to the FM repository', () async {
    final managed = ManagedContent(
      id: 'managed-live',
      type: 'fm_program',
      title: 'برنامج مُدار',
      subtitle: 'تقديم: أفنان',
      description: 'بيانات من لوحة التحكم',
      sortOrder: 1,
      media: const [
        ManagedMedia(
          id: 'cover',
          type: ManagedMediaType.image,
          url: 'assets/images/program.jpg',
        ),
        ManagedMedia(
          id: 'stream',
          type: ManagedMediaType.liveStream,
          url: 'https://example.com/live',
        ),
      ],
      metadata: const {
        'liveTime': '01:00 PM',
        'replayTimes': ['10:00 PM'],
        'broadcastDays': [0],
        'broadcastType': 'live',
      },
    );
    final repository = DashboardFmProgramRepository(
      _FakeContentRepository([managed]),
    );

    final programs = await repository.fetchPrograms();

    expect(programs.single.title, 'برنامج مُدار');
    expect(programs.single.presenterName, 'تقديم: أفنان');
    expect(programs.single.streamUrl, 'https://example.com/live');
    expect(programs.single.isLive, isTrue);
  });
}

class _FakeContentRepository implements ContentRepository {
  const _FakeContentRepository(this.items);

  final List<ManagedContent> items;

  @override
  Future<ManagedContent?> fetchById(String id) async {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<List<ManagedContent>> fetchPublished({String? type}) async => items;

  @override
  Stream<List<ManagedContent>> watchPublished({String? type}) {
    return Stream.value(items);
  }
}
