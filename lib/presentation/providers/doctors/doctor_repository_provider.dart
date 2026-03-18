import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../infrastructure/datasources/doctordb_datasource.dart';
import '../../../infrastructure/repositories/doctor_repository_impl.dart';
import '../../../domain/repositories/doctor_repository.dart';

final doctorRepositoryProvider = Provider<DoctorRepository>((ref) {
  return DoctorRepositoryImpl(DoctordbDatasource());
});
