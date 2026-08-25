import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/core/audio/widgets/mini_player.dart';
import 'package:alwan_hub/core/widgets/adaptive_content_image.dart';
import 'package:alwan_hub/features/interaction/data/live_program_interaction_service.dart';
import 'package:alwan_hub/features/interaction/presentation/providers/live_program_interaction_provider.dart';
import 'package:alwan_hub/features/programs/domain/entities/fm_program.dart';
import 'package:alwan_hub/features/programs/presentation/providers/fm_program_provider.dart';

/// مساحة التفاعل الخاصة بالبرنامج المباشر الحالي.
///
/// عند فتحها من البطاقة المباشرة يصل البرنامج نفسه عبر [program]، وعند فتحها
/// من بطاقة «شارك ودردش» تستعيد البرنامج الحي من مصدر لوحة التحكم.
class ShareAndChatScreen extends ConsumerStatefulWidget {
  const ShareAndChatScreen({super.key, this.program});

  final FmProgram? program;

  @override
  ConsumerState<ShareAndChatScreen> createState() =>
      _ShareAndChatScreenState();
}

class _ShareAndChatScreenState extends ConsumerState<ShareAndChatScreen> {
  final TextEditingController _presenterMessageController =
      TextEditingController();
  final TextEditingController _chatMessageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  int _selectedTabIndex = 0;
  int? _q1Selected;
  int? _q2Selected;
  int? _q3Selected;
  bool _pollSubmitted = false;

  bool get _isPollComplete =>
      _q1Selected != null && _q2Selected != null && _q3Selected != null;

