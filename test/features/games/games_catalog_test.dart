import 'package:alwan_hub/features/games/domain/games_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps dashboard programs with a dynamic question list', () {
    final programs = GamesCatalog.programsFromDashboard([
      {
        'id': 'dashboard-contest',
        'title': 'مسابقة لوحة التحكم',
        'sponsor': 'الراعي',
        'status': 'متاحة الآن',
        'description': 'وصف المسابقة',
        'color': '4281545706',
        'sponsorColor': '4287516130',
        'actions': ['طلب اشتراك بالبرنامج', 'تفعيل التذكير'],
        'contactLines': [
          {'label': 'Line 1', 'number': '777000000'},
        ],
        'enrollment': {
          'programDetails': 'تفاصيل البرنامج',
          'sponsors': 'الراعي',
          'targetAudience': 'الجميع',
          'prizeType': 'جائزة',
          'drawSchedule': 'الخميس',
          'conditions': ['شرط واحد'],
          'provinces': ['صنعاء'],
          'currentParticipants': 25,
          'correctAnswerPoints': 3,
          'wrongAnswerPoints': 1,
          'shareBonusPoints': 50,
          'sponsorOffer': {
            'title': 'عرض الراعي',
            'subtitle': 'وصف مختصر',
            'description': 'تفاصيل العرض',
            'promoCode': 'ALWAN10',
          },
          'questions': [
            {
              'id': 'q1',
              'question': 'السؤال الأول؟',
              'options': ['أ', 'ب'],
              'correctOptionIndex': 1,
            },
            {
              'id': 'q2',
              'question': 'السؤال الثاني؟',
              'options': ['ج', 'د', 'هـ'],
              'correctOptionIndex': 2,
            },
          ],
        },
      },
    ]);

    expect(programs, hasLength(1));
    expect(programs.single.contactLines.single.number, '777000000');
    expect(programs.single.enrollment!.questions, hasLength(2));
    expect(programs.single.enrollment!.questions.last.options, hasLength(3));
    expect(programs.single.enrollment!.correctAnswerPoints, 3);
    expect(programs.single.enrollment!.wrongAnswerPoints, 1);
  });

  test('serializes a registration payload for the dashboard API', () {
    final submittedAt = DateTime.utc(2026, 8, 7, 12, 30);
    final payload = CompetitionRegistration(
      programId: 'luck_box',
      fullName: 'محمد أحمد علي عبدالله',
      phoneNumber: '777123456',
      province: 'صنعاء',
      participantCount: 2,
      submittedAt: submittedAt,
    ).toDashboardJson();

    expect(payload['programId'], 'luck_box');
    expect(payload['participantCount'], 2);
    expect(payload['submittedAt'], submittedAt.toIso8601String());
  });

  test('maps dashboard challenge questions and leaderboard entries', () {
    final challenges = GamesCatalog.challengesFromDashboard([
      {
        'id': 'science',
        'title': 'تحدي العلوم',
        'category': 'العلوم والطبيعة',
        'description': 'تحد تجريبي',
        'inviteCode': 'ALWAN-TEST',
        'currentUserName': 'مستخدم ألوان',
        'currentUserPoints': 100,
        'weeklyTargetPoints': 500,
        'participants': [
          {'id': 'one', 'name': 'المتسابق الأول', 'points': 900},
        ],
        'questions': [
          {
            'id': 'q1',
            'question': 'سؤال؟',
            'options': ['أ', 'ب'],
            'correctOptionIndex': 0,
          },
        ],
      },
    ]);

    expect(challenges.single.questions, hasLength(1));
    expect(challenges.single.participants.single.points, 900);
    expect(challenges.single.pointsForCorrectAnswer, 3);
    expect(challenges.single.pointsForWrongAnswer, 1);
  });
}
