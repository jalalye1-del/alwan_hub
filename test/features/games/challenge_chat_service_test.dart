import 'package:alwan_hub/features/games/data/challenge_chat_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'broadcasts text and voice messages to every watcher in one room',
    () async {
      final service = ChallengeChatService();
      service.joinRoom('shared-room');

      final nextState = service.watchRoom('shared-room').skip(1).first;
      final voiceMessage = ChallengeChatMessage(
        id: 'voice-1',
        roomId: 'shared-room',
        author: 'المتحدي الأول',
        sentAt: DateTime(2026, 8, 7, 12, 30),
        audioPath: 'https://example.com/challenge-message.wav',
        audioDuration: const Duration(seconds: 7),
      );

      await service.publish(voiceMessage);
      final state = await nextState;

      expect(state.messages, hasLength(1));
      expect(state.messages.single.isVoice, isTrue);
      expect(state.messages.single.audioDuration, const Duration(seconds: 7));
      expect(state.onlineCount, 1);
    },
  );

  test('maps incoming dashboard chat payloads into the live room', () async {
    final service = ChallengeChatService();
    final nextState = service.watchRoom('dashboard-room').skip(1).first;

    await service.receiveDashboardMessage({
      'id': 'server-message',
      'roomId': 'dashboard-room',
      'author': 'أحمد',
      'sentAt': '2026-08-07T12:30:00.000Z',
      'type': 'text',
      'text': 'وصلت الرسالة مباشرة',
    });

    final state = await nextState;
    expect(state.messages.single.text, 'وصلت الرسالة مباشرة');
    expect(state.messages.single.author, 'أحمد');
  });
}
