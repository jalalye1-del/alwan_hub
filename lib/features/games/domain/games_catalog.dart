import 'package:flutter/material.dart';

class CompetitionContactLine {
  const CompetitionContactLine({required this.label, required this.number});

  final String label;
  final String number;

  factory CompetitionContactLine.fromJson(Map<String, dynamic> json) {
    return CompetitionContactLine(
      label: json['label']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
    );
  }
}

class CompetitionQuestion {
  const CompetitionQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  factory CompetitionQuestion.fromJson(Map<String, dynamic> json) {
    final options = (json['options'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList();
    return CompetitionQuestion(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: options,
      correctOptionIndex:
          int.tryParse(json['correctOptionIndex']?.toString() ?? '') ?? 0,
    );
  }
}

class CompetitionSponsorOffer {
  const CompetitionSponsorOffer({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.promoCode,
  });

  final String title;
  final String subtitle;
  final String description;
  final String promoCode;

  factory CompetitionSponsorOffer.fromJson(Map<String, dynamic> json) {
    return CompetitionSponsorOffer(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      promoCode: json['promoCode']?.toString() ?? '',
    );
  }
}

class CompetitionEnrollment {
  const CompetitionEnrollment({
    required this.programDetails,
    required this.sponsors,
    required this.targetAudience,
    required this.prizeType,
    required this.drawSchedule,
    required this.conditions,
    required this.provinces,
    required this.questions,
    required this.currentParticipants,
    required this.sponsorOffer,
    this.correctAnswerPoints = 3,
    this.wrongAnswerPoints = 1,
    this.shareBonusPoints = 50,
  });

  final String programDetails;
  final String sponsors;
  final String targetAudience;
  final String prizeType;
  final String drawSchedule;
  final List<String> conditions;
  final List<String> provinces;
  final List<CompetitionQuestion> questions;
  final int currentParticipants;
  final CompetitionSponsorOffer sponsorOffer;
  final int correctAnswerPoints;
  final int wrongAnswerPoints;
  final int shareBonusPoints;

  factory CompetitionEnrollment.fromJson(Map<String, dynamic> json) {
    return CompetitionEnrollment(
      programDetails: json['programDetails']?.toString() ?? '',
      sponsors: json['sponsors']?.toString() ?? '',
      targetAudience: json['targetAudience']?.toString() ?? '',
      prizeType: json['prizeType']?.toString() ?? '',
      drawSchedule: json['drawSchedule']?.toString() ?? '',
      conditions: (json['conditions'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      provinces: (json['provinces'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      questions: (json['questions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CompetitionQuestion.fromJson)
          .toList(),
      currentParticipants:
          int.tryParse(json['currentParticipants']?.toString() ?? '') ?? 0,
      sponsorOffer: CompetitionSponsorOffer.fromJson(
        json['sponsorOffer'] as Map<String, dynamic>? ?? const {},
      ),
      correctAnswerPoints:
          int.tryParse(json['correctAnswerPoints']?.toString() ?? '') ?? 3,
      wrongAnswerPoints:
          int.tryParse(json['wrongAnswerPoints']?.toString() ?? '') ?? 1,
      shareBonusPoints:
          int.tryParse(json['shareBonusPoints']?.toString() ?? '') ?? 50,
    );
  }
}

class CompetitionRegistration {
  const CompetitionRegistration({
    required this.programId,
    required this.fullName,
    required this.phoneNumber,
    required this.province,
    required this.participantCount,
    required this.submittedAt,
  });

  final String programId;
  final String fullName;
  final String phoneNumber;
  final String province;
  final int participantCount;
  final DateTime submittedAt;

  Map<String, dynamic> toDashboardJson() => {
    'programId': programId,
    'fullName': fullName,
    'phoneNumber': phoneNumber,
    'province': province,
    'participantCount': participantCount,
    'submittedAt': submittedAt.toIso8601String(),
  };
}

class CompetitionProgram {
  const CompetitionProgram({
    required this.id,
    required this.title,
    required this.sponsor,
    required this.status,
    required this.description,
    required this.color,
    required this.sponsorColor,
    required this.actions,
    this.contactLines = const [],
    this.enrollment,
  });

  final String id;
  final String title;
  final String sponsor;
  final String status;
  final String description;
  final Color color;
  final Color sponsorColor;
  final List<String> actions;
  final List<CompetitionContactLine> contactLines;
  final CompetitionEnrollment? enrollment;

  factory CompetitionProgram.fromDashboard(Map<String, dynamic> json) {
    return CompetitionProgram(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      sponsor: json['sponsor']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      color: Color(int.tryParse(json['color']?.toString() ?? '') ?? 0xFF334FEA),
      sponsorColor: Color(
        int.tryParse(json['sponsorColor']?.toString() ?? '') ?? 0xFF8E2DE2,
      ),
      actions: (json['actions'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      contactLines: (json['contactLines'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CompetitionContactLine.fromJson)
          .toList(),
      enrollment: json['enrollment'] is Map<String, dynamic>
          ? CompetitionEnrollment.fromJson(
              json['enrollment'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class ChallengeParticipant {
  const ChallengeParticipant({
    required this.id,
    required this.name,
    required this.points,
    this.isOnline = true,
  });

  final String id;
  final String name;
  final int points;
  final bool isOnline;

  factory ChallengeParticipant.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      points: int.tryParse(json['points']?.toString() ?? '') ?? 0,
      isOnline: json['isOnline'] != false,
    );
  }
}

class QuizChallenge {
  const QuizChallenge({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.inviteCode,
    required this.currentUserName,
    required this.currentUserPoints,
    required this.weeklyTargetPoints,
    required this.participants,
    required this.questions,
    this.pointsForCorrectAnswer = 3,
    this.pointsForWrongAnswer = 1,
  });

  final String id;
  final String title;
  final String category;
  final String description;
  final String inviteCode;
  final String currentUserName;
  final int currentUserPoints;
  final int weeklyTargetPoints;
  final List<ChallengeParticipant> participants;
  final List<CompetitionQuestion> questions;
  final int pointsForCorrectAnswer;
  final int pointsForWrongAnswer;

  factory QuizChallenge.fromDashboard(Map<String, dynamic> json) {
    return QuizChallenge(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      inviteCode: json['inviteCode']?.toString() ?? '',
      currentUserName: json['currentUserName']?.toString() ?? 'مستخدم ألوان',
      currentUserPoints:
          int.tryParse(json['currentUserPoints']?.toString() ?? '') ?? 0,
      weeklyTargetPoints:
          int.tryParse(json['weeklyTargetPoints']?.toString() ?? '') ?? 500,
      participants: (json['participants'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ChallengeParticipant.fromJson)
          .toList(growable: false),
      questions: (json['questions'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CompetitionQuestion.fromJson)
          .toList(growable: false),
      pointsForCorrectAnswer:
          int.tryParse(json['pointsForCorrectAnswer']?.toString() ?? '') ?? 3,
      pointsForWrongAnswer:
          int.tryParse(json['pointsForWrongAnswer']?.toString() ?? '') ?? 1,
    );
  }
}

class EntertainmentGame {
  const EntertainmentGame({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    this.mode = 'لعب مباشر',
    this.rewardPoints = 30,
    this.estimatedMinutes = 3,
  });

  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final String mode;
  final int rewardPoints;
  final int estimatedMinutes;
}

abstract final class GamesCatalog {
  static const liveStreamUrl = 'https://s9.voscast.com:9617/stream';

  /// A dashboard response can be mapped with this method without changing UI.
  static List<CompetitionProgram> programsFromDashboard(
    List<Map<String, dynamic>> payload,
  ) => payload.map(CompetitionProgram.fromDashboard).toList();

  /// Maps dashboard-managed challenges, including any number of questions.
  static List<QuizChallenge> challengesFromDashboard(
    List<Map<String, dynamic>> payload,
  ) => payload.map(QuizChallenge.fromDashboard).toList(growable: false);

  static const programs = <CompetitionProgram>[
    CompetitionProgram(
      id: 'echo_letters',
      title: 'برنامج صدى الحروف',
      sponsor: 'برعاية شركة يمن موبايل',
      status: 'مباشر الآن',
      description:
          'شارك مباشرة بالاتصال الهاتفي وأجب عن الأحرف الذهبية لتفوز بجوائز نقدية كبرى فورية وهدايا قيمة.',
      color: Color(0xFF3159D9),
      sponsorColor: Color(0xFF8E2DE2),
      actions: ['اتصل للمشاركة', 'استمع للبث'],
      contactLines: [
        CompetitionContactLine(label: 'Line 1', number: '772277800'),
        CompetitionContactLine(label: 'Line 2', number: '772277900'),
        CompetitionContactLine(label: 'Line 3', number: '733887887'),
      ],
    ),
    CompetitionProgram(
      id: 'luck_box',
      title: 'برنامج صندوق الحظ',
      sponsor: 'برعاية كاك بنك الإسلامي',
      status: 'يبدأ 8:00 مساءً',
      description:
          'افتح الصناديق الغامضة على الهواء مباشرة! اختر الصندوق الذهبي أو الفضي أو البرونزي وأجب عن السؤال المشوق واكسب الجائزة.',
      color: Color(0xFF8E2DE2),
      sponsorColor: Color(0xFF334FEA),
      actions: ['طلب اشتراك بالبرنامج', 'تفعيل التذكير'],
      enrollment: CompetitionEnrollment(
        programDetails: 'تقديم فكرة مشروع ريادي',
        sponsors: 'شاي الكبوس ورعاة آخرون',
        targetAudience: 'الشباب والمبدعون',
        prizeType: 'تمويل ودعم مشاريع ريادية',
        drawSchedule: 'أسبوعياً كل خميس',
        conditions: [
          'أن يكون عمر المتقدم بين 18 و35 سنة',
          'تقديم دراسة جدوى مبسطة للمشروع',
          'الالتزام بمتطلبات التدريب والتأهيل',
        ],
        provinces: ['أمانة العاصمة', 'صنعاء', 'عدن', 'تعز', 'الحديدة'],
        currentParticipants: 14350,
        correctAnswerPoints: 3,
        wrongAnswerPoints: 1,
        shareBonusPoints: 50,
        sponsorOffer: CompetitionSponsorOffer(
          title: 'شاي الكبوس',
          subtitle: 'شاي طبيعي 100% من مذاق يمني أصيل',
          description:
              'اشترِ عبوتين من شاي الكبوس الفاخر 250جم واحصل على كوب زجاجي مجاناً.',
          promoCode: 'ALWAN10',
        ),
        questions: [
          CompetitionQuestion(
            id: 'frequency',
            question: 'ما هو التردد الرئيسي لإذاعة ألوان FM في اليمن؟',
            options: ['99.9 MHz', '91.5 MHz', '101.5 MHz', '88.1 MHz'],
            correctOptionIndex: 3,
          ),
          CompetitionQuestion(
            id: 'brand_frequency',
            question: 'ما هو التردد المكتوب في شعار إذاعة ألوان؟',
            options: ['88.7 FM', '90.1 FM', '95.5 FM', '100.7 FM'],
            correctOptionIndex: 0,
          ),
          CompetitionQuestion(
            id: 'live_program',
            question: 'أي برنامج يتيح المشاركة بالاتصال المباشر؟',
            options: ['صدى الحروف', 'ألوان الليلة', 'صندوق الحظ', 'شعر وحنين'],
            correctOptionIndex: 0,
          ),
          CompetitionQuestion(
            id: 'points',
            question: 'كم نقطة تحصل عليها عند الإجابة الصحيحة؟',
            options: ['نقطة واحدة', 'نقطتان', 'ثلاث نقاط', 'خمس نقاط'],
            correctOptionIndex: 2,
          ),
          CompetitionQuestion(
            id: 'draw_day',
            question: 'في أي يوم يقام السحب الأسبوعي للبرنامج؟',
            options: ['السبت', 'الإثنين', 'الخميس', 'الجمعة'],
            correctOptionIndex: 2,
          ),
        ],
      ),
    ),
    CompetitionProgram(
      id: 'alwan_tonight',
      title: 'برنامج ألوان الليلة',
      sponsor: 'برعاية مجموعة بن هايل التجارية',
      status: 'قريباً',
      description:
          'أكبر سهرة مسابقات رمضانية متنوعة وتحديات فورية على راديو ألوان FM. أسئلة فنية وثقافية واجتماعية وهدايا قيمة للجميع.',
      color: Color(0xFF334FEA),
      sponsorColor: Color(0xFF8E2DE2),
      actions: ['عرض التفاصيل', 'ذكرني'],
    ),
  ];

  static const challengeParticipants = <ChallengeParticipant>[
    ChallengeParticipant(id: 'mohammed', name: 'مروان الحاشدي', points: 9800),
    ChallengeParticipant(id: 'abir', name: 'عبير صالح', points: 7650),
    ChallengeParticipant(id: 'jamal', name: 'جمال اليافعي', points: 6500),
    ChallengeParticipant(id: 'sarah', name: 'سارة عمار', points: 5850),
    ChallengeParticipant(id: 'waleed', name: 'وليد خالد', points: 5300),
    ChallengeParticipant(id: 'nabil', name: 'نبيل العريقي', points: 4950),
  ];

  static const sinJimChallenges = <QuizChallenge>[
    QuizChallenge(
      id: 'history_geography',
      title: 'تحدي التاريخ والجغرافيا',
      category: 'التاريخ والجغرافيا',
      description: 'اختبر معلوماتك في الحضارات والبلدان والمعالم والجغرافيا.',
      inviteCode: 'ALWAN-HG-7945',
      currentUserName: 'ياسمين الأصبحي',
      currentUserPoints: 2750,
      weeklyTargetPoints: 4500,
      participants: challengeParticipants,
      questions: [
        CompetitionQuestion(
          id: 'hg-1',
          question: 'ما عاصمة الجمهورية اليمنية؟',
          options: ['صنعاء', 'عدن', 'تعز', 'الحديدة'],
          correctOptionIndex: 0,
        ),
        CompetitionQuestion(
          id: 'hg-2',
          question: 'في أي قارة تقع الأرجنتين؟',
          options: ['آسيا', 'أوروبا', 'أمريكا الجنوبية', 'أفريقيا'],
          correctOptionIndex: 2,
        ),
        CompetitionQuestion(
          id: 'hg-3',
          question: 'أي حضارة بنت مدينة مأرب القديمة؟',
          options: ['سبأ', 'الرومان', 'الفراعنة', 'الأنباط'],
          correctOptionIndex: 0,
        ),
      ],
    ),
    QuizChallenge(
      id: 'science_nature',
      title: 'تحدي العلوم والطبيعة',
      category: 'العلوم والطبيعة',
      description: 'أسئلة ممتعة عن جسم الإنسان والطاقة والكائنات والطبيعة.',
      inviteCode: 'ALWAN-SN-4821',
      currentUserName: 'ياسمين الأصبحي',
      currentUserPoints: 2750,
      weeklyTargetPoints: 4500,
      participants: challengeParticipants,
      questions: [
        CompetitionQuestion(
          id: 'sn-1',
          question: 'ما الكوكب المعروف بالكوكب الأحمر؟',
          options: ['الزهرة', 'المريخ', 'عطارد', 'المشتري'],
          correctOptionIndex: 1,
        ),
        CompetitionQuestion(
          id: 'sn-2',
          question: 'ما الغاز الذي تمتصه النباتات من الهواء؟',
          options: ['الأكسجين', 'الهيدروجين', 'ثاني أكسيد الكربون', 'الهيليوم'],
          correctOptionIndex: 2,
        ),
        CompetitionQuestion(
          id: 'sn-3',
          question: 'كم عدد حجرات قلب الإنسان؟',
          options: ['اثنتان', 'ثلاث', 'أربع', 'خمس'],
          correctOptionIndex: 2,
        ),
      ],
    ),
    QuizChallenge(
      id: 'religion_languages',
      title: 'تحدي الدين واللغات',
      category: 'الدين واللغات',
      description: 'معرفة عامة في القيم الإسلامية واللغة العربية ولغات العالم.',
      inviteCode: 'ALWAN-RL-6503',
      currentUserName: 'ياسمين الأصبحي',
      currentUserPoints: 2750,
      weeklyTargetPoints: 4500,
      participants: challengeParticipants,
      questions: [
        CompetitionQuestion(
          id: 'rl-1',
          question: 'كم عدد أركان الإسلام؟',
          options: ['أربعة', 'خمسة', 'ستة', 'سبعة'],
          correctOptionIndex: 1,
        ),
        CompetitionQuestion(
          id: 'rl-2',
          question: 'ما جمع كلمة كتاب؟',
          options: ['كتابات', 'كتبة', 'كتب', 'مكاتب'],
          correctOptionIndex: 2,
        ),
        CompetitionQuestion(
          id: 'rl-3',
          question: 'أي لغة هي الأكثر انتشاراً في أمريكا الجنوبية؟',
          options: ['العربية', 'الإسبانية', 'الألمانية', 'اليابانية'],
          correctOptionIndex: 1,
        ),
      ],
    ),
    QuizChallenge(
      id: 'arts_sports',
      title: 'تحدي الفنون والرياضة',
      category: 'الفنون والرياضة',
      description:
          'جولة سريعة في الموسيقى والسينما والفنون والبطولات الرياضية.',
      inviteCode: 'ALWAN-AS-3187',
      currentUserName: 'ياسمين الأصبحي',
      currentUserPoints: 2750,
      weeklyTargetPoints: 4500,
      participants: challengeParticipants,
      questions: [
        CompetitionQuestion(
          id: 'as-1',
          question: 'كم لاعباً يشارك في فريق كرة القدم داخل الملعب؟',
          options: ['تسعة', 'عشرة', 'أحد عشر', 'اثنا عشر'],
          correctOptionIndex: 2,
        ),
        CompetitionQuestion(
          id: 'as-2',
          question: 'أي آلة موسيقية تحتوي عادةً على مفاتيح سوداء وبيضاء؟',
          options: ['العود', 'البيانو', 'الناي', 'الكمان'],
          correctOptionIndex: 1,
        ),
        CompetitionQuestion(
          id: 'as-3',
          question: 'كل كم سنة تقام دورة الألعاب الأولمبية الصيفية؟',
          options: ['سنتين', 'ثلاث سنوات', 'أربع سنوات', 'خمس سنوات'],
          correctOptionIndex: 2,
        ),
      ],
    ),
  ];

  static const culturalChallenge = QuizChallenge(
    id: 'general_culture',
    title: 'المسابقة الثقافية',
    category: 'المعلومات العامة',
    description: 'تحدٍ ثقافي عام يجمع المعرفة والسرعة وروح المنافسة.',
    inviteCode: 'ALWAN-QA-7945',
    currentUserName: 'ياسمين الأصبحي',
    currentUserPoints: 2750,
    weeklyTargetPoints: 4500,
    participants: challengeParticipants,
    questions: [
      CompetitionQuestion(
        id: 'gc-1',
        question: 'ما أكبر محيط على سطح الأرض؟',
        options: ['الأطلسي', 'الهندي', 'الهادئ', 'المتجمد الشمالي'],
        correctOptionIndex: 2,
      ),
      CompetitionQuestion(
        id: 'gc-2',
        question: 'من مؤلف رواية البؤساء؟',
        options: ['فيكتور هوغو', 'نجيب محفوظ', 'تولستوي', 'طه حسين'],
        correctOptionIndex: 0,
      ),
      CompetitionQuestion(
        id: 'gc-3',
        question: 'كم لوناً يتكون منها قوس قزح؟',
        options: ['خمسة', 'ستة', 'سبعة', 'ثمانية'],
        correctOptionIndex: 2,
      ),
    ],
  );

  static const games = <EntertainmentGame>[
    EntertainmentGame(
      id: 'memory_match',
      title: 'لعبة مطابقة الذاكرة',
      subtitle: 'طابق بطاقات الأيقونات المتشابهة بأقل عدد من الحركات',
      color: Color(0xFF8E2DE2),
      mode: 'فردي وتحدي صديق',
      rewardPoints: 40,
      estimatedMinutes: 3,
    ),
    EntertainmentGame(
      id: 'tic_tac_toe',
      title: 'لعبة إكس أو التفاعلية',
      subtitle: 'تحدَّ الذكاء الاصطناعي أو صديقاً في اللعبة الشهيرة',
      color: Color(0xFF334FEA),
      mode: 'ضد الذكاء أو صديق',
      rewardPoints: 35,
      estimatedMinutes: 2,
    ),
    EntertainmentGame(
      id: 'word_guess',
      title: 'تخمين الكلمات والبرامج',
      subtitle: 'رتّب الأحرف لتخمين أسماء برامج ومذيعي ألوان',
      color: Color(0xFF5B4BE7),
      mode: 'جولات فردية',
      rewardPoints: 30,
      estimatedMinutes: 4,
    ),
  ];
}
