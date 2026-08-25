import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alwan_hub/app.dart';
import 'package:alwan_hub/features/library/core/library_initializer.dart';
import 'package:alwan_hub/features/library/domain/repositories/library_category_repository.dart';
import 'package:alwan_hub/features/library/presentation/providers/library_provider.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          libraryInitializerProvider.overrideWithValue(
            _NoopLibraryInitializer(),
          ),
        ],
        child: const AlwanHubApp(),
      ),
    );

    expect(find.byType(AlwanHubApp), findsOneWidget);
  });
}

class _NoopLibraryInitializer extends LibraryInitializer {
  _NoopLibraryInitializer() : super(_FakeLibraryCategoryRepository());

  @override
  Future<void> initialize() async {}
}

class _FakeLibraryCategoryRepository extends Fake
    implements LibraryCategoryRepository {}
