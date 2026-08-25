import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alwan_hub/features/alwan_ai/presentation/widgets/alwan_ai_floating_button.dart';

void main() {
  testWidgets('shows a compact circular Alwan AI button and opens it', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.centerRight,
            child: AlwanAiFloatingButton(onTap: () => tapped = true),
          ),
        ),
      ),
    );

    final button = find.byKey(const ValueKey('home-alwan-ai-floating-button'));
    expect(button, findsOneWidget);
    expect(tester.getSize(button), const Size.square(66));
    expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);

    await tester.tap(button);
    expect(tapped, isTrue);
  });
}
