import 'package:app_top_medicos/domain/datasources/specialty_datasource.dart';
import 'package:app_top_medicos/domain/entities/specialty.dart';
import 'package:app_top_medicos/infrastructure/models/specialty/local_specialty_model.dart';
import 'package:app_top_medicos/shared/data/local_specialty.dart';

class LocalSpecialtyDatasourceImpl implements SpecialtyDatasource {
  
  @override
  Future<List<Specialty>> getAll() async {

    await Future.delayed( const Duration(seconds: 2) );
    
    final List<Specialty> newSpecialties = specialties.map(
      ( specialty ) => LocalSpecialtyModel.fromJson(specialty).toSpecialtyEntity()
    ).toList();
    
    return newSpecialties;
  }

}
