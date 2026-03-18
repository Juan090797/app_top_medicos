import 'package:app_top_medicos/infrastructure/datasources/specialtydb_datasource.dart';
import 'package:app_top_medicos/infrastructure/repositories/specialty_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final specialtiesProvider = FutureProvider((ref) async {
  return SpecialtyRepositoryImpl(
    //LocalSpecialtyDatasourceImpl()
    SpecialtydbDatasource()
  ).getAll();
});
