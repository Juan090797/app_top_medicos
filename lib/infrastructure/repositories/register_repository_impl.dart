import 'package:app_top_medicos/domain/datasources/register_datasource.dart';
import 'package:app_top_medicos/domain/entities/document_type.dart';
import 'package:app_top_medicos/domain/entities/gender_option.dart';
import 'package:app_top_medicos/domain/entities/patient_registration_result.dart';
import 'package:app_top_medicos/domain/repositories/register_repository.dart';

class RegisterRepositoryImpl implements RegisterRepository {
  final RegisterDatasource datasource;

  RegisterRepositoryImpl(this.datasource);

  @override
  Future<List<DocumentType>> getDocumentTypes() {
    return datasource.getDocumentTypes();
  }

  @override
  Future<List<GenderOption>> getGenders() {
    return datasource.getGenders();
  }

  @override
  Future<PatientRegistrationResult> createPatient({
    required Map<String, dynamic> payload,
  }) {
    return datasource.createPatient(payload: payload);
  }
}
