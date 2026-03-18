import 'package:app_top_medicos/domain/entities/specialty.dart';
import 'package:app_top_medicos/infrastructure/models/specialty/specialty_response.dart';

class SpecialtyMapper {

  static List<Specialty> toEntityList(SpecialtyResponse response) {
    return response.results;
  }

}
