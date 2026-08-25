import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:alwan_hub/core/audio/audio_controller.dart';
import 'package:alwan_hub/core/audio/models/audio_track.dart';
import 'package:alwan_hub/core/audio/widgets/mini_player.dart';
import 'package:alwan_hub/core/router/app_router.dart';

import '../application/alwan_ai_command_service.dart';
import '../data/alwan_ai_catalog_provider.dart';
import '../data/alwan_ai_gateway.dart';
import '../domain/alwan_ai_models.dart';

const _aiPurple = Color(0xFF6C27D9);
const _aiBlue = Color(0xFF1769E8);
const _aiCyan = Color(0xFF05A9C7);
const _aiInk = Color(0xFF171247);
const _aiSurface = Color(0xFFF5F4FF);

class AlwanAiScreen extends ConsumerStatefulWidget {
  const AlwanAiScreen({
    super.key,
    this.commandService,
    this.autoStartListening = false,
  });

  final AlwanAiCommandService? commandService;
  final bool autoStartListening;

  @override
  ConsumerState<AlwanAiScreen> createState() => _AlwanAiScreenState();
}

class _AlwanAiScreenState extends ConsumerState<AlwanAiScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _speech = SpeechToText();

  late final AlwanAiCommandService _commands;
  final List<AlwanAiMessage> _messages = [];
  List<AlwanAiSearchResult> _searchResults = const [];
  AlwanAiMode _mode = AlwanAiMode.search;
  bool _busy = false;
  bool _listening = false;
  bool _speechInitialized = false;
  bool _voiceSubmitted = false;
  String _lastRecognizedWords = '';
  int _messageSequence = 0;

  @override
  void initState() {
    super.initState();
    _commands =
        widget.commandService ?? ref.read(alwanAiCommandServiceProvider);
    _messages.add(
      AlwanAiMessage(
        id: _nextMessageId(),
        role: AlwanAiMessageRole.assistant,
        text:
            'مرحبًا، أنا ألوان AI. قل مثلًا: «افتح الأبراج اليومية» أو «شغّل البث المباشر»، أو استخدم أدوات الدردشة والصور والموسيقى.',
      ),
    );
    if (widget.autoStartListening) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_startListening());
      });
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _nextMessageId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_messageSequence++}';

  void _setMode(AlwanAiMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _searchResults = const [];
    });
    _textController.clear();
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      await _submitRecognizedSpeech();
      return;
    }

    await _startListening();
  }

  Future<void> _startListening() async {
    if (_busy || _listening) return;
    _voiceSubmitted = false;
    _lastRecognizedWords = '';
    _textController.clear();
    try {
      final available = await _ensureSpeechInitialized();

      if (!available) {
        if (mounted) {
          _showMessage(
            'تعذر تشغيل التعرف الصوتي. تأكد من السماح بالميكروفون ثم حاول مجددًا.',
          );
        }
        return;
      }

      final locales = await _speech.locales();
      String? arabicLocale;
      for (final locale in locales) {
        if (locale.localeId.toLowerCase().startsWith('ar')) {
          arabicLocale = locale.localeId;
          break;
        }
      }

      if (!mounted) return;
      setState(() => _listening = true);
      await _speech.listen(
        listenOptions: SpeechListenOptions(
          localeId: arabicLocale,
          listenFor: const Duration(seconds: 25),
          pauseFor: const Duration(seconds: 3),
          cancelOnError: true,
          partialResults: true,
          autoPunctuation: true,
          listenMode: ListenMode.confirmation,
        ),
        onResult: (result) {
          if (!mounted) return;
          final words = result.recognizedWords.trim();
          _lastRecognizedWords = words;
          _textController.value = TextEditingValue(
            text: words,
            selection: TextSelection.collapsed(offset: words.length),
          );
          if (result.finalResult && words.isNotEmpty && !_voiceSubmitted) {
            unawaited(_submitRecognizedSpeech());
          }
        },
      );
    } catch (error, stackTrace) {
      debugPrint('Alwan AI microphone start failed: $error\n$stackTrace');
      if (!mounted) return;
      setState(() => _listening = false);
      _showMessage(_speechErrorMessage(error.toString()));
    }
  }

  Future<bool> _ensureSpeechInitialized() async {
    if (_speechInitialized) return true;
    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          final active = status == 'listening';
          if (_listening != active) setState(() => _listening = active);
          if (!active && (status == 'done' || status == 'notListening')) {
            unawaited(
              Future<void>.delayed(
                const Duration(milliseconds: 180),
                _submitRecognizedSpeech,
              ),
            );
          }
        },
        onError: (error) {
          debugPrint(
            'Alwan AI speech error: ${error.errorMsg}; '
            'permanent=${error.permanent}',
          );
          if (!mounted) return;
          setState(() => _listening = false);
          _showMessage(_speechErrorMessage(error.errorMsg));
        },
      );
      _speechInitialized = available;
      return available;
    } catch (error, stackTrace) {
      debugPrint('Alwan AI speech initialization failed: $error\n$stackTrace');
      return false;
    }
  }

  Future<void> _submitRecognizedSpeech() async {
    if (!mounted || _voiceSubmitted || _busy) return;
    final words = _lastRecognizedWords.trim();
    if (words.isEmpty) return;
    _voiceSubmitted = true;
    await _submit(words, fromVoice: true);
  }

  String _speechErrorMessage(String errorCode) {
    final normalized = errorCode.toLowerCase();
    if (normalized.contains('permission') ||
        normalized.contains('denied') ||
        normalized.contains('notallowed') ||
        normalized.contains('not_allowed')) {
      return 'اسمح لتطبيق ألوان باستخدام الميكروفون من إعدادات الجهاز ثم حاول مجددًا.';
    }
    if (normalized.contains('network')) {
      return 'تعذر الوصول إلى خدمة التعرف الصوتي. تحقق من الإنترنت وحاول مجددًا.';
    }
    if (normalized.contains('no_match') ||
        normalized.contains('no-speech')) {
      return 'لم أتمكن من سماع العبارة بوضوح. اقترب من الميكروفون وحاول مجددًا.';
    }
    if (normalized.contains('audio') ||
        normalized.contains('client') ||
        normalized.contains('unavailable') ||
        normalized.contains('not_supported')) {
      return 'الميكروفون أو التعرف الصوتي غير متاح في هذا الجهاز أو المتصفح. جرّب Chrome أو Edge واسمح بالميكروفون.';
    }
    if (normalized.contains('busy')) {
      return 'الميكروفون مستخدم حاليًا من تطبيق آخر. أغلقه هناك ثم حاول مجددًا.';
    }
    return 'تعذر قراءة الصوت من ميكروفون الجهاز. حاول مجددًا.';
  }

  Future<void> _submitFromComposer() {
    return _submit(_textController.text);
  }

  Future<void> _submit(String rawText, {bool fromVoice = false}) async {
    final text = rawText.trim();
    if (text.isEmpty || _busy) return;

    await _speech.stop();
    if (!mounted) return;
    setState(() {
      _listening = false;
      _busy = true;
      _textController.clear();
      _messages.add(
        AlwanAiMessage(
          id: _nextMessageId(),
          role: AlwanAiMessageRole.user,
          text: text,
        ),
      );
    });
    _scrollToEnd();

    try {
      final command = await _commands.resolve(text);
      if (command.handled) {
        await _executeCommand(command);
        return;
      }

      if (_mode == AlwanAiMode.search) {
        final results = await _commands.search(text);
        if (!mounted) return;
        setState(() {
          _searchResults = results;
          _messages.add(
            AlwanAiMessage(
              id: _nextMessageId(),
              role: AlwanAiMessageRole.assistant,
              text: results.isEmpty
                  ? 'لم أجد نتيجة محلية مطابقة. جرّب اسم برنامج أو إذاعة أو واجهة.'
                  : 'وجدت ${results.length} نتائج داخل تطبيق ألوان.',
            ),
          );
        });
        return;
      }

      final gateway = ref.read(alwanAiGatewayProvider);
      final response = switch (_mode) {
        AlwanAiMode.chat => await gateway.chat(
          message: text,
          voiceReply: fromVoice,
        ),
        AlwanAiMode.image => await gateway.generateImage(text),
        AlwanAiMode.music => await gateway.generateMusic(
          prompt: text,
          fullSong: true,
        ),
        AlwanAiMode.search => throw StateError('وضع البحث محلي'),
      };

      if (!mounted) return;
      setState(() {
        _messages.add(
          AlwanAiMessage(
            id: _nextMessageId(),
            role: AlwanAiMessageRole.assistant,
            text: response.text,
            imageUrl: response.imageUrl,
            audioUrl: response.audioUrl,
            mediaTitle: response.title,
          ),
        );
      });

      if (fromVoice && response.audioUrl?.isNotEmpty == true) {
        await _playGeneratedAudio(
          response.audioUrl!,
          response.title ?? 'رد ألوان AI الصوتي',
        );
      }
    } on AlwanAiGatewayException catch (error) {
      _addAssistantMessage(error.message);
    } catch (_) {
      _addAssistantMessage('حدث خطأ غير متوقع. حاول مرة أخرى.');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        _scrollToEnd();
      }
    }
  }

  Future<void> _executeCommand(AlwanAiCommandResult command) async {
    try {
      switch (command.type) {
        case AlwanAiCommandType.navigate:
          _addAssistantMessage(command.message);
          if (!mounted || command.routeName == null) return;
          if (command.routeName == AppRoutes.home) {
            context.goNamed(
              command.routeName!,
              pathParameters: command.pathParameters,
              queryParameters: command.queryParameters,
            );
          } else {
            context.pushNamed(
              command.routeName!,
              pathParameters: command.pathParameters,
              queryParameters: command.queryParameters,
            );
          }
          break;
        case AlwanAiCommandType.play:
          if (command.track != null) {
            await ref.read(audioControllerProvider).play(command.track!);
          }
          _addAssistantMessage(command.message);
          if (mounted && command.track != null) {
            context.pushNamed(AppRoutes.player);
          }
          break;
        case AlwanAiCommandType.pause:
          await ref.read(audioControllerProvider).pause();
          _addAssistantMessage(command.message);
          break;
        case AlwanAiCommandType.resume:
          await ref.read(audioControllerProvider).resume();
          _addAssistantMessage(command.message);
          break;
        case AlwanAiCommandType.stop:
          await ref.read(audioControllerProvider).stop();
          _addAssistantMessage(command.message);
          break;
        case AlwanAiCommandType.next:
          await ref.read(audioControllerProvider).next();
          _addAssistantMessage(command.message);
          break;
        case AlwanAiCommandType.previous:
          await ref.read(audioControllerProvider).previous();
          _addAssistantMessage(command.message);
          break;
        case AlwanAiCommandType.none:
          break;
      }
    } catch (_) {
      _addAssistantMessage('تعذر تنفيذ الأمر الصوتي حاليًا.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openSearchResult(AlwanAiSearchResult result) async {
    if (result.kind == AlwanAiSearchKind.destination &&
        result.routeName != null) {
      if (result.routeName == AppRoutes.home) {
        context.goNamed(
          result.routeName!,
          pathParameters: result.pathParameters,
          queryParameters: result.queryParameters,
        );
      } else {
        context.pushNamed(
          result.routeName!,
          pathParameters: result.pathParameters,
          queryParameters: result.queryParameters,
        );
      }
      return;
    }
    if (result.track != null) {
      await ref.read(audioControllerProvider).play(result.track!);
      if (mounted) _showMessage('تم تشغيل ${result.track!.title}');
    }
  }

  Future<void> _playGeneratedAudio(String url, String title) {
    return ref
        .read(audioControllerProvider)
        .play(
          AudioTrack(
            id: 'alwan-ai-${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            subtitle: 'تم إنشاؤه بواسطة ألوان AI',
            url: url,
            sourceType: AudioSourceType.music,
            category: 'ألوان AI',
          ),
        );
  }

  void _addAssistantMessage(String message) {
    if (!mounted) return;
    setState(() {
      _messages.add(
        AlwanAiMessage(
          id: _nextMessageId(),
          role: AlwanAiMessageRole.assistant,
          text: message,
        ),
      );
    });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final gatewayReady = ref.watch(alwanAiGatewayProvider).isConfigured;
    final compact = MediaQuery.sizeOf(context).width < 620;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'رجوع',
          onPressed: () => context.canPop()
              ? context.pop()
              : context.goNamed(AppRoutes.home),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: _aiInk),
        ),
        title: const Text(
          'ألوان AI',
          style: TextStyle(fontWeight: FontWeight.w700, color: _aiInk),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 14),
            child: _ConnectionBadge(connected: gatewayReady),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        compact ? 14 : 24,
                        14,
                        compact ? 14 : 24,
                        10,
                      ),
                      child: Column(
                        children: [
                          _AiHero(compact: compact),
                          const SizedBox(height: 12),
                          _ModeSelector(selected: _mode, onSelected: _setMode),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(
                          compact ? 14 : 24,
                          4,
                          compact ? 14 : 24,
                          16,
                        ),
                        children: [
                          ..._messages.map(
                            (message) => _MessageBubble(
                              message: message,
                              onPlayAudio: message.audioUrl == null
                                  ? null
                                  : () => _playGeneratedAudio(
                                      message.audioUrl!,
                                      message.mediaTitle ?? 'صوت ألوان AI',
                                    ),
                            ),
                          ),
                          if (_searchResults.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            ..._searchResults.map(
                              (result) => _SearchResultCard(
                                result: result,
                                onTap: () => _openSearchResult(result),
                              ),
                            ),
                          ],
                          if (_busy) const _ThinkingBubble(),
                        ],
                      ),
                    ),
                    _Composer(
                      controller: _textController,
                      mode: _mode,
                      busy: _busy,
                      listening: _listening,
                      onMic: _toggleListening,
                      onSend: _submitFromComposer,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }
}

