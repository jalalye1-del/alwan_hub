import 'package:alwan_hub/features/games/presentation/pages/games_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpGamesScreen(WidgetTester tester) async {
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
          home: GamesScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('shows the contests experience on a phone', (tester) async {
    await pumpGamesScreen(tester);

    expect(find.text('مسابقات وألعاب ألوان'), findsOneWidget);
    expect(find.bySemanticsLabel('بنر إعلاني'), findsOneWidget);
    expect(find.text('المسابقات'), findsOneWidget);
    expect(find.text('الألعاب والتسلية'), findsOneWidget);
    expect(find.text('مسابقات برامج الـ FM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switches to the interactive games tab', (tester) async {
    await pumpGamesScreen(tester);

    await tester.tap(find.text('الألعاب والتسلية'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('ألعاب ألوان التفاعلية'), findsOneWidget);
    expect(find.text('لعبة إكس أو التفاعلية'), findsOneWidget);
    expect(find.text('لعبة مطابقة الذاكرة'), findsOneWidget);
    expect(find.text('تخمين الكلمات والبرامج'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows Sin Jeem categories when its filter is selected', (
    tester,
  ) async {
    await pumpGamesScreen(tester);

    await tester.ensureVisible(find.text('مسابقة سين جيم'));
    await tester.pump();
    await tester.tap(find.text('مسابقة سين جيم'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('التاريخ والجغرافيا'), findsOneWidget);
    expect(find.text('العلوم والطبيعة'), findsOneWidget);
    expect(find.text('الدين واللغات'), findsOneWidget);
    expect(find.text('الفنون والرياضة'), findsOneWidget);
    expect(find.text('المرحلة الثانية • اختر التصنيف'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
