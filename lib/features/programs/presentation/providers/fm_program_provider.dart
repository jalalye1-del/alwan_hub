import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alwan_hub/features/programs/data/repositories/local_fm_program_repository.dart';
import 'package:alwan_hub/features/programs/domain/entities/fm_program.dart';
import 'package:alwan_hub/features/programs/domain/repositories/fm_program_repository.dart';

/// Override this provider with [DashboardFmProgramRepository] in the app
/// bootstrap when the remote managed-content service is configured.
final fmProgramRepositoryProvider = Provider<FmProgramRepository>((ref) {
  return const LocalFmProgramRepository();
});

final fmProgramsProvider = StreamProvider<List<FmProgram>>((ref) {
  return ref.watch(fmProgramRepositoryProvider).watchPrograms();
});

final liveFmProgramProvider = Provider<AsyncValue<FmProgram?>>((ref) {
  return ref.watch(fmProgramsProvider).whenData((programs) {
    for (final program in programs) {
      if (program.isLive) return program;
    }
    return programs.isEmpty ? null : programs.first;
  });
});
