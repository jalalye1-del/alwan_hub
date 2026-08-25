import 'package:alwan_hub/core/localization/localized_text.dart' as localized;
import 'package:alwan_hub/core/theme/app_typography.dart';
import 'package:alwan_hub/features/home/presentation/widgets/live_program_card.dart';
import 'package:alwan_hub/features/programs/domain/entities/fm_program.dart';
import 'package:alwan_hub/features/programs/domain/repositories/fm_program_repository.dart';
import 'package:alwan_hub/features/programs/presentation/providers/fm_program_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('live card reads the same live program supplied by dashboard', (
    tester,
  ) async {
    const program = FmProgram(
      id: 'dashboard-card',
      title: 'برنامج مباشر من اللوحة',
      description: 'وصف',
      presenterName: 'تقديم: مذيعة ألوان',
      liveTime: '08:00 PM',
      liveEndTime: '09:00 PM',
      replayTimes: ['01:00 AM'],
      imageUrl: 'assets/images/program.jpg',
      streamUrl: 'https://example.com/live',
      accentColor: Color(0xFF4A35E8),
      broadcastDays: {0},
      isLive: true,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fmProgramRepositoryProvider.overrideWithValue(
            const _FakeFmProgramRepository([program]),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: [Locale('ar'), Locale('en')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Scaffold(body: SingleChildScrollView(child: LiveProgramCard())),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('برنامج مباشر من اللوحة'), findsOneWidget);
    expect(find.text('تقديم: مذيعة ألوان'), findsOneWidget);
    expect(find.text('08:00 PM - 09:00 PM'), findsOneWidget);

    final listenLabel = tester.widget<localized.Text>(
      find.byKey(const ValueKey('live-listen-label')),
    );
    final chatLabel = tester.widget<localized.Text>(
      find.byKey(const ValueKey('live-chat-label')),
    );
    expect(listenLabel.style?.fontFamily, AppTypography.fontFamily);
    expect(chatLabel.style?.fontFamily, AppTypography.fontFamily);
  });
}

class _FakeFmProgramRepository implements FmProgramRepository {
  const _FakeFmProgramRepository(this.programs);

  final List<FmProgram> programs;

  @override
  Future<List<FmProgram>> fetchPrograms() async => programs;

  @override
  Stream<List<FmProgram>> watchPrograms() => Stream.value(programs);
}
