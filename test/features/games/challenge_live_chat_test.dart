import 'package:alwan_hub/features/games/data/challenge_chat_service.dart';
import 'package:alwan_hub/features/games/presentation/widgets/challenge_live_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sends a text message and publishes a dashboard-ready payload', (
    tester,
  ) async {
    final service = ChallengeChatService();
    Map<String, dynamic>? publishedPayload;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ChallengeLiveChatCard(
              roomId: 'widget-room',
              currentUserName: 'ياسمين',
              chatService: service,
              onPublish: (payload) async => publishedPayload = payload,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'أنا جاهزة للتحدي');
    await tester.tap(find.byTooltip('إرسال رسالة نصية'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('أنا جاهزة للتحدي'), findsOneWidget);
    expect(publishedPayload?['roomId'], 'widget-room');
    expect(publishedPayload?['type'], 'text');
    expect(publishedPayload?['text'], 'أنا جاهزة للتحدي');
    expect(find.text('1 متصل الآن'), findsOneWidget);
  });
}
