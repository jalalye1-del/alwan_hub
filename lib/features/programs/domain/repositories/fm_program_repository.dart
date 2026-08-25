import 'package:alwan_hub/features/programs/domain/entities/fm_program.dart';

abstract interface class FmProgramRepository {
  Future<List<FmProgram>> fetchPrograms();

  Stream<List<FmProgram>> watchPrograms();
}
