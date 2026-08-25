import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/features/games/data/challenge_invitation_service.dart';
import 'package:alwan_hub/features/games/domain/games_catalog.dart';
import 'package:alwan_hub/features/games/presentation/widgets/challenge_live_chat.dart';

const _font = 'MohammadBoldArt';
const _page = Color(0xFFF8FAFF);
const _surface = Colors.white;
const _ink = Color(0xFF17164F);
const _blue = Color(0xFF334FEA);
const _purple = Color(0xFF8E2DE2);
const _muted = Color(0xFF73788F);
const _line = Color(0xFFE4E7F3);

class QuizChallengeScreen extends StatefulWidget {
  const QuizChallengeScreen({super.key, required this.challenge});

  final QuizChallenge challenge;

  @override
  State<QuizChallengeScreen> createState() => _QuizChallengeScreenState();
}

class _QuizChallengeScreenState extends State<QuizChallengeScreen> {
  final ChallengeInvitationService _invitationService =
      ChallengeInvitationService();
  late int _currentUserPoints;
  late List<ChallengeParticipant> _participants;
  bool _notificationQueued = false;

  QuizChallenge get _challenge => widget.challenge;

  @override
  void initState() {
    super.initState();
    _currentUserPoints = _challenge.currentUserPoints;
    _participants = List.of(_challenge.participants);
  }

  List<ChallengeParticipant> get _leaderboard {
    final entries = <ChallengeParticipant>[
      ..._participants.where((entry) => entry.id != 'current-user'),
      ChallengeParticipant(
        id: 'current-user',
        name: _challenge.currentUserName,
        points: _currentUserPoints,
      ),
    ]..sort((a, b) => b.points.compareTo(a.points));
    return entries;
  }

