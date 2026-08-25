import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart' hide Text;

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:alwan_hub/core/responsive/responsive_layout.dart';
import 'package:alwan_hub/features/games/data/challenge_invitation_service.dart';
import 'package:alwan_hub/features/games/domain/games_catalog.dart';
import 'package:alwan_hub/features/games/presentation/widgets/challenge_live_chat.dart';

const _font = 'MohammadBoldArt';
const _page = Color(0xFFF8FAFF);
const _ink = Color(0xFF17164F);
const _blue = Color(0xFF334FEA);
const _purple = Color(0xFF8E2DE2);
const _muted = Color(0xFF73788F);
const _line = Color(0xFFE4E7F3);

class EntertainmentGameScreen extends StatefulWidget {
  const EntertainmentGameScreen({super.key, required this.game});

  final EntertainmentGame game;

  @override
  State<EntertainmentGameScreen> createState() =>
      _EntertainmentGameScreenState();
}

class _EntertainmentGameScreenState extends State<EntertainmentGameScreen> {
  final ChallengeInvitationService _invitationService =
      ChallengeInvitationService();
  bool _notificationQueued = false;

  String get _inviteCode =>
      'ALWAN-${widget.game.id.toUpperCase().replaceAll('_', '-')}';
  String get _invitationText =>
      'أتحداك في ${widget.game.title} على تطبيق ألوان! '
      'رمز الدعوة: $_inviteCode';

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

  Future<void> _queueNotification() async {
    await _invitationService.queueGroupNotification(
      challengeId: widget.game.id,
      challengeTitle: widget.game.title,
      inviteCode: _inviteCode,
    );
    if (!mounted) return;
    setState(() => _notificationQueued = true);
    _showMessage('تمت إضافة دعوة اللعبة إلى قائمة إرسال لوحة التحكم');
  }

  Future<void> _openWhatsApp() async {
    final opened = await _invitationService.sendWhatsApp(_invitationText);
    if (mounted && !opened) {
      _showMessage('تعذر فتح واتساب على هذا الجهاز');
    }
  }

