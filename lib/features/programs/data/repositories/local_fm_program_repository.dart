import 'package:alwan_hub/features/programs/domain/entities/fm_program.dart';
import 'package:alwan_hub/features/programs/domain/repositories/fm_program_repository.dart';

/// Local dashboard-shaped seed used until the remote repository is injected.
class LocalFmProgramRepository implements FmProgramRepository {
  const LocalFmProgramRepository();

  static const _streamUrl = 'https://s9.voscast.com:9617/stream';

  static final _dashboardSeed = <Map<String, dynamic>>[
    {
      'id': 'alwan-podcast',
      'title': 'بودكاست ألوان',
      'description':
          'حوارات ملهمة مع ضيوف من مختلف المجالات لمشاركة الأفكار والخبرات المهمة.',
      'presenterName': 'تقديم: أفنان خالد',
      'liveTime': '01:00 PM',
      'liveEndTime': '02:00 PM',
      'replayTimes': ['10:30 PM', '03:30 AM'],
      'broadcastSlots': [
        {'day': 'السبت', 'time': '01:00 PM'},
        {'day': 'الإثنين', 'time': '01:00 PM'},
        {'day': 'الجمعة', 'time': '01:00 PM'},
      ],
      'replaySlots': [
        {'day': 'الأحد', 'time': '10:30 PM'},
        {'day': 'الثلاثاء', 'time': '10:30 PM'},
      ],
      'imageUrl':
          'https://images.unsplash.com/photo-1590602847861-f357a9332bbc?auto=format&fit=crop&w=500&q=85',
      'streamUrl': _streamUrl,
      'accentColor': '#4A35E8',
      'broadcastDays': [0, 2, 5],
      'conversationTitle': 'حلقة اليوم: مساحة الأفكار',
      'broadcastType': 'live',
      'isLive': true,
      'sortOrder': 0,
    },
    {
      'id': 'alwan-doctor',
      'title': 'طبيب ألوان',
      'description':
          'نصائح طبية موثوقة وأجوبة وإرشادات مع نخبة من الأطباء والمتخصصين.',
      'presenterName': 'تقديم: د. مرام البعداني',
      'liveTime': '04:00 PM',
      'liveEndTime': '05:00 PM',
      'replayTimes': ['01:00 AM', '06:00 AM'],
      'broadcastSlots': [
        {'day': 'الأحد', 'time': '04:00 PM'},
        {'day': 'الخميس', 'time': '04:00 PM'},
      ],
      'replaySlots': [
        {'day': 'الإثنين', 'time': '01:00 AM'},
        {'day': 'الجمعة', 'time': '06:00 AM'},
      ],
      'imageUrl':
          'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?auto=format&fit=crop&w=500&q=85',
      'streamUrl': _streamUrl,
      'accentColor': '#3159D9',
      'broadcastDays': [1, 4],
      'conversationTitle': 'استشارات طبية مباشرة',
      'broadcastType': 'recorded',
      'sortOrder': 1,
    },
    {
      'id': 'poetry-and-nostalgia',
      'title': 'شعر وحنين',
      'description':
          'أجمل القصائد والأغاني المختارة من تراثنا العربي الأصيل بصوت إذاعات مميزة.',
      'presenterName': 'تقديم: نزار القدسي',
      'liveTime': '07:00 PM',
      'liveEndTime': '08:00 PM',
      'replayTimes': ['04:00 AM', '11:00 AM'],
      'broadcastSlots': [
        {'day': 'الإثنين', 'time': '07:00 PM'},
        {'day': 'الجمعة', 'time': '07:00 PM'},
      ],
      'replaySlots': [
        {'day': 'الثلاثاء', 'time': '04:00 AM'},
        {'day': 'السبت', 'time': '11:00 AM'},
      ],
      'imageUrl':
          'https://images.unsplash.com/photo-1455390582262-044cdead277a?auto=format&fit=crop&w=500&q=85',
      'streamUrl': _streamUrl,
      'accentColor': '#C77A18',
      'broadcastDays': [2, 5],
      'conversationTitle': 'مختارات شعرية',
      'broadcastType': 'recorded',
      'sortOrder': 2,
    },
    {
      'id': 'good-sermon',
      'title': 'موعظة حسنة',
      'description':
          'خواطر إيمانية وقيم نبيلة من القرآن والسنة في حياتنا اليومية.',
      'presenterName': 'تقديم: د. عبدالرحمن الجرموزي',
      'liveTime': '09:00 PM',
      'liveEndTime': '10:00 PM',
      'replayTimes': ['06:00 AM', '02:00 PM'],
      'broadcastSlots': [
        {'day': 'الثلاثاء', 'time': '09:00 PM'},
      ],
      'replaySlots': [
        {'day': 'الأربعاء', 'time': '06:00 AM'},
        {'day': 'الخميس', 'time': '02:00 PM'},
      ],
      'imageUrl':
          'https://images.unsplash.com/photo-1609599006353-e629aaabfeae?auto=format&fit=crop&w=500&q=85',
      'streamUrl': _streamUrl,
      'accentColor': '#0C8E83',
      'broadcastDays': [3],
      'conversationTitle': 'رسالة اليوم',
      'broadcastType': 'recorded',
      'sortOrder': 3,
    },
  ];

  List<FmProgram> _programs() {
    final programs = _dashboardSeed
        .map(FmProgram.fromDashboardMap)
        .where((program) => program.isPublished)
        .toList(growable: false);
    return [...programs]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<List<FmProgram>> fetchPrograms() async => _programs();

  @override
  Stream<List<FmProgram>> watchPrograms() => Stream.value(_programs());
}
