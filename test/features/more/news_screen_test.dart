import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alwan_hub/features/more/presentation/pages/news_screen.dart';

void main() {
  testWidgets('opens with trending news selected', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('ar'),
        supportedLocales: [Locale('ar'), Locale('en')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: NewsScreen(initialCategory: NewsScreen.trendingCategory),
      ),
    );
    await tester.pump();

    final chip = tester.widget<ChoiceChip>(
      find.byKey(
        const ValueKey('news-category-${NewsScreen.trendingCategory}'),
      ),
    );
    expect(chip.selected, isTrue);
    expect(
      find.text('مهرجان ألوان للموسيقى العربية يعود في نسخته العاشرة'),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });
}