class _AiHero extends StatelessWidget {
  const _AiHero({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 16 : 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [_aiPurple, _aiBlue, _aiCyan],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x336C27D9),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 58 : 72,
            height: compact ? 58 : 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: .35)),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: compact ? 30 : 38,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مساعدك الذكي داخل ألوان',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'ابحث، تحدّث، أنشئ صورة أو أغنية، وتحكّم في التطبيق بصوتك',
                  style: TextStyle(
                    color: Color(0xFFEFEAFF),
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
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

class _ModeSelector extends StatelessWidget {
  const _ModeSelector({required this.selected, required this.onSelected});

  final AlwanAiMode selected;
  final ValueChanged<AlwanAiMode> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = <(AlwanAiMode, String, IconData)>[
      (AlwanAiMode.search, 'بحث سريع', Icons.search_rounded),
      (AlwanAiMode.chat, 'دردشة صوتية', Icons.graphic_eq_rounded),
      (AlwanAiMode.image, 'توليد صورة', Icons.image_outlined),
      (AlwanAiMode.music, 'توليد أغنية', Icons.music_note_rounded),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map((item) {
              final active = selected == item.$1;
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  selected: active,
                  showCheckmark: false,
                  avatar: Icon(
                    item.$3,
                    size: 18,
                    color: active ? Colors.white : _aiPurple,
                  ),
                  label: Text(item.$2),
                  labelStyle: TextStyle(
                    color: active ? Colors.white : _aiInk,
                    fontWeight: FontWeight.w700,
                  ),
                  selectedColor: _aiPurple,
                  backgroundColor: Colors.white,
                  side: BorderSide(
                    color: active ? _aiPurple : const Color(0xFFE1DDF6),
                  ),
                  onSelected: (_) => onSelected(item.$1),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, this.onPlayAudio});

  final AlwanAiMessage message;
  final VoidCallback? onPlayAudio;

  @override
  Widget build(BuildContext context) {
    final user = message.role == AlwanAiMessageRole.user;
    return Align(
      alignment: user
          ? AlignmentDirectional.centerStart
          : AlignmentDirectional.centerEnd,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 690),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: user ? _aiPurple : Colors.white,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(20),
            topEnd: const Radius.circular(20),
            bottomStart: Radius.circular(user ? 5 : 20),
            bottomEnd: Radius.circular(user ? 20 : 5),
          ),
          border: user ? null : Border.all(color: const Color(0xFFE7E3F6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D171247),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: user ? Colors.white : _aiInk,
                height: 1.55,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (message.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: _GeneratedImage(source: message.imageUrl!),
                ),
              ),
            ],
            if (onPlayAudio != null) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: onPlayAudio,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(message.mediaTitle ?? 'تشغيل النتيجة الصوتية'),
                style: FilledButton.styleFrom(backgroundColor: _aiBlue),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GeneratedImage extends StatelessWidget {
  const _GeneratedImage({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    Widget errorBuilder(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
    ) {
      return const ColoredBox(
        color: _aiSurface,
        child: Center(child: Icon(Icons.broken_image_outlined)),
      );
    }

    if (source.startsWith('data:image/')) {
      try {
        final separator = source.indexOf(',');
        final bytes = base64Decode(source.substring(separator + 1));
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: errorBuilder,
        );
      } catch (_) {
        return errorBuilder(context, const FormatException(), null);
      }
    }

    return Image.network(source, fit: BoxFit.cover, errorBuilder: errorBuilder);
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.result, required this.onTap});

  final AlwanAiSearchResult result;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final destination = result.kind == AlwanAiSearchKind.destination;
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE7E3F6)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: _aiSurface,
          foregroundColor: _aiPurple,
          child: Icon(
            destination ? Icons.open_in_new_rounded : Icons.play_arrow_rounded,
          ),
        ),
        title: Text(
          result.title,
          style: const TextStyle(color: _aiInk, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(result.subtitle),
        trailing: Icon(
          destination ? Icons.arrow_back_ios_new_rounded : Icons.graphic_eq,
          color: _aiPurple,
          size: 18,
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: _aiPurple),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.mode,
    required this.busy,
    required this.listening,
    required this.onMic,
    required this.onSend,
  });

  final TextEditingController controller;
  final AlwanAiMode mode;
  final bool busy;
  final bool listening;
  final VoidCallback onMic;
  final VoidCallback onSend;

  String get _hint => switch (mode) {
    AlwanAiMode.chat => 'اكتب سؤالك أو اطلب أمرًا داخل التطبيق…',
    AlwanAiMode.search => 'ابحث عن واجهة، برنامج، إذاعة أو ملف صوتي…',
    AlwanAiMode.image => 'صف الصورة التي تريد إنشاءها…',
    AlwanAiMode.music => 'صف الأغنية أو الموسيقى التي تريدها…',
  };

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  color: listening ? const Color(0xFFE63557) : _aiPurple,
                  shape: BoxShape.circle,
                  boxShadow: listening
                      ? const [
                          BoxShadow(color: Color(0x55E63557), blurRadius: 14),
                        ]
                      : const [],
                ),
                child: IconButton(
                  key: const ValueKey('alwan-ai-microphone'),
                  tooltip: listening ? 'إيقاف الاستماع' : 'أمر صوتي',
                  onPressed: onMic,
                  color: Colors.white,
                  icon: Icon(
                    listening ? Icons.stop_rounded : Icons.mic_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  key: const ValueKey('alwan-ai-input'),
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: busy ? null : (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: listening ? 'أنا أستمع إليك الآن…' : _hint,
                    filled: true,
                    fillColor: _aiSurface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                key: const ValueKey('alwan-ai-send'),
                tooltip: 'إرسال',
                onPressed: busy ? null : onSend,
                style: IconButton.styleFrom(backgroundColor: _aiBlue),
                icon: const Icon(Icons.arrow_upward_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  const _ConnectionBadge({required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final color = connected ? const Color(0xFF15986C) : const Color(0xFFE18822);
    return Tooltip(
      message: connected
          ? 'خدمات الذكاء السحابية متصلة'
          : 'الأوامر المحلية تعمل، والخدمات السحابية تحتاج إعداد الخادم',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(Icons.circle, size: 8, color: color),
            const SizedBox(width: 5),
            Text(
              connected ? 'متصل' : 'محلي',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
