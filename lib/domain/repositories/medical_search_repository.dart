import 'package:app_top_medicos/domain/entities/doctor.dart';
import 'package:app_top_medicos/domain/entities/medical_search_suggestion.dart';

abstract class MedicalSearchRepository {
  Future<List<MedicalSearchSuggestion>> searchSuggestions({
    required String keyword,
    required String token,
    int page = 0,
    int size = 10,
  });

  Future<List<Doctor>> searchDoctors({
    required String keyword,
    required String token,
    String city = '',
    int page = 0,
    int size = 10,
  });
}
