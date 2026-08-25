import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alwan_hub/features/home/presentation/widgets/home_feature_links.dart';

void main() {
  testWidgets('shows the trending news and daily horoscopes links', (
    tester,
  ) async {
    var trendingNewsTapped = false;
    var dailyHoroscopesTapped = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(
            body: HomeFeatureLinks(
              onTrendingNewsTap: () => trendingNewsTapped = true,
              onDailyHoroscopesTap: () => dailyHoroscopesTapped = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('الأخبار الرائجة'), findsOneWidget);
    expect(find.text('الأبراج اليومية'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('trending_news-card')));
    await tester.tap(find.byKey(const ValueKey('daily_horoscopes-card')));

    expect(trendingNewsTapped, isTrue);
    expect(dailyHoroscopesTapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
