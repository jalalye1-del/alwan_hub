import 'package:alwan_hub/core/content/repositories/content_repository.dart';
import 'package:alwan_hub/features/programs/domain/entities/fm_program.dart';
import 'package:alwan_hub/features/programs/domain/repositories/fm_program_repository.dart';

/// Adapter connecting the FM UI to the app's managed-content dashboard.
class DashboardFmProgramRepository implements FmProgramRepository {
  const DashboardFmProgramRepository(this.contentRepository);

  final ContentRepository contentRepository;

  @override
  Future<List<FmProgram>> fetchPrograms() async {
    final content = await contentRepository.fetchPublished(type: 'fm_program');
    return _mapAndSort(content.map(FmProgram.fromManagedContent));
  }

  @override
  Stream<List<FmProgram>> watchPrograms() {
    return contentRepository
        .watchPublished(type: 'fm_program')
        .map((items) => _mapAndSort(items.map(FmProgram.fromManagedContent)));
  }

  List<FmProgram> _mapAndSort(Iterable<FmProgram> values) {
    final programs = values
        .where((program) => program.isPublished)
        .toList(growable: false);
    return [...programs]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }
}
