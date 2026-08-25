import 'dart:async';

import 'package:flutter/foundation.dart';

/// A text or voice message exchanged inside a challenge room.
class ChallengeChatMessage {
  const ChallengeChatMessage({
    required this.id,
    required this.roomId,
    required this.author,
    required this.sentAt,
    this.text,
    this.audioPath,
    this.audioDuration = Duration.zero,
    this.isMine = false,
  });

  final String id;
  final String roomId;
  final String author;
  final DateTime sentAt;
  final String? text;
  final String? audioPath;
  final Duration audioDuration;
  final bool isMine;

  bool get isVoice => audioPath != null && audioPath!.isNotEmpty;

  ChallengeChatMessage copyWith({bool? isMine}) {
    return ChallengeChatMessage(
      id: id,
      roomId: roomId,
      author: author,
      sentAt: sentAt,
      text: text,
      audioPath: audioPath,
      audioDuration: audioDuration,
      isMine: isMine ?? this.isMine,
    );
  }

  Map<String, dynamic> toDashboardJson() => {
    'id': id,
    'roomId': roomId,
    'author': author,
    'sentAt': sentAt.toUtc().toIso8601String(),
    'type': isVoice ? 'voice' : 'text',
    'text': text,
    'audioPath': audioPath,
    'audioDurationMs': audioDuration.inMilliseconds,
  };

  factory ChallengeChatMessage.fromDashboardJson(
    Map<String, dynamic> json, {
    String? currentUserName,
  }) {
    final author = json['author']?.toString() ?? 'مستخدم ألوان';
    return ChallengeChatMessage(
      id:
          json['id']?.toString() ??
          'message-${DateTime.now().microsecondsSinceEpoch}',
      roomId: json['roomId']?.toString() ?? '',
      author: author,
      sentAt:
          DateTime.tryParse(json['sentAt']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      text: json['text']?.toString(),
      audioPath: json['audioUrl']?.toString() ?? json['audioPath']?.toString(),
      audioDuration: Duration(
        milliseconds:
            int.tryParse(json['audioDurationMs']?.toString() ?? '') ?? 0,
      ),
      isMine: currentUserName != null && author == currentUserName,
    );
  }
}

@immutable
class ChallengeChatRoomState {
  const ChallengeChatRoomState({
    required this.messages,
    required this.onlineCount,
  });

  final List<ChallengeChatMessage> messages;
  final int onlineCount;
}

/// App-wide live room store for the games experience.
///
/// Every mounted screen in the same room receives additions immediately. A
/// future WebSocket/dashboard adapter can feed server messages through
/// [receiveDashboardMessage] without changing the presentation layer.
class ChallengeChatService {
  ChallengeChatService();

  static final ChallengeChatService instance = ChallengeChatService();

  final Map<String, List<ChallengeChatMessage>> _roomMessages = {};
  final Map<String, int> _roomMembers = {};
  final Map<String, StreamController<ChallengeChatRoomState>> _controllers = {};

  StreamController<ChallengeChatRoomState> _controllerFor(String roomId) {
    return _controllers.putIfAbsent(
      roomId,
      () => StreamController<ChallengeChatRoomState>.broadcast(),
    );
  }

  ChallengeChatRoomState roomState(String roomId) {
    return ChallengeChatRoomState(
      messages: List.unmodifiable(_roomMessages[roomId] ?? const []),
      onlineCount: _roomMembers[roomId] ?? 0,
    );
  }

  Stream<ChallengeChatRoomState> watchRoom(String roomId) {
    final roomController = _controllerFor(roomId);
    return Stream<ChallengeChatRoomState>.multi((listener) {
      listener.add(roomState(roomId));
      final subscription = roomController.stream.listen(
        listener.add,
        onError: listener.addError,
      );
      listener.onCancel = subscription.cancel;
    });
  }

  void joinRoom(
    String roomId, {
    Iterable<ChallengeChatMessage> seedMessages = const [],
  }) {
    final messages = _roomMessages.putIfAbsent(roomId, () => []);
    if (messages.isEmpty) {
      messages.addAll(
        seedMessages.where((message) => message.roomId == roomId),
      );
    }
    _roomMembers[roomId] = (_roomMembers[roomId] ?? 0) + 1;
    _emit(roomId);
  }

  void leaveRoom(String roomId) {
    final members = _roomMembers[roomId] ?? 0;
    _roomMembers[roomId] = members > 0 ? members - 1 : 0;
    _emit(roomId);
  }

  Future<void> publish(ChallengeChatMessage message) async {
    final messages = _roomMessages.putIfAbsent(message.roomId, () => []);
    final existingIndex = messages.indexWhere(
      (entry) => entry.id == message.id,
    );
    if (existingIndex == -1) {
      messages.add(message);
    } else {
      messages[existingIndex] = message;
    }
    messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    _emit(message.roomId);
  }

  Future<void> receiveDashboardMessage(
    Map<String, dynamic> payload, {
    String? currentUserName,
  }) {
    return publish(
      ChallengeChatMessage.fromDashboardJson(
        payload,
        currentUserName: currentUserName,
      ),
    );
  }

  @visibleForTesting
  void clear() {
    _roomMessages.clear();
    _roomMembers.clear();
    for (final roomId in _controllers.keys.toList(growable: false)) {
      _emit(roomId);
    }
  }

  void _emit(String roomId) {
    final controller = _controllers[roomId];
    if (controller == null || controller.isClosed) return;
    controller.add(roomState(roomId));
  }
}
