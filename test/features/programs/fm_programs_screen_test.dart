import 'package:alwan_hub/features/programs/presentation/pages/fm_programs_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpProgramsScreen(WidgetTester tester, Size logicalSize) async {
    tester.view
      ..physicalSize = logicalSize
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('ar'),
          supportedLocales: [Locale('ar'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: FmProgramsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('renders the FM schedule without overflow on a phone', (
    tester,
  ) async {
    await pumpProgramsScreen(tester, const Size(390, 844));

    expect(find.text('برامج إذاعة ألوان FM'), findsOneWidget);
    expect(find.text('مواعيد البث'), findsOneWidget);
    expect(find.text('بيانات البرنامج'), findsOneWidget);
    expect(find.text('حوارات البرنامج'), findsOneWidget);
    expect(find.text('مواعيد الإعادة'), findsOneWidget);
    final liveStatus = find.byKey(
      const ValueKey('fm-broadcast-status-alwan-podcast'),
    );
    expect(liveStatus, findsOneWidget);
    expect(
      find.descendant(of: liveStatus, matching: find.text('مباشر')),
      findsOneWidget,
    );

    final saturdaySlot = find.byKey(const ValueKey('fm-broadcast-slot-السبت'));
    final sundayReplaySlot = find.byKey(const ValueKey('fm-replay-slot-الأحد'));
    final broadcastDay = find.descendant(
      of: saturdaySlot,
      matching: find.text('السبت'),
    );
    final broadcastTime = find.descendant(
      of: saturdaySlot,
      matching: find.text('01:00 PM'),
    );
    final replayDay = find.descendant(
      of: sundayReplaySlot,
      matching: find.text('الأحد'),
    );
    final replayTime = find.descendant(
      of: sundayReplaySlot,
      matching: find.text('10:30 PM'),
    );

    expect(
      tester.getBottomLeft(broadcastDay).dy,
      lessThanOrEqualTo(tester.getTopLeft(broadcastTime).dy),
    );
    expect(
      tester.getBottomLeft(replayDay).dy,
      lessThanOrEqualTo(tester.getTopLeft(replayTime).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the recorded status selected by the dashboard', (
    tester,
  ) async {
    await pumpProgramsScreen(tester, const Size(390, 844));

    await tester.tap(find.text('الأحد').first);
    await tester.pump(const Duration(milliseconds: 250));

    final recordedStatus = find.byKey(
      const ValueKey('fm-broadcast-status-alwan-doctor'),
    );
    expect(find.text('طبيب ألوان'), findsOneWidget);
    expect(recordedStatus, findsOneWidget);
    expect(
      find.descendant(of: recordedStatus, matching: find.text('مسجل')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the FM schedule readable on a very small phone', (
    tester,
  ) async {
    await pumpProgramsScreen(tester, const Size(320, 700));

    expect(find.text('برامج إذاعة ألوان FM'), findsOneWidget);
    expect(find.text('بودكاست ألوان'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('fm-broadcast-alwan-podcast')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders the complete FM schedule on a desktop width', (
    tester,
  ) async {
    await pumpProgramsScreen(tester, const Size(1180, 900));

    expect(find.text('بودكاست ألوان'), findsOneWidget);
    expect(find.text('طبيب ألوان'), findsNothing);
    expect(find.text('شعر وحنين'), findsNothing);
    expect(find.text('موعظة حسنة'), findsNothing);
    expect(
      find.byKey(const ValueKey('fm-broadcast-alwan-podcast')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
