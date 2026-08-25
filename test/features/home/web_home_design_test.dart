import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alwan_hub/features/home/presentation/web_home_design.dart';

void main() {
  testWidgets('uses the exact 1920x1080 reference canvas and working hotspots', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1920, 1080)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var homeTapped = false;
    var programsTapped = false;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: WebHomeDesign(
              onHomeTap: () => homeTapped = true,
              onProgramsTap: () => programsTapped = true,
              onStationsTap: () {},
              onLibraryTap: () {},
              onMoreTap: () {},
              onNotificationsTap: () {},
              onProfileTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('web-home-reference')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('web-home-reference'))),
      WebHomeDesign.designSize,
    );

    await tester.tap(find.byKey(const ValueKey('web-nav-home')));
    await tester.tap(find.byKey(const ValueKey('web-nav-programs')));

    expect(homeTapped, isTrue);
    expect(programsTapped, isTrue);
    expect(tester.takeException(), isNull);
  });
}
