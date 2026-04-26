import 'package:app_top_medicos/domain/entities/document_type.dart';
import 'package:app_top_medicos/domain/entities/gender_option.dart';
import 'package:app_top_medicos/domain/entities/patient_registration_result.dart';

abstract class RegisterDatasource {
  Future<List<DocumentType>> getDocumentTypes();

  Future<List<GenderOption>> getGenders();

  Future<PatientRegistrationResult> createPatient({
    required Map<String, dynamic> payload,
  });
}
