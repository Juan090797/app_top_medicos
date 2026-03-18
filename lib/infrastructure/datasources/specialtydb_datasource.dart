import 'package:app_top_medicos/domain/datasources/specialty_datasource.dart';
import 'package:app_top_medicos/domain/entities/specialty.dart';
import 'package:app_top_medicos/infrastructure/mappers/specialty_mapper.dart';
import 'package:app_top_medicos/infrastructure/models/specialty/specialty_response.dart';
import 'package:dio/dio.dart';

class SpecialtydbDatasource extends SpecialtyDatasource{

  final dio = Dio(BaseOptions(
    baseUrl: 'https://topmedicosperu.com/ms-medical-app/api'
  ));

  @override
  Future<List<Specialty>> getAll() async {
    final response = await dio.get('/specialties');
    final specialtyResponse = SpecialtyResponse.fromJson(response.data);

    return SpecialtyMapper.toEntityList(specialtyResponse);
  }

}
