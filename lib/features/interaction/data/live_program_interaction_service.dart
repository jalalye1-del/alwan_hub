import 'dart:async';

import 'package:flutter/foundation.dart';

/// رسالة دردشة مرتبطة ببرنامج FM محدد، قابلة للإرسال والاستقبال من اللوحة.
class LiveProgramChatMessage {
  const LiveProgramChatMessage({
    required this.id,
    required this.programId,
    required this.author,
    required this.sentAt,
    required this.text,
    this.isMine = false,
  });

  final String id;
  final String programId;
  final String author;
  final DateTime sentAt;
  final String text;
  final bool isMine;

  String get roomId => LiveProgramInteractionService.roomIdFor(programId);

  Map<String, dynamic> toDashboardJson() => {
    'type': 'live_program_chat_message',
    'id': id,
    'programId': programId,
    'roomId': roomId,
    'author': author,
    'text': text,
    'sentAt': sentAt.toUtc().toIso8601String(),
  };

  factory LiveProgramChatMessage.fromDashboardJson(
    Map<String, dynamic> json, {
    String currentUserName = 'مستمع ألوان',
  }) {
    final author = json['author']?.toString() ?? 'مستمع ألوان';
    return LiveProgramChatMessage(
      id:
          json['id']?.toString() ??
          'dashboard-${DateTime.now().microsecondsSinceEpoch}',
      programId:
          json['programId']?.toString() ??
          _programIdFromRoom(json['roomId']?.toString() ?? ''),
      author: author,
      text: json['text']?.toString().trim() ?? '',
      sentAt:
          DateTime.tryParse(json['sentAt']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
      isMine: author == currentUserName,
    );
  }

  static String _programIdFromRoom(String roomId) => roomId.startsWith('fm-')
      ? roomId.substring(3)
      : 'alwan-fm';
}

@immutable
class LiveProgramChatRoomState {
  const LiveProgramChatRoomState({required this.messages});

  final List<LiveProgramChatMessage> messages;
}

/// مخزن حي لغرف البرامج المباشرة.
///
/// يتلقى موصل لوحة التحكم الرسائل الواردة عبر [receiveDashboardEvent]، ويستمع
/// إلى [dashboardEvents] لإرسال رسائل المستمعين ورسائل المذيع والاستفتاءات.
class LiveProgramInteractionService {
  LiveProgramInteractionService();

  static final LiveProgramInteractionService instance =
      LiveProgramInteractionService();

  final Map<String, List<LiveProgramChatMessage>> _roomMessages = {};
  final Map<String, StreamController<LiveProgramChatRoomState>> _controllers =
      {};
  final StreamController<Map<String, dynamic>> _dashboardEventController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get dashboardEvents =>
      _dashboardEventController.stream;

  static String roomIdFor(String programId) => 'fm-$programId';

  LiveProgramChatRoomState roomState(String programId) {
    return LiveProgramChatRoomState(
      messages: List.unmodifiable(
        _roomMessages[roomIdFor(programId)] ?? const <LiveProgramChatMessage>[],
      ),
    );
  }

  Stream<LiveProgramChatRoomState> watchRoom(String programId) {
    final roomId = roomIdFor(programId);
    final controller = _controllerFor(roomId);
    return Stream<LiveProgramChatRoomState>.multi((listener) {
      listener.add(roomState(programId));
      final subscription = controller.stream.listen(
        listener.add,
        onError: listener.addError,
      );
      listener.onCancel = subscription.cancel;
    });
  }

  Future<void> publishChatMessage(LiveProgramChatMessage message) async {
    if (message.text.trim().isEmpty) return;
    final roomId = message.roomId;
    final messages = _roomMessages.putIfAbsent(roomId, () => []);
    final index = messages.indexWhere((item) => item.id == message.id);
    if (index == -1) {
      messages.add(message);
    } else {
      messages[index] = message;
    }
    messages.sort((first, second) => first.sentAt.compareTo(second.sentAt));
    _emit(roomId);
    _dashboardEventController.add(message.toDashboardJson());
  }

  Future<void> sendPresenterMessage({
    required String programId,
    required String text,
    String author = 'مستمع ألوان',
  }) async {
    final content = text.trim();
    if (content.isEmpty) return;
    _dashboardEventController.add({
      'type': 'live_program_presenter_message',
      'id': 'presenter-${DateTime.now().microsecondsSinceEpoch}',
      'programId': programId,
      'roomId': roomIdFor(programId),
      'author': author,
      'text': content,
      'sentAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> submitPoll({
    required String programId,
    required Map<String, int> answers,
  }) async {
    _dashboardEventController.add({
      'type': 'live_program_poll_submission',
      'id': 'poll-${DateTime.now().microsecondsSinceEpoch}',
      'programId': programId,
      'roomId': roomIdFor(programId),
      'answers': answers,
      'submittedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// نقطة إدخال موصل WebSocket/API الخاص بلوحة التحكم للرسائل الواردة.
  Future<void> receiveDashboardEvent(
    Map<String, dynamic> payload, {
    String currentUserName = 'مستمع ألوان',
  }) async {
    if (payload['type']?.toString() != 'live_program_chat_message') return;
    final message = LiveProgramChatMessage.fromDashboardJson(
      payload,
      currentUserName: currentUserName,
    );
    if (message.text.isEmpty) return;
    final roomId = message.roomId;
    final messages = _roomMessages.putIfAbsent(roomId, () => []);
    final index = messages.indexWhere((item) => item.id == message.id);
    if (index == -1) {
      messages.add(message);
    } else {
      messages[index] = message;
    }
    messages.sort((first, second) => first.sentAt.compareTo(second.sentAt));
    _emit(roomId);
  }

  @visibleForTesting
  void clear() {
    _roomMessages.clear();
    for (final roomId in _controllers.keys.toList(growable: false)) {
      _emit(roomId);
    }
  }

  StreamController<LiveProgramChatRoomState> _controllerFor(String roomId) {
    return _controllers.putIfAbsent(
      roomId,
      () => StreamController<LiveProgramChatRoomState>.broadcast(),
    );
  }

  void _emit(String roomId) {
    final controller = _controllers[roomId];
    if (controller == null || controller.isClosed) return;
    final programId = LiveProgramChatMessage._programIdFromRoom(roomId);
    controller.add(roomState(programId));
  }
}
