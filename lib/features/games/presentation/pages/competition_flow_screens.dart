import 'package:flutter/material.dart' hide Text;
import 'package:share_plus/share_plus.dart';

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/core/services/link_launcher_service.dart';
import 'package:alwan_hub/features/games/domain/games_catalog.dart';

const _font = 'MohammadBoldArt';
const _page = Color(0xFFF8FAFF);
const _ink = Color(0xFF17164F);
const _blue = Color(0xFF334FEA);
const _purple = Color(0xFF8E2DE2);
const _muted = Color(0xFF73788F);
const _line = Color(0xFFE4E7F3);

class CallParticipationSheet {
  const CallParticipationSheet._();

  static Future<void> show(
    BuildContext context,
    CompetitionProgram program,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _CallSheetBody(program: program),
    );
  }
}

class _CallSheetBody extends StatelessWidget {
  const _CallSheetBody({required this.program});

  final CompetitionProgram program;

  Future<void> _call(BuildContext context, String number) async {
    final launched = await LinkLauncherService().openPhone(number);
    if (!context.mounted || launched) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تعذر فتح تطبيق الاتصال على هذا الجهاز',
          style: TextStyle(fontFamily: _font, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          context.responsive.pagePadding.left,
          12,
          context.responsive.pagePadding.right,
          24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD8DBEA),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [_blue, _purple]),
                  ),
                  child: const Icon(Icons.call_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'البث المباشر (${program.title})',
                        style: const TextStyle(
                          fontFamily: _font,
                          color: _ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        'اختر أحد خطوط الاتصال الرسمية للانتقال إلى تطبيق الهاتف',
                        style: TextStyle(
                          fontFamily: _font,
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'إغلاق',
                  icon: const Icon(Icons.close_rounded, color: _purple),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7FF),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _line),
              ),
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < program.contactLines.length;
                    index++
                  ) ...[
                    ListTile(
                      onTap: () =>
                          _call(context, program.contactLines[index].number),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _blue.withValues(alpha: .08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.phone_rounded, color: _blue),
                      ),
                      title: Text(
                        '${program.contactLines[index].label}: ${program.contactLines[index].number}',
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          fontFamily: _font,
                          color: _ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: const Text(
                        'اتصل الآن',
                        style: TextStyle(
                          fontFamily: _font,
                          color: _purple,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (index != program.contactLines.length - 1)
                      const Divider(height: 1, color: _line),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompetitionDetailsScreen extends StatelessWidget {
  const CompetitionDetailsScreen({
    super.key,
    required this.program,
    required this.returnToGamesBuilder,
  });

  final CompetitionProgram program;
  final WidgetBuilder returnToGamesBuilder;

  @override
  Widget build(BuildContext context) {
    final enrollment = program.enrollment;
    if (enrollment == null) {
      return _MissingEnrollmentScreen(program: program);
    }

    final details = [
      ('تفاصيل البرنامج', enrollment.programDetails, Icons.description_rounded),
      ('رعاة البرنامج', enrollment.sponsors, Icons.handshake_rounded),
      ('الفئة المستهدفة', enrollment.targetAudience, Icons.groups_rounded),
      ('نوع الجائزة', enrollment.prizeType, Icons.redeem_rounded),
      ('موعد السحب', enrollment.drawSchedule, Icons.calendar_month_rounded),
    ];

    return _FlowScaffold(
      title: 'تفاصيل وشروط المشاركة بالمسابقة',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SponsorOfferBanner(offer: enrollment.sponsorOffer),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              children: [
                for (var index = 0; index < details.length; index++) ...[
                  _DetailRow(
                    label: details[index].$1,
                    value: details[index].$2,
                    icon: details[index].$3,
                  ),
                  if (index != details.length - 1)
                    const Divider(height: 22, color: _line),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle(
            title: 'شروط المشاركة',
            icon: Icons.fact_check_rounded,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: _cardDecoration(),
            child: Column(
              children: enrollment.conditions
                  .map(
                    (condition) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            color: _blue,
                            size: 19,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              condition,
                              style: const TextStyle(
                                fontFamily: _font,
                                color: _muted,
                                fontSize: 13,
                                height: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          const _SectionTitle(
            title: 'طريقة احتساب النقاط',
            icon: Icons.stars_rounded,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ScoreRule(
                  value: '${enrollment.correctAnswerPoints}',
                  label: 'للإجابة الصحيحة',
                  color: _blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ScoreRule(
                  value: '${enrollment.wrongAnswerPoints}',
                  label: 'للإجابة الخاطئة',
                  color: _purple,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ScoreRule(
                  value: '+${enrollment.shareBonusPoints}',
                  label: 'لمشاركة المسابقة',
                  color: const Color(0xFF5B4BE7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _GradientButton(
            label: enrollment.questions.isEmpty
                ? 'سيتم نشر الأسئلة قريباً'
                : 'اشترك الآن',
            icon: Icons.auto_awesome_rounded,
            onPressed: enrollment.questions.isEmpty
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CompetitionRegistrationScreen(
                        program: program,
                        returnToGamesBuilder: returnToGamesBuilder,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class CompetitionRegistrationScreen extends StatefulWidget {
  const CompetitionRegistrationScreen({
    super.key,
    required this.program,
    required this.returnToGamesBuilder,
  });

  final CompetitionProgram program;
  final WidgetBuilder returnToGamesBuilder;

  @override
  State<CompetitionRegistrationScreen> createState() =>
      _CompetitionRegistrationScreenState();
}

class _CompetitionRegistrationScreenState
    extends State<CompetitionRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _province;
  int _participantCount = 1;
  bool _submitting = false;

  CompetitionEnrollment get _enrollment => widget.program.enrollment!;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _province == null) {
      if (_province == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى تحديد المحافظة',
              style: TextStyle(fontFamily: _font, fontWeight: FontWeight.w700),
            ),
          ),
        );
      }
      return;
    }

    setState(() => _submitting = true);
    final registration = CompetitionRegistration(
      programId: widget.program.id,
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      province: _province!,
      participantCount: _participantCount,
      submittedAt: DateTime.now(),
    );

    // Ready for the dashboard API: registration.toDashboardJson().
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    setState(() => _submitting = false);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionQuizScreen(
          program: widget.program,
          registration: registration,
          returnToGamesBuilder: widget.returnToGamesBuilder,
        ),
      ),
    );
  }

  Future<void> _share() async {
    await SharePlus.instance.share(
      ShareParams(text: 'شارك في ${widget.program.title} عبر تطبيق ألوان'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _FlowScaffold(
      title: 'التسجيل في البرامج الإذاعية',
      subtitle: 'سجّل بياناتك لدخول السحب والمشاركة المباشرة على الهواء',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FlowTextField(
              controller: _nameController,
              label: 'الاسم الرباعي الكامل',
              icon: Icons.person_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) {
                final words = (value ?? '').trim().split(RegExp(r'\s+'));
                return words.length < 4
                    ? 'يرجى كتابة الاسم الرباعي كاملاً'
                    : null;
              },
            ),
            const SizedBox(height: 14),
            _FlowTextField(
              controller: _phoneController,
              label: 'رقم الهاتف',
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              validator: (value) {
                final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
                return digits.length < 7 ? 'يرجى إدخال رقم هاتف صحيح' : null;
              },
            ),
            const SizedBox(height: 18),
            const _SectionTitle(
              title: 'المحافظة',
              icon: Icons.location_on_rounded,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _province,
              isExpanded: true,
              decoration: _fieldDecoration(Icons.map_rounded, 'حدد المحافظة'),
              dropdownColor: Colors.white,
              style: const TextStyle(
                fontFamily: _font,
                color: _ink,
                fontWeight: FontWeight.w700,
              ),
              items: _enrollment.provinces
                  .map(
                    (province) => DropdownMenuItem(
                      value: province,
                      child: Text(
                        province,
                        style: const TextStyle(
                          fontFamily: _font,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _province = value),
              validator: (value) =>
                  value == null ? 'يرجى تحديد المحافظة' : null,
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'عدد المشاركين بالبرنامج',
                      style: TextStyle(
                        fontFamily: _font,
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _participantCount > 1
                        ? () => setState(() => _participantCount--)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: _purple,
                  ),
                  Text(
                    '$_participantCount',
                    style: const TextStyle(
                      fontFamily: _font,
                      color: _ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _participantCount++),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: _blue,
                  ),
                  IconButton(
                    onPressed: _share,
                    tooltip: 'مشاركة',
                    icon: const Icon(Icons.share_rounded, color: _purple),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    'عدد المشتركين المسجلين حالياً: ${_enrollment.currentParticipants}',
                    style: const TextStyle(
                      fontFamily: _font,
                      color: _ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'مشترك نشط',
                    style: TextStyle(
                      fontFamily: _font,
                      color: _blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _GradientButton(
              label: _submitting
                  ? 'جارٍ الإرسال...'
                  : 'تأكيد وإرسال طلب الاشتراك',
              icon: Icons.edit_note_rounded,
              onPressed: _submitting ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class CompetitionQuizScreen extends StatefulWidget {
  const CompetitionQuizScreen({
    super.key,
    required this.program,
    required this.registration,
    required this.returnToGamesBuilder,
  });

  final CompetitionProgram program;
  final CompetitionRegistration registration;
  final WidgetBuilder returnToGamesBuilder;

  @override
  State<CompetitionQuizScreen> createState() => _CompetitionQuizScreenState();
}

class _CompetitionQuizScreenState extends State<CompetitionQuizScreen> {
  int _questionIndex = 0;
  int _score = 0;
  int _correctAnswers = 0;
  int? _selectedOption;
  bool _shared = false;

  CompetitionEnrollment get _enrollment => widget.program.enrollment!;
  CompetitionQuestion get _question => _enrollment.questions[_questionIndex];

  void _selectAnswer(int index) {
    if (_selectedOption != null) return;
    final correct = index == _question.correctOptionIndex;
    setState(() {
      _selectedOption = index;
      _score += correct
          ? _enrollment.correctAnswerPoints
          : _enrollment.wrongAnswerPoints;
      if (correct) _correctAnswers++;
    });
  }

  void _next() {
    if (_selectedOption == null) return;
    if (_questionIndex < _enrollment.questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedOption = null;
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionResultScreen(
          program: widget.program,
          registration: widget.registration,
          score: _score,
          correctAnswers: _correctAnswers,
          totalQuestions: _enrollment.questions.length,
          returnToGamesBuilder: widget.returnToGamesBuilder,
        ),
      ),
    );
  }

  Future<void> _share() async {
    await SharePlus.instance.share(
      ShareParams(text: 'أنا أشارك في ${widget.program.title} عبر تطبيق ألوان'),
    );
    if (!mounted || _shared) return;
    setState(() {
      _shared = true;
      _score += _enrollment.shareBonusPoints;
    });
  }

  @override
  Widget build(BuildContext context) {
    final answerIsCorrect = _selectedOption == _question.correctOptionIndex;
    return _FlowScaffold(
      title: widget.program.title,
      subtitle:
          'السؤال ${_questionIndex + 1} من ${_enrollment.questions.length}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SponsorOfferBanner(offer: _enrollment.sponsorOffer, compact: true),
          const SizedBox(height: 22),
          Text(
            _question.question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: _font,
              color: _ink,
              fontSize: 23,
              height: 1.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          for (var index = 0; index < _question.options.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: _AnswerOption(
                index: index,
                label: _question.options[index],
                selected: _selectedOption == index,
                correct:
                    _selectedOption != null &&
                    index == _question.correctOptionIndex,
                wrong:
                    _selectedOption == index &&
                    index != _question.correctOptionIndex,
                onTap: () => _selectAnswer(index),
              ),
            ),
          if (_selectedOption != null) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: answerIsCorrect
                    ? const Color(0xFFEAF4FF)
                    : const Color(0xFFF6EDFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                answerIsCorrect
                    ? 'إجابة صحيحة! +${_enrollment.correctAnswerPoints} نقاط'
                    : 'إجابة غير صحيحة، حصلت على ${_enrollment.wrongAnswerPoints} نقطة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: _font,
                  color: answerIsCorrect ? _blue : _purple,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.groups_rounded,
                  label: 'عدد المشاركين',
                  value: '${_enrollment.currentParticipants}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatCard(
                  icon: Icons.stars_rounded,
                  label: 'نقاطك الحالية',
                  value: '$_score',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: _shared ? null : _share,
                  borderRadius: BorderRadius.circular(18),
                  child: _StatCard(
                    icon: Icons.share_rounded,
                    label: _shared ? 'تمت المشاركة' : 'شارك للمكافأة',
                    value: '+${_enrollment.shareBonusPoints}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _GradientButton(
            label: _questionIndex == _enrollment.questions.length - 1
                ? 'إنهاء الأسئلة'
                : 'التالي',
            icon: Icons.arrow_forward_rounded,
            onPressed: _selectedOption == null ? null : _next,
          ),
        ],
      ),
    );
  }
}

class CompetitionResultScreen extends StatelessWidget {
  const CompetitionResultScreen({
    super.key,
    required this.program,
    required this.registration,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.returnToGamesBuilder,
  });

  final CompetitionProgram program;
  final CompetitionRegistration registration;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final WidgetBuilder returnToGamesBuilder;

  void _returnToGames(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/games'),
        builder: returnToGamesBuilder,
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ResponsiveContent(
          maxWidth: 620,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 240,
                height: 240,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_blue, _purple],
                  ),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.celebration_rounded,
                      color: Colors.white,
                      size: 58,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'رائع!',
                      style: TextStyle(
                        fontFamily: _font,
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'انتهت الأسئلة',
                style: TextStyle(
                  fontFamily: _font,
                  color: _ink,
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${registration.fullName}، حصلت على $score نقطة وأجبت عن $correctAnswers من $totalQuestions إجابات صحيحة.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: _font,
                  color: _muted,
                  fontSize: 15,
                  height: 1.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: _GradientButton(
                  label: 'الرجوع إلى قائمة المسابقات',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => _returnToGames(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlowScaffold extends StatelessWidget {
  const _FlowScaffold({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: _font,
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: _blue),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 34),
          child: ResponsiveContent(
            maxWidth: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (subtitle != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: _font,
                      color: _muted,
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SponsorOfferBanner extends StatelessWidget {
  const _SponsorOfferBanner({required this.offer, this.compact = false});

  final CompetitionSponsorOffer offer;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          width: double.infinity,
          height: compact ? 150 : 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0E5735),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                offer.title,
                style: const TextStyle(
                  fontFamily: _font,
                  color: Color(0xFFFFD447),
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                offer.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: _font,
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  offer.description,
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: _font,
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'كود الخصم: ${offer.promoCode}',
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontFamily: _font,
                      color: Color(0xFFFFD447),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _blue, size: 21),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: _font,
              color: _ink,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: _font,
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _purple, size: 21),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: _font,
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ScoreRule extends StatelessWidget {
  const _ScoreRule({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: _font,
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontFamily: _font,
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowTextField extends StatelessWidget {
  const _FlowTextField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: const TextStyle(
        fontFamily: _font,
        color: _ink,
        fontWeight: FontWeight.w700,
      ),
      decoration: _fieldDecoration(icon, label),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.index,
    required this.label,
    required this.selected,
    required this.correct,
    required this.wrong,
    required this.onTap,
  });

  final int index;
  final String label;
  final bool selected;
  final bool correct;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = correct
        ? _blue
        : wrong
        ? _purple
        : selected
        ? _purple
        : _line;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: correct
              ? const Color(0xFFEEF4FF)
              : wrong
              ? const Color(0xFFF8EFFF)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: borderColor,
            width: selected || correct ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: .09),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontFamily: _font,
                  color: borderColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: _font,
                  color: _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (correct) const Icon(Icons.check_circle_rounded, color: _blue),
            if (wrong) const Icon(Icons.cancel_rounded, color: _purple),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(icon, color: _blue, size: 20),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontFamily: _font,
              color: _muted,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: _font,
              color: _purple,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(colors: [_blue, _purple])
            : const LinearGradient(
                colors: [Color(0xFFD7DAE5), Color(0xFFC9CDD9)],
              ),
        borderRadius: BorderRadius.circular(17),
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: _font,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
      ),
    );
  }
}

class _MissingEnrollmentScreen extends StatelessWidget {
  const _MissingEnrollmentScreen({required this.program});

  final CompetitionProgram program;

  @override
  Widget build(BuildContext context) {
    return _FlowScaffold(
      title: program.title,
      child: const Center(
        child: Text(
          'سيتم نشر تفاصيل الاشتراك قريباً',
          style: TextStyle(
            fontFamily: _font,
            color: _muted,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration(IconData icon, String label) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      fontFamily: _font,
      color: _muted,
      fontWeight: FontWeight.w700,
    ),
    prefixIcon: Icon(icon, color: _blue),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _line),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _line),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: _blue, width: 1.5),
    ),
  );
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: _line),
    boxShadow: [
      BoxShadow(
        color: _blue.withValues(alpha: .05),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
