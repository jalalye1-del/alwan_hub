import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:alwan_hub/features/alwan_ai/application/alwan_ai_command_service.dart';
import 'package:alwan_hub/features/alwan_ai/presentation/alwan_ai_screen.dart';

void main() {
  testWidgets('shows quick search as the first and selected category', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: AlwanAiScreen()),
      ),
    );
    await tester.pump();

    final chips = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .toList(growable: false);
    final firstLabel = chips.first.label as Text;

    expect(firstLabel.data, 'بحث سريع');
    expect(chips.first.selected, isTrue);
  });

  testWidgets('executes a conversational navigation command', (tester) async {
    final service = AlwanAiCommandService(loadMediaCatalog: () async => const []);
    final router = GoRouter(
      initialLocation: '/assistant',
      routes: [
        GoRoute(
          path: '/assistant',
          builder: (context, state) => AlwanAiScreen(commandService: service),
        ),
        GoRoute(
          path: '/news',
          name: 'more-news',
          builder: (context, state) => Scaffold(
            body: Text(
              'واجهة ${state.uri.queryParameters['category']}',
            ),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    await tester.enterText(
      find.byKey(const ValueKey('alwan-ai-input')),
      'قم بفتح الأخبار الرائجة',
    );
    await tester.tap(find.byKey(const ValueKey('alwan-ai-send')));
    await tester.pumpAndSettle();

    expect(find.text('واجهة الأخبار الرائجة'), findsOneWidget);
  });
}
