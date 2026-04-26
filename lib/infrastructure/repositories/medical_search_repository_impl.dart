import 'package:app_top_medicos/domain/datasources/medical_search_datasource.dart';
import 'package:app_top_medicos/domain/entities/doctor.dart';
import 'package:app_top_medicos/domain/entities/medical_search_suggestion.dart';
import 'package:app_top_medicos/domain/repositories/medical_search_repository.dart';

class MedicalSearchRepositoryImpl implements MedicalSearchRepository {
  final MedicalSearchDatasource datasource;

  MedicalSearchRepositoryImpl(this.datasource);

  @override
  Future<List<MedicalSearchSuggestion>> searchSuggestions({
    required String keyword,
    required String token,
    int page = 0,
    int size = 10,
  }) {
    return datasource.searchSuggestions(
      keyword: keyword,
      token: token,
      page: page,
      size: size,
    );
  }

  @override
  Future<List<Doctor>> searchDoctors({
    required String keyword,
    required String token,
    String city = '',
    int page = 0,
    int size = 10,
  }) {
    return datasource.searchDoctors(
      keyword: keyword,
      token: token,
      city: city,
      page: page,
      size: size,
    );
  }
}
