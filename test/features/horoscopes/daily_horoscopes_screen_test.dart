import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alwan_hub/features/horoscopes/presentation/daily_horoscopes_screen.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('ar'),
          supportedLocales: [Locale('ar'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: DailyHoroscopesScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('renders the twelve daily zodiac signs on a phone', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('الأبراج اليومية'), findsOneWidget);
    expect(find.byKey(const ValueKey('horoscope-aries')), findsOneWidget);
    expect(find.byKey(const ValueKey('horoscope-pisces')), findsOneWidget);
    expect(find.textContaining('محتوى الأبراج ترفيهي'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens detailed horoscope information', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byKey(const ValueKey('horoscope-aries')));
    await tester.pumpAndSettle();

    expect(find.text('الحب والعلاقات'), findsOneWidget);
    expect(find.text('العمل والمال'), findsOneWidget);
    expect(find.text('الصحة والطاقة'), findsOneWidget);
    expect(find.text('نصيحة اليوم'), findsOneWidget);
    expect(find.text('رقم الحظ'), findsOneWidget);
    expect(find.text('لون الحظ'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