  Future<void> _openSms() async {
    final opened = await _invitationService.sendSms(_invitationText);
    if (mounted && !opened) {
      _showMessage('تعذر فتح تطبيق الرسائل على هذا الجهاز');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(fontFamily: _font),
      ),
      child: Scaffold(
        backgroundColor: _page,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'العودة إلى قائمة الألعاب',
            icon: const Icon(Icons.arrow_back_rounded, color: _blue),
          ),
          title: Text(
            widget.game.title,
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
                  const _GameAdBanner(),
                  Padding(
                    padding: context.responsive.pagePadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _GameHeader(game: widget.game),
                        const SizedBox(height: 13),
                        _gameStage(),
                        const SizedBox(height: 15),
                        _GameInvitationCard(
                          code: _inviteCode,
                          queued: _notificationQueued,
                          onNotification: _notificationQueued
                              ? null
                              : _queueNotification,
                          onSms: _openSms,
                          onWhatsApp: _openWhatsApp,
                        ),
                        const SizedBox(height: 15),
                        ChallengeLiveChatCard(
                          roomId: 'game-${widget.game.id}',
                          currentUserName: 'مستخدم ألوان',
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

  Widget _gameStage() {
    return switch (widget.game.id) {
      'memory_match' => const MemoryMatchingGame(),
      'tic_tac_toe' => const TicTacToeGame(),
      _ => const WordGuessGame(),
    };
  }
}

class MemoryMatchingGame extends StatefulWidget {
  const MemoryMatchingGame({super.key});

  @override
  State<MemoryMatchingGame> createState() => _MemoryMatchingGameState();
}

class _MemoryMatchingGameState extends State<MemoryMatchingGame> {
  static const _symbols = <IconData>[
    Icons.headphones_rounded,
    Icons.radio_rounded,
    Icons.music_note_rounded,
    Icons.mic_rounded,
    Icons.star_rounded,
    Icons.favorite_rounded,
  ];

  late List<IconData> _cards;
  final Set<int> _revealed = {};
  final Set<int> _matched = {};
  int _moves = 0;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    _cards = [..._symbols, ..._symbols]..shuffle(Random());
    _revealed.clear();
    _matched.clear();
    _moves = 0;
    _checking = false;
    if (mounted) setState(() {});
  }

  Future<void> _flip(int index) async {
    if (_checking || _matched.contains(index) || _revealed.contains(index)) {
      return;
    }
    setState(() => _revealed.add(index));
    if (_revealed.length != 2) return;
    setState(() {
      _checking = true;
      _moves++;
    });
    final selected = _revealed.toList(growable: false);
    if (_cards[selected.first] == _cards[selected.last]) {
      await Future<void>.delayed(const Duration(milliseconds: 280));
      if (!mounted) return;
      setState(() {
        _matched.addAll(selected);
        _revealed.clear();
        _checking = false;
      });
      if (_matched.length == _cards.length) {
        _showCompletion();
      }
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 720));
    if (!mounted) return;
    setState(() {
      _revealed.clear();
      _checking = false;
    });
  }

  void _showCompletion() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        icon: const Icon(Icons.emoji_events_rounded, color: _purple, size: 48),
        title: const Text(
          'أحسنت! أكملت اللعبة',
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: _font, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'أنهيت مطابقة البطاقات في $_moves حركة.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: _font, color: _muted),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _reset();
            },
            style: FilledButton.styleFrom(backgroundColor: _blue),
            child: const Text('العب مرة أخرى'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _StageCard(
      title: 'لعبة مطابقة الذاكرة',
      icon: Icons.extension_rounded,
      trailing: 'الحركات: $_moves',
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              const columns = 4;
              const spacing = 9.0;
              final size =
                  (constraints.maxWidth - ((columns - 1) * spacing)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: List.generate(_cards.length, (index) {
                  final visible =
                      _revealed.contains(index) || _matched.contains(index);
                  return SizedBox(
                    width: size,
                    height: size,
                    child: Material(
                      color: visible
                          ? _blue.withValues(alpha: .09)
                          : const Color(0xFFF2F3FA),
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        onTap: () => _flip(index),
                        borderRadius: BorderRadius.circular(15),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: visible
                              ? Icon(
                                  _cards[index],
                                  key: ValueKey('symbol-$index'),
                                  color: _matched.contains(index)
                                      ? const Color(0xFF1AA984)
                                      : _purple,
                                  size: size * .43,
                                )
                              : Icon(
                                  Icons.question_mark_rounded,
                                  key: ValueKey('hidden-$index'),
                                  color: _muted.withValues(alpha: .65),
                                  size: size * .35,
                                ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 17),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة اللعب'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _purple,
              side: const BorderSide(color: _purple),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class TicTacToeGame extends StatefulWidget {
  const TicTacToeGame({super.key});

  @override
  State<TicTacToeGame> createState() => _TicTacToeGameState();
}

class _TicTacToeGameState extends State<TicTacToeGame> {
  final List<String?> _board = List.filled(9, null);
  String _status = 'دورك: X';
  bool _locked = false;
  int _moves = 0;

  static const _wins = <List<int>>[
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  String? _winner() {
    for (final line in _wins) {
      final value = _board[line.first];
      if (value != null &&
          value == _board[line[1]] &&
          value == _board[line[2]]) {
        return value;
      }
    }
    return null;
  }

  Future<void> _play(int index) async {
    if (_locked || _board[index] != null) return;
    setState(() {
      _board[index] = 'X';
      _moves++;
    });
    if (_finishIfNeeded()) return;
    setState(() {
      _locked = true;
      _status = 'يفكر المنافس...';
    });
    await Future<void>.delayed(const Duration(milliseconds: 430));
    if (!mounted) return;
    final empty = <int>[
      for (var i = 0; i < _board.length; i++)
        if (_board[i] == null) i,
    ];
    if (empty.isNotEmpty) {
      final choice = empty.contains(4)
          ? 4
          : empty[Random().nextInt(empty.length)];
      setState(() {
        _board[choice] = 'O';
        _moves++;
        _locked = false;
        _status = 'دورك: X';
      });
      _finishIfNeeded();
    }
  }

  bool _finishIfNeeded() {
    final winner = _winner();
    if (winner != null) {
      setState(() {
        _locked = true;
        _status = winner == 'X' ? 'أحسنت، فزت!' : 'فاز المنافس هذه الجولة';
      });
      return true;
    }
    if (_board.every((value) => value != null)) {
      setState(() {
        _locked = true;
        _status = 'تعادل رائع!';
      });
      return true;
    }
    return false;
  }

  void _reset() {
    setState(() {
      _board.fillRange(0, _board.length, null);
      _status = 'دورك: X';
      _locked = false;
      _moves = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _StageCard(
      title: 'لعبة إكس أو التفاعلية',
      icon: Icons.grid_3x3_rounded,
      trailing: 'الحركات: $_moves',
      child: Column(
        children: [
          Text(
            _status,
            style: const TextStyle(
              fontFamily: _font,
              color: _purple,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 330),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 8.0;
                  final size = (constraints.maxWidth - spacing * 2) / 3;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: List.generate(9, (index) {
                      final value = _board[index];
                      return SizedBox(
                        width: size,
                        height: size,
                        child: Material(
                          color: const Color(0xFFF3F4FA),
                          borderRadius: BorderRadius.circular(17),
                          child: InkWell(
                            onTap: () => _play(index),
                            borderRadius: BorderRadius.circular(17),
                            child: Center(
                              child: Text(
                                value ?? '',
                                style: TextStyle(
                                  fontFamily: _font,
                                  color: value == 'X' ? _blue : _purple,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة اللعب'),
          ),
        ],
      ),
    );
  }
}

class WordGuessGame extends StatefulWidget {
  const WordGuessGame({super.key});

  @override
  State<WordGuessGame> createState() => _WordGuessGameState();
}

class _WordGuessGameState extends State<WordGuessGame> {
  static const _rounds = <(String, String, String)>[
    ('ن ا و ل أ', 'ألوان', 'اسم الإذاعة التي تنبض بالحياة'),
    ('ا ح ب ص', 'صباح', 'وقت برنامج صباحكم ألوان'),
    ('ت ا ك س د و ب', 'بودكاست', 'محتوى صوتي يتكون من حلقات'),
  ];
  final _controller = TextEditingController();
  int _round = 0;
  int _score = 0;
  String? _feedback;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    final answer = _controller.text.trim();
    if (answer.isEmpty) return;
    final correct = answer == _rounds[_round].$2;
    setState(() {
      _feedback = correct ? 'إجابة صحيحة! +3 نقاط' : 'حاول مرة أخرى';
      if (correct) _score += 3;
    });
    if (!correct) return;
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      setState(() {
        _round = (_round + 1) % _rounds.length;
        _controller.clear();
        _feedback = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _rounds[_round];
    return _StageCard(
      title: 'تخمين الكلمات والبرامج',
      icon: Icons.edit_note_rounded,
      trailing: 'النقاط: $_score',
      child: Column(
        children: [
          const Text(
            'رتّب الأحرف واكتب الإجابة الصحيحة',
            style: TextStyle(fontFamily: _font, color: _muted),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Text(
              current.$1,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: _font,
                color: _purple,
                fontSize: 27,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'التلميح: ${current.$3}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: _font,
              color: _muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            onSubmitted: (_) => _check(),
            style: const TextStyle(
              fontFamily: _font,
              color: _ink,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: 'اكتب الكلمة هنا',
              filled: true,
              fillColor: const Color(0xFFF7F8FC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: _line),
              ),
            ),
          ),
          if (_feedback != null) ...[
            const SizedBox(height: 9),
            Text(
              _feedback!,
              style: TextStyle(
                fontFamily: _font,
                color: _feedback!.contains('صحيحة')
                    ? const Color(0xFF168F7B)
                    : const Color(0xFFE34262),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _check,
            icon: const Icon(Icons.check_rounded),
            label: const Text('تحقق من الإجابة'),
            style: FilledButton.styleFrom(backgroundColor: _blue),
          ),
        ],
      ),
    );
  }
}

class _GameAdBanner extends StatelessWidget {
  const _GameAdBanner();

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

class _GameHeader extends StatelessWidget {
  const _GameHeader({required this.game});

  final EntertainmentGame game;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [game.color, _purple],
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: game.color.withValues(alpha: .22),
            blurRadius: 23,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .23),
                  ),
                ),
                child: Icon(_gameIcon(game.id), color: Colors.white, size: 31),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Text(
                        'المرحلة الثانية • حلبة اللعب',
                        style: TextStyle(
                          fontFamily: _font,
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontFamily: _font,
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            game.subtitle,
            style: const TextStyle(
              fontFamily: _font,
              color: Colors.white70,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              _HeaderMetric(icon: Icons.group_outlined, label: game.mode),
              _HeaderMetric(
                icon: Icons.timer_outlined,
                label: '${game.estimatedMinutes} دقائق',
              ),
              _HeaderMetric(
                icon: Icons.stars_rounded,
                label: '+${game.rewardPoints} نقطة',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: Colors.white.withValues(alpha: .16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: _font,
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.title,
    required this.icon,
    required this.trailing,
    required this.child,
  });

  final String title;
  final IconData icon;
  final String trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: _purple),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: _font,
                    color: _ink,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                trailing,
                style: const TextStyle(
                  fontFamily: _font,
                  color: _blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          child,
        ],
      ),
    );
  }
}

class _GameInvitationCard extends StatelessWidget {
  const _GameInvitationCard({
    required this.code,
    required this.queued,
    required this.onNotification,
    required this.onSms,
    required this.onWhatsApp,
  });

  final String code;
  final bool queued;
  final VoidCallback? onNotification;
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
          const Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: _blue),
              SizedBox(width: 8),
              Text(
                'دعوة تحدي اللعبة',
                style: TextStyle(
                  fontFamily: _font,
                  color: _ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Code: $code',
            textDirection: TextDirection.ltr,
            style: const TextStyle(
              fontFamily: _font,
              color: _purple,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(height: 23, color: _line),
          _GameInviteButton(
            icon: queued
                ? Icons.check_circle_rounded
                : Icons.notifications_active_rounded,
            label: queued
                ? 'تمت إضافة الإشعار الجماعي'
                : 'إشعار جماعي للمتحدين',
            color: _purple,
            onTap: onNotification,
          ),
          const SizedBox(height: 9),
          _GameInviteButton(
            icon: Icons.sms_rounded,
            label: 'إرسال رسالة SMS',
            color: _blue,
            onTap: onSms,
          ),
          const SizedBox(height: 9),
          _GameInviteButton(
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

class _GameInviteButton extends StatelessWidget {
  const _GameInviteButton({
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: .3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontFamily: _font,
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _gameIcon(String id) {
  if (id == 'memory_match') return Icons.extension_rounded;
  if (id == 'tic_tac_toe') return Icons.grid_3x3_rounded;
  return Icons.edit_note_rounded;
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
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
