import 'package:app_top_medicos/domain/entities/specialty.dart';

abstract class SpecialtyDatasource {

  Future<List<Specialty>> getAll();

}
