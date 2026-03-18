import 'package:app_top_medicos/domain/datasources/specialty_datasource.dart';
import 'package:app_top_medicos/domain/entities/specialty.dart';
import 'package:app_top_medicos/domain/repositories/specialty_repository.dart';


class SpecialtyRepositoryImpl implements SpecialtyRepository{
  
  final SpecialtyDatasource specialtyDatasource;

  SpecialtyRepositoryImpl(this.specialtyDatasource);

  @override
  Future<List<Specialty>> getAll(){
    return specialtyDatasource.getAll();
  }
  
}
