import 'package:app_top_medicos/domain/repositories/patient_profile_repository.dart';
import 'package:app_top_medicos/infrastructure/datasources/patient_profile_datasource_impl.dart';
import 'package:app_top_medicos/infrastructure/repositories/patient_profile_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final patientProfileRepositoryProvider = Provider<PatientProfileRepository>((ref) {
  return PatientProfileRepositoryImpl(PatientProfileDatasourceImpl());
});