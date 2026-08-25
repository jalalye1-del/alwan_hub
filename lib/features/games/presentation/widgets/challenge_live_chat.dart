import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:alwan_hub/core/localization/localized_text.dart';
import 'package:alwan_hub/features/games/data/challenge_chat_service.dart';

const _font = 'MohammadBoldArt';
const _ink = Color(0xFF17164F);
const _blue = Color(0xFF334FEA);
const _purple = Color(0xFF8E2DE2);
const _muted = Color(0xFF73788F);
const _line = Color(0xFFE4E7F3);

class ChallengeLiveChatCard extends StatefulWidget {
  const ChallengeLiveChatCard({
    super.key,
    required this.roomId,
    required this.currentUserName,
    this.onPublish,
    this.chatService,
  });

  final String roomId;
  final String currentUserName;

  /// A WebSocket/API adapter can publish this dashboard-ready payload.
  final Future<void> Function(Map<String, dynamic> payload)? onPublish;

  /// Defaults to the shared app room, while tests and integrations can inject
  /// an isolated service.
  final ChallengeChatService? chatService;

  @override
  State<ChallengeLiveChatCard> createState() => _ChallengeLiveChatCardState();
}

class _ChallengeLiveChatCardState extends State<ChallengeLiveChatCard> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _recorder = AudioRecorder();
  final List<ChallengeChatMessage> _messages = [];
  late final ChallengeChatService _chatService;
  StreamSubscription<ChallengeChatRoomState>? _roomSubscription;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  bool _recording = false;
  bool _recordingBusy = false;
  int _onlineCount = 0;

  @override
  void initState() {
    super.initState();
    _chatService = widget.chatService ?? ChallengeChatService.instance;
    final seedMessages = [
      ChallengeChatMessage(
        id: 'welcome',
        roomId: widget.roomId,
        author: 'مريم المطيري',
        text: 'أهلاً بكم في حلبة التحدي! شاركونا حماسكم 🎉',
        sentAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ChallengeChatMessage(
        id: 'challenger',
        roomId: widget.roomId,
        author: 'أحمد اليماني',
        text: 'جاهز للتحدي، من ينافسني اليوم؟ 😎',
        sentAt: DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ];
    _chatService.joinRoom(widget.roomId, seedMessages: seedMessages);
    _roomSubscription = _chatService.watchRoom(widget.roomId).listen((room) {
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(
            room.messages.map(
              (message) => message.copyWith(
                isMine: message.author == widget.currentUserName,
              ),
            ),
          );
        _onlineCount = room.onlineCount;
      });
      _scrollToEnd();
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    unawaited(_roomSubscription?.cancel());
    _chatService.leaveRoom(widget.roomId);
    _messageController.dispose();
    _scrollController.dispose();
    unawaited(_recorder.dispose());
    super.dispose();
  }

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

  Future<void> _publish(ChallengeChatMessage message) async {
    await _chatService.publish(message);
    final callback = widget.onPublish;
    if (callback != null) await callback(message.toDashboardJson());
  }

  Future<void> _sendText() async {
    final value = _messageController.text.trim();
    if (value.isEmpty) return;
    final message = ChallengeChatMessage(
      id: 'text-${DateTime.now().microsecondsSinceEpoch}',
      roomId: widget.roomId,
      author: widget.currentUserName,
      text: value,
      sentAt: DateTime.now(),
      isMine: true,
    );
    _messageController.clear();
    try {
      await _publish(message);
    } catch (_) {
      if (mounted) _showMessage('تعذر إرسال الرسالة، حاول مرة أخرى');
    }
  }

  Future<void> _toggleRecording() async {
    if (_recordingBusy) return;
    setState(() => _recordingBusy = true);
    try {
      if (_recording) {
        final recordedPath = await _recorder.stop();
        _recordingTimer?.cancel();
        if (!mounted) return;
        final duration = _recordingDuration;
        setState(() {
          _recording = false;
          _recordingDuration = Duration.zero;
        });
        if (recordedPath == null || recordedPath.isEmpty) {
          _showMessage('تعذر حفظ الرسالة الصوتية');
          return;
        }
        final message = ChallengeChatMessage(
          id: 'voice-${DateTime.now().microsecondsSinceEpoch}',
          roomId: widget.roomId,
          author: widget.currentUserName,
          audioPath: recordedPath,
          audioDuration: duration,
          sentAt: DateTime.now(),
          isMine: true,
        );
        try {
          await _publish(message);
        } catch (_) {
          if (mounted) _showMessage('تعذر إرسال الرسالة الصوتية');
        }
        return;
      }

      if (!await _recorder.hasPermission()) {
        if (mounted) _showMessage('يلزم السماح باستخدام الميكروفون');
        return;
      }
      final recordingPath = await _createRecordingPath();
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
          echoCancel: true,
          noiseSuppress: true,
        ),
        path: recordingPath,
      );
      if (!mounted) return;
      setState(() {
        _recording = true;
        _recordingDuration = Duration.zero;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() => _recordingDuration += const Duration(seconds: 1));
      });
    } catch (_) {
      if (mounted) _showMessage('تعذر تشغيل تسجيل الرسالة الصوتية');
    } finally {
      if (mounted) setState(() => _recordingBusy = false);
    }
  }

  Future<String> _createRecordingPath() async {
    final fileName =
        'challenge_voice_${DateTime.now().millisecondsSinceEpoch}.wav';
    if (kIsWeb) return fileName;
    final directory = await getTemporaryDirectory();
    return path.join(directory.path, fileName);
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  String _durationLabel(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _timeLabel(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.forum_rounded, color: _blue, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'دردشة المتحدين المباشرة',
                  style: TextStyle(
                    fontFamily: _font,
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.circle, color: Color(0xFF22B99A), size: 10),
              const SizedBox(width: 5),
              Text(
                '$_onlineCount متصل الآن',
                style: const TextStyle(
                  fontFamily: _font,
                  color: Color(0xFF168F7B),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 240,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FD),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _line),
            ),
            child: ListView.separated(
              controller: _scrollController,
              itemCount: _messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 9),
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isMine
                      ? AlignmentDirectional.centerStart
                      : AlignmentDirectional.centerEnd,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 290),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: message.isMine
                          ? _blue.withValues(alpha: .09)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: message.isMine
                            ? _blue.withValues(alpha: .22)
                            : _line,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.author,
                          style: TextStyle(
                            fontFamily: _font,
                            color: message.isMine ? _blue : _purple,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        if (message.audioPath != null)
                          _VoiceMessagePlayer(
                            source: message.audioPath!,
                            duration: message.audioDuration,
                          )
                        else
                          Text(
                            message.text ?? '',
                            style: const TextStyle(
                              fontFamily: _font,
                              color: _ink,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        const SizedBox(height: 3),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            _timeLabel(message.sentAt),
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              fontFamily: _font,
                              color: _muted,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 11),
          if (_recording)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.mic_rounded, color: Color(0xFFE34262)),
                  const SizedBox(width: 7),
                  Text(
                    'جارٍ التسجيل ${_durationLabel(_recordingDuration)}',
                    style: const TextStyle(
                      fontFamily: _font,
                      color: Color(0xFFE34262),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'اضغط للإرسال',
                    style: TextStyle(
                      fontFamily: _font,
                      color: _muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendText(),
                  style: const TextStyle(fontFamily: _font, color: _ink),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالة للتحدي...',
                    hintStyle: const TextStyle(
                      fontFamily: _font,
                      color: _muted,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F8FC),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _sendText,
                tooltip: 'إرسال رسالة نصية',
                style: IconButton.styleFrom(backgroundColor: _blue),
                icon: const Icon(Icons.send_rounded, color: Colors.white),
              ),
              const SizedBox(width: 5),
              IconButton.filled(
                onPressed: _recordingBusy ? null : _toggleRecording,
                tooltip: _recording
                    ? 'إيقاف وإرسال الرسالة الصوتية'
                    : 'تسجيل رسالة صوتية',
                style: IconButton.styleFrom(
                  backgroundColor: _recording
                      ? const Color(0xFFE34262)
                      : _purple,
                ),
                icon: Icon(
                  _recording ? Icons.stop_rounded : Icons.mic_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoiceMessagePlayer extends StatefulWidget {
  const _VoiceMessagePlayer({required this.source, required this.duration});

  final String source;
  final Duration duration;

  @override
  State<_VoiceMessagePlayer> createState() => _VoiceMessagePlayerState();
}

class _VoiceMessagePlayerState extends State<_VoiceMessagePlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      setState(() => _playing = state.playing);
    });
  }

  @override
  void dispose() {
    unawaited(_player.dispose());
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
      return;
    }
    if (_player.audioSource == null) {
      final uri = Uri.tryParse(widget.source);
      if (kIsWeb || (uri?.hasScheme ?? false)) {
        await _player.setUrl(widget.source);
      } else {
        await _player.setFilePath(widget.source);
      }
    }
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
    }
    await _player.play();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = widget.duration.inMinutes.toString().padLeft(2, '0');
    final seconds = widget.duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _toggle,
          visualDensity: VisualDensity.compact,
          icon: Icon(
            _playing ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
            color: _purple,
            size: 29,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.graphic_eq_rounded, color: _blue, size: 42),
        const SizedBox(width: 7),
        Text(
          '$minutes:$seconds',
          style: const TextStyle(
            fontFamily: _font,
            color: _muted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