  String get _invitationText =>
      'أتحداك في ${_challenge.title} على تطبيق ألوان! '
      'استخدم رمز الدعوة: ${_challenge.inviteCode}';

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: _font,
              fontWeight: FontWeight.w700,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _startChallenge() async {
    if (_challenge.questions.isEmpty) {
      _showMessage('سيتم نشر أسئلة التحدي قريباً');
      return;
    }
    final earnedPoints = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => ChallengeQuestionsScreen(challenge: _challenge),
      ),
    );
    if (!mounted || earnedPoints == null) return;
    setState(() => _currentUserPoints += earnedPoints);
    _showMessage('أضيفت $earnedPoints نقطة إلى رصيدك في التحدي');
  }

  Future<void> _queueGroupNotification() async {
    try {
      await _invitationService.queueGroupNotification(
        challengeId: _challenge.id,
        challengeTitle: _challenge.title,
        inviteCode: _challenge.inviteCode,
      );
      if (!mounted) return;
      setState(() => _notificationQueued = true);
      _showMessage('تمت إضافة الإشعار الجماعي إلى قائمة إرسال لوحة التحكم');
    } catch (_) {
      if (mounted) _showMessage('تعذر تجهيز الإشعار الجماعي، حاول مرة أخرى');
    }
  }

  Future<void> _sendWhatsApp() async {
    final opened = await _invitationService.sendWhatsApp(_invitationText);
    if (mounted && !opened) {
      _showMessage('تعذر فتح واتساب على هذا الجهاز');
    }
  }

  Future<void> _sendSms() async {
    final opened = await _invitationService.sendSms(_invitationText);
    if (mounted && !opened) {
      _showMessage('تعذر فتح تطبيق الرسائل على هذا الجهاز');
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaderboard = _leaderboard;
    final champion = leaderboard.first;
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: _font),
      ),
      child: Scaffold(
        backgroundColor: _page,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'العودة',
            icon: const Icon(Icons.arrow_back_rounded, color: _blue),
          ),
          title: Text(
            _challenge.title,
            style: const TextStyle(
              fontFamily: _font,
              color: _ink,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 48),
            child: ResponsiveContent(
              maxWidth: 680,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 14),
                  const _ChallengeAdBanner(),
                  Padding(
                    padding: context.responsive.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 18),
                        _ChallengeIntroCard(
                          challenge: _challenge,
                          onStart: _startChallenge,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 156,
                          child: _ChampionCard(champion: champion),
                        ),
                        const SizedBox(height: 14),
                        _ProgressCard(
                          points: _currentUserPoints,
                          target: _challenge.weeklyTargetPoints,
                        ),
                        const SizedBox(height: 14),
                        _ParticipantsCard(participants: _participants),
                        const SizedBox(height: 14),
                        _LeaderboardCard(entries: leaderboard.take(5).toList()),
                        const SizedBox(height: 14),
                        _InvitationCard(
                          code: _challenge.inviteCode,
                          notificationQueued: _notificationQueued,
                          onNotification: _queueGroupNotification,
                          onSms: _sendSms,
                          onWhatsApp: _sendWhatsApp,
                        ),
                        const SizedBox(height: 14),
                        ChallengeLiveChatCard(
                          roomId: _challenge.id,
                          currentUserName: _challenge.currentUserName,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChallengeQuestionsScreen extends StatefulWidget {
  const ChallengeQuestionsScreen({super.key, required this.challenge});

  final QuizChallenge challenge;

  @override
  State<ChallengeQuestionsScreen> createState() =>
      _ChallengeQuestionsScreenState();
}

class _ChallengeQuestionsScreenState extends State<ChallengeQuestionsScreen> {
  int _questionIndex = 0;
  int _earnedPoints = 0;
  int? _selectedOption;

  CompetitionQuestion get _question =>
      widget.challenge.questions[_questionIndex];

  void _select(int index) {
    if (_selectedOption != null) return;
    final correct = index == _question.correctOptionIndex;
    setState(() {
      _selectedOption = index;
      _earnedPoints += correct
          ? widget.challenge.pointsForCorrectAnswer
          : widget.challenge.pointsForWrongAnswer;
    });
  }

  Future<void> _next() async {
    if (_selectedOption == null) return;
    if (_questionIndex < widget.challenge.questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedOption = null;
      });
      return;
    }
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        icon: const Icon(Icons.emoji_events_rounded, color: _purple, size: 48),
        title: const Text(
          'انتهى التحدي',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: _font, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'حصلت على $_earnedPoints نقطة في هذه الجولة.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: _font, color: _muted),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: FilledButton.styleFrom(backgroundColor: _blue),
            child: const Text(
              'عرض الترتيب',
              style: TextStyle(fontFamily: _font, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context, _earnedPoints);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _questionIndex == widget.challenge.questions.length - 1;
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          'السؤال ${_questionIndex + 1} من ${widget.challenge.questions.length}',
          style: const TextStyle(
            fontFamily: _font,
            color: _ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 620,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_questionIndex + 1) / widget.challenge.questions.length,
                minHeight: 7,
                borderRadius: BorderRadius.circular(20),
                color: _purple,
                backgroundColor: const Color(0xFFE9EAF5),
              ),
              const SizedBox(height: 28),
              Text(
                _question.question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: _font,
                  color: _ink,
                  fontSize: 24,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 22),
              for (var index = 0; index < _question.options.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 11),
                  child: _QuestionOption(
                    number: index + 1,
                    label: _question.options[index],
                    selected: _selectedOption == index,
                    correct:
                        _selectedOption != null &&
                        index == _question.correctOptionIndex,
                    wrong:
                        _selectedOption == index &&
                        index != _question.correctOptionIndex,
                    onTap: () => _select(index),
                  ),
                ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _selectedOption == null ? null : _next,
                icon: Icon(
                  isLast ? Icons.emoji_events_rounded : Icons.arrow_forward,
                ),
                label: Text(isLast ? 'إنهاء التحدي' : 'السؤال التالي'),
                style: FilledButton.styleFrom(
                  backgroundColor: _blue,
                  disabledBackgroundColor: const Color(0xFFD8DBE8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontFamily: _font,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeAdBanner extends StatelessWidget {
  const _ChallengeAdBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsive.pagePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: Image.asset(
                'assets/images/banners/banner1.jpg',
                fit: BoxFit.cover,
                semanticLabel: 'بنر إعلاني',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChallengeIntroCard extends StatelessWidget {
  const _ChallengeIntroCard({required this.challenge, required this.onStart});

  final QuizChallenge challenge;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.public_rounded, color: _blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.category,
                      style: const TextStyle(
                        fontFamily: _font,
                        color: _ink,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      challenge.description,
                      style: const TextStyle(
                        fontFamily: _font,
                        color: _muted,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.bolt_rounded),
            label: const Text('ابدأ التحدي الفردي'),
            style: FilledButton.styleFrom(
              backgroundColor: _purple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                fontFamily: _font,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChampionCard extends StatelessWidget {
  const _ChampionCard({required this.champion});

  final ChallengeParticipant champion;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFFFD45C);
    return Semantics(
      label: 'بطاقة متصدر التحدي المميزة',
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF17164F), _blue, _purple],
            stops: [0, .55, 1],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: gold.withValues(alpha: .3),
              blurRadius: 26,
              spreadRadius: 1,
              offset: const Offset(0, 11),
            ),
            BoxShadow(
              color: _purple.withValues(alpha: .22),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              end: -34,
              top: -52,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      gold.withValues(alpha: .26),
                      gold.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 18,
              top: 12,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: gold.withValues(alpha: .8),
                size: 19,
              ),
            ),
            PositionedDirectional(
              end: 12,
              bottom: 10,
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withValues(alpha: .23),
                size: 31,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .14),
                          shape: BoxShape.circle,
                          border: Border.all(color: gold, width: 2.2),
                          boxShadow: [
                            BoxShadow(
                              color: gold.withValues(alpha: .36),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const Positioned(
                        top: -19,
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: gold,
                          size: 40,
                        ),
                      ),
                      Positioned(
                        bottom: -5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '#1',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              fontFamily: _font,
                              color: _ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 17),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'متصدر التحدي هذا الأسبوع',
                          style: TextStyle(
                            fontFamily: _font,
                            color: gold,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          champion.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: _font,
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: .18),
                            ),
                          ),
                          child: Text(
                            '${champion.points} XP  •  بطل ألوان',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontFamily: _font,
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.points, required this.target});

  final int points;
  final int target;

  @override
  Widget build(BuildContext context) {
    final progress = target == 0 ? 0.0 : (points / target).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.insights_rounded, color: _blue),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'نقاطك في هذا التحدي',
                  style: TextStyle(
                    fontFamily: _font,
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '$points XP',
                style: const TextStyle(
                  fontFamily: _font,
                  color: _purple,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(20),
            color: _blue,
            backgroundColor: const Color(0xFFE9EBF6),
          ),
          const SizedBox(height: 7),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'الهدف الأسبوعي: $target XP',
              style: const TextStyle(
                fontFamily: _font,
                color: _muted,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantsCard extends StatelessWidget {
  const _ParticipantsCard({required this.participants});

  final List<ChallengeParticipant> participants;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardTitle(
            icon: Icons.groups_rounded,
            title: 'المشاركون في التحدي',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: participants
                .take(6)
                .map(
                  (participant) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7FD),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _line),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: participant.isOnline
                                ? const Color(0xFF25B99A)
                                : _muted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          participant.name,
                          style: const TextStyle(
                            fontFamily: _font,
                            color: _ink,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  const _LeaderboardCard({required this.entries});

  final List<ChallengeParticipant> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const _CardTitle(
            icon: Icons.leaderboard_rounded,
            title: 'لوحة صدارة المتسابقين',
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < entries.length; index++) ...[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: index == 0 ? 10 : 2,
                vertical: index == 0 ? 10 : 3,
              ),
              decoration: BoxDecoration(
                gradient: index == 0
                    ? LinearGradient(
                        colors: [
                          const Color(0xFFFFD45C).withValues(alpha: .24),
                          const Color(0xFFFFF7D6).withValues(alpha: .45),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(15),
                border: index == 0
                    ? Border.all(
                        color: const Color(0xFFFFD45C).withValues(alpha: .72),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? const Color(0xFFFFD45C)
                          : index < 3
                          ? [_purple, _blue, const Color(0xFF6A67CE)][index]
                          : const Color(0xFFF0F2FA),
                      shape: BoxShape.circle,
                    ),
                    child: index == 0
                        ? const Icon(
                            Icons.emoji_events_rounded,
                            color: _ink,
                            size: 19,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontFamily: _font,
                              color: index < 3 ? Colors.white : _ink,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entries[index].name,
                          style: const TextStyle(
                            fontFamily: _font,
                            color: _ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (index == 0)
                          const Text(
                            'متصدر التحدي',
                            style: TextStyle(
                              fontFamily: _font,
                              color: Color(0xFF8A6500),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${entries[index].points} XP',
                    style: TextStyle(
                      fontFamily: _font,
                      color: index == 0 ? const Color(0xFF8A6500) : _blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (index != entries.length - 1)
              const Divider(height: 17, color: _line),
          ],
        ],
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.code,
    required this.notificationQueued,
    required this.onNotification,
    required this.onSms,
    required this.onWhatsApp,
  });

  final String code;
  final bool notificationQueued;
  final VoidCallback onNotification;
  final VoidCallback onSms;
  final VoidCallback onWhatsApp;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _CardTitle(
            icon: Icons.emoji_events_rounded,
            title: 'دعوة التحدي',
          ),
          const SizedBox(height: 7),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              'Code: $code',
              style: const TextStyle(
                fontFamily: _font,
                color: _purple,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Divider(height: 25, color: _line),
          const Text(
            'اختر وسيلة إرسال دعوة التحدي:',
            style: TextStyle(fontFamily: _font, color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 11),
          _InviteAction(
            icon: notificationQueued
                ? Icons.check_circle_rounded
                : Icons.notifications_active_rounded,
            label: notificationQueued
                ? 'تمت إضافة الإشعار الجماعي'
                : 'إشعار جماعي لكل المستخدمين',
            color: _purple,
            onTap: notificationQueued ? null : onNotification,
          ),
          const SizedBox(height: 9),
          _InviteAction(
            icon: Icons.sms_rounded,
            label: 'إرسال رسالة SMS',
            color: _blue,
            onTap: onSms,
          ),
          const SizedBox(height: 9),
          _InviteAction(
            icon: Icons.chat_rounded,
            label: 'إرسال رسالة WhatsApp',
            color: const Color(0xFF168F7B),
            onTap: onWhatsApp,
          ),
        ],
      ),
    );
  }
}

class _InviteAction extends StatelessWidget {
  const _InviteAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withValues(alpha: .35)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 21),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: _font,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionOption extends StatelessWidget {
  const _QuestionOption({
    required this.number,
    required this.label,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  final int number;
  final String label;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = correct
        ? const Color(0xFF1AA984)
        : wrong
        ? const Color(0xFFE24A67)
        : selected
        ? _purple
        : _line;
    final fillColor = correct
        ? const Color(0xFFECFAF6)
        : wrong
        ? const Color(0xFFFFF0F3)
        : Colors.white;
    return Material(
      color: fillColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.4),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: .1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$number',
                  style: TextStyle(
                    fontFamily: _font,
                    color: borderColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: _font,
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (correct)
                const Icon(Icons.check_circle_rounded, color: Color(0xFF1AA984))
              else if (wrong)
                const Icon(Icons.cancel_rounded, color: Color(0xFFE24A67)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _blue, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: _font,
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: _surface,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: _line),
    boxShadow: [
      BoxShadow(
        color: _blue.withValues(alpha: .055),
        blurRadius: 18,
        offset: const Offset(0, 7),
      ),
    ],
  );
}
