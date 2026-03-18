import 'package:app_top_medicos/domain/entities/specialty.dart';

abstract class SpecialtyRepository {

  Future<List<Specialty>> getAll();

}