  @override
  void dispose() {
    _presenterMessageController.dispose();
    _chatMessageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProgram = ref
        .watch(liveFmProgramProvider)
        .maybeWhen(data: (program) => program, orElse: () => null);
    final program = widget.program ?? dashboardProgram;
    final programId = program?.id.isNotEmpty == true
        ? program!.id
        : 'alwan-fm';
    final interactionService = ref.read(liveProgramInteractionServiceProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        bottomNavigationBar: const MiniPlayer(),
        body: SafeArea(
          child: Column(
            children: [
              _TopBar(onBack: () => Navigator.maybePop(context)),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        children: [
                          const _Header(),
                          const SizedBox(height: 16),
                          _ProgramCard(program: program),
                          const SizedBox(height: 20),
                          _Tabs(
                            selectedIndex: _selectedTabIndex,
                            onSelected: (index) =>
                                setState(() => _selectedTabIndex = index),
                          ),
                          const SizedBox(height: 20),
                          _buildTabContent(
                            program: program,
                            programId: programId,
                            interactionService: interactionService,
                          ),
                        ],
                      ),
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

  Widget _buildTabContent({
    required FmProgram? program,
    required String programId,
    required LiveProgramInteractionService interactionService,
  }) {
    return switch (_selectedTabIndex) {
      0 => _PresenterMessageTab(
        controller: _presenterMessageController,
        programName: program?.title ?? 'البرنامج المباشر',
        onSend: () => _sendPresenterMessage(
          programId: programId,
          interactionService: interactionService,
        ),
      ),
      1 => _PublicChatTab(
        programId: programId,
        service: interactionService,
        controller: _chatMessageController,
        scrollController: _chatScrollController,
        onSend: () => _sendChatMessage(
          programId: programId,
          interactionService: interactionService,
        ),
      ),
      _ => _LivePollTab(
        q1Selected: _q1Selected,
        q2Selected: _q2Selected,
        q3Selected: _q3Selected,
        isSubmitted: _pollSubmitted,
        onFirstChanged: (value) => setState(() {
          _q1Selected = value;
          _pollSubmitted = false;
        }),
        onSecondChanged: (value) => setState(() {
          _q2Selected = value;
          _pollSubmitted = false;
        }),
        onThirdChanged: (value) => setState(() {
          _q3Selected = value;
          _pollSubmitted = false;
        }),
        onSubmit: _isPollComplete
            ? () => _submitPoll(
                programId: programId,
                interactionService: interactionService,
              )
            : null,
      ),
    };
  }

  Future<void> _sendPresenterMessage({
    required String programId,
    required LiveProgramInteractionService interactionService,
  }) async {
    final message = _presenterMessageController.text.trim();
    if (message.isEmpty) return;
    await interactionService.sendPresenterMessage(
      programId: programId,
      text: message,
    );
    _presenterMessageController.clear();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال رسالتك إلى لوحة البرنامج.')),
    );
  }

  Future<void> _sendChatMessage({
    required String programId,
    required LiveProgramInteractionService interactionService,
  }) async {
    final message = _chatMessageController.text.trim();
    if (message.isEmpty) return;
    await interactionService.publishChatMessage(
      LiveProgramChatMessage(
        id: 'listener-${DateTime.now().microsecondsSinceEpoch}',
        programId: programId,
        author: 'مستمع ألوان',
        sentAt: DateTime.now(),
        text: message,
        isMine: true,
      ),
    );
    _chatMessageController.clear();
    if (!_chatScrollController.hasClients) return;
    await _chatScrollController.animateTo(
      _chatScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _submitPoll({
    required String programId,
    required LiveProgramInteractionService interactionService,
  }) async {
    await interactionService.submitPoll(
      programId: programId,
      answers: {
        'question_1': _q1Selected!,
        'question_2': _q2Selected!,
        'question_3': _q3Selected!,
      },
    );
    if (!mounted) return;
    setState(() => _pollSubmitted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال تصويتاتك إلى لوحة التحكم.')),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: IconButton.filledTonal(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_forward_rounded),
          tooltip: 'رجوع',
          color: const Color(0xFF5B4CF0),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.graphic_eq_rounded, color: Color(0xFF6A4CDB)),
            SizedBox(width: 8),
            Text(
              'المشاركة الآن والدردشة',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2A2D43),
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.graphic_eq_rounded, color: Color(0xFF6A4CDB)),
          ],
        ),
        SizedBox(height: 5),
        Text(
          'تفاعل مع البرنامج المباشر ومستمعي ألوان',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program});

  final FmProgram? program;

  @override
  Widget build(BuildContext context) {
    final title = program?.title ?? 'ألوان FM';
    final presenter = program?.presenterName ?? 'البث المباشر';
    final time = program?.broadcastTimeLabel ?? 'على مدار الساعة';
    final image = program?.imageUrl ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A148C), Color(0xFF6A4CDB)],
          begin: AlignmentDirectional.centerStart,
          end: AlignmentDirectional.centerEnd,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 52,
              height: 52,
              child: AdaptiveContentImage(
                source: image,
                fit: BoxFit.cover,
                semanticLabel: presenter,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  presenter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.white, size: 7),
                    SizedBox(width: 4),
                    Text(
                      'مباشر الآن',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 7),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded,
                      color: Colors.white70, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    time,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      ('رسالة للمذيع', Icons.mail_outline),
      ('الدردشة', Icons.chat_bubble_outline),
      ('استفتاء', Icons.poll_outlined),
    ];
    return LayoutBuilder(
      builder: (context, constraints) => SegmentedButton<int>(
        segments: List.generate(
          items.length,
          (index) => ButtonSegment<int>(
            value: index,
            icon: Icon(items[index].$2, size: 18),
            label: Text(
              constraints.maxWidth < 390
                  ? items[index].$1.split(' ').first
                  : items[index].$1,
            ),
          ),
        ),
        selected: {selectedIndex},
        onSelectionChanged: (value) => onSelected(value.first),
        showSelectedIcon: false,
        style: const ButtonStyle(
          visualDensity: VisualDensity.compact,
          foregroundColor: WidgetStatePropertyAll(Color(0xFF5B4CF0)),
        ),
      ),
    );
  }
}

class _PresenterMessageTab extends StatelessWidget {
  const _PresenterMessageTab({
    required this.controller,
    required this.programName,
    required this.onSend,
  });

