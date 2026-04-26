import 'package:app_top_medicos/domain/entities/document_type.dart';
import 'package:app_top_medicos/domain/entities/gender_option.dart';
import 'package:app_top_medicos/domain/entities/patient_registration_result.dart';
import 'package:app_top_medicos/infrastructure/datasources/register_datasource_impl.dart';
import 'package:app_top_medicos/infrastructure/repositories/register_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final registerRepositoryProvider = Provider((ref) {
  return RegisterRepositoryImpl(RegisterDatasourceImpl());
});

final documentTypesProvider = FutureProvider<List<DocumentType>>((ref) {
  return ref.watch(registerRepositoryProvider).getDocumentTypes();
});

final registerGendersProvider = FutureProvider<List<GenderOption>>((ref) {
  return ref.watch(registerRepositoryProvider).getGenders();
});

final createPatientProvider = FutureProvider.family<
  PatientRegistrationResult,
  Map<String, dynamic>
>((ref, payload) {
  return ref.watch(registerRepositoryProvider).createPatient(payload: payload);
});