  final TextEditingController controller;
  final String programName;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Color(0x1A6A4CDB),
            child: Icon(
              Icons.mark_email_unread_outlined,
              size: 34,
              color: Color(0xFF6A4CDB),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'أرسل رسالتك إلى مذيع $programName',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'تصل رسالتك مباشرة إلى لوحة البرنامج ليطّلع عليها فريق البث.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            maxLines: 4,
            maxLength: 300,
            decoration: _inputDecoration('اكتب رسالتك هنا...'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSend,
              icon: const Icon(Icons.send_rounded),
              label: const Text('إرسال الرسالة'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6A4CDB),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicChatTab extends StatelessWidget {
  const _PublicChatTab({
    required this.programId,
    required this.service,
    required this.controller,
    required this.scrollController,
    required this.onSend,
  });

  final String programId;
  final LiveProgramInteractionService service;
  final TextEditingController controller;
  final ScrollController scrollController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Icon(Icons.forum_rounded, color: Color(0xFF6A4CDB)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'دردشة البرنامج المباشر',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Text(
                  'تتحدّث مع البرنامج الحالي',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
          StreamBuilder<LiveProgramChatRoomState>(
            stream: service.watchRoom(programId),
            initialData: service.roomState(programId),
            builder: (context, snapshot) {
              final messages = snapshot.data?.messages ?? const [];
              if (messages.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 42, horizontal: 24),
                  child: Column(
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          color: Color(0xFF6A4CDB), size: 34),
                      SizedBox(height: 10),
                      Text(
                        'كن أول من يشارك في دردشة هذا البرنامج.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox(
                height: 280,
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                  itemCount: messages.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, index) => _ChatMessageBubble(
                    message: messages[index],
                  ),
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE9E8F2))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: _inputDecoration('اكتب تعليقك هنا ليراه الجميع...')
                        .copyWith(counterText: ''),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: onSend,
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF6A4CDB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({required this.message});

  final LiveProgramChatMessage message;

  @override
  Widget build(BuildContext context) {
    final time = TimeOfDay.fromDateTime(message.sentAt).format(context);
    final isMine = message.isMine;
    return Align(
      alignment: isMine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isMine ? const Color(0xFF6A4CDB) : const Color(0xFFF0EEFA),
            borderRadius: BorderRadiusDirectional.only(
              topStart: const Radius.circular(16),
              topEnd: const Radius.circular(16),
              bottomStart: Radius.circular(isMine ? 16 : 4),
              bottomEnd: Radius.circular(isMine ? 4 : 16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.author,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isMine ? Colors.white : const Color(0xFF4A148C),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 13,
                    color: isMine ? Colors.white : const Color(0xFF2A2D43),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 9,
                    color: isMine ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LivePollTab extends StatelessWidget {
  const _LivePollTab({
    required this.q1Selected,
    required this.q2Selected,
    required this.q3Selected,
    required this.isSubmitted,
    required this.onFirstChanged,
    required this.onSecondChanged,
    required this.onThirdChanged,
    required this.onSubmit,
  });

  final int? q1Selected;
  final int? q2Selected;
  final int? q3Selected;
  final bool isSubmitted;
  final ValueChanged<int?> onFirstChanged;
  final ValueChanged<int?> onSecondChanged;
  final ValueChanged<int?> onThirdChanged;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined, color: Color(0xFF6A4CDB)),
              SizedBox(width: 7),
              Text(
                'استفتاء البرنامج المباشر',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Spacer(),
              _LiveStatus(),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'تصل نتائج الاستفتاء إلى لوحة التحكم لمتابعة تفاعل المستمعين.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 18),
          _PollQuestion(
            question: 'ما مدى أهمية موضوع حلقة اليوم بالنسبة لك؟',
            options: const ['مهم جدًا', 'متوسط الأهمية', 'غير مهم حاليًا'],
            selected: q1Selected,
            onChanged: onFirstChanged,
          ),
          const SizedBox(height: 14),
          _PollQuestion(
            question: 'كيف تقيّم أداء المذيع وطريقة تناول الموضوع؟',
            options: const ['ممتاز', 'جيد جدًا', 'مقبول', 'يحتاج إلى تحسين'],
            selected: q2Selected,
            onChanged: onSecondChanged,
          ),
          const SizedBox(height: 14),
          _PollQuestion(
            question: 'هل تود الاستمرار في موضوعات مشابهة؟',
            options: const ['نعم', 'لا'],
            selected: q3Selected,
            onChanged: onThirdChanged,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSubmit,
              icon: Icon(isSubmitted ? Icons.check_circle_rounded : Icons.send),
              label: Text(isSubmitted ? 'تم إرسال التصويت' : 'إرسال تصويتاتي'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF6A4CDB),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveStatus extends StatelessWidget {
  const _LiveStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0x1AE53935),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'نشط الآن',
        style: TextStyle(
          color: Color(0xFFE53935),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PollQuestion extends StatelessWidget {
  const _PollQuestion({
    required this.question,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String question;
  final List<String> options;
  final int? selected;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E3F0)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 7),
            RadioGroup<int>(
              groupValue: selected,
              onChanged: onChanged,
              child: Column(
                children: List.generate(
                  options.length,
                  (index) => RadioListTile<int>(
                    value: index,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: const Color(0xFF6A4CDB),
                    title: Text(options[index], style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8E6F3)),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 14, offset: Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }
}

InputDecoration _inputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
  filled: true,
  fillColor: const Color(0xFFF8F7FC),
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide.none,
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: Color(0xFF6A4CDB)),
  ),
);
