import 'package:app_top_medicos/domain/datasources/register_datasource.dart';
import 'package:app_top_medicos/domain/entities/document_type.dart';
import 'package:app_top_medicos/domain/entities/gender_option.dart';
import 'package:app_top_medicos/domain/entities/patient_registration_result.dart';
import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';
import 'package:dio/dio.dart';

class RegisterDatasourceImpl extends RegisterDatasource {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://topmedicosperu.com',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  @override
  Future<List<DocumentType>> getDocumentTypes() async {
    try {
      final response = await dio.get('/data/document-types.json');
      final list = response.data as List<dynamic>? ?? const [];

      return list.whereType<Map<String, dynamic>>().map((json) {
        return DocumentType(
          id: (json['id'] as num?)?.toInt() ?? 0,
          description: (json['description'] ?? '').toString(),
          shortDescription: (json['shortDescription'] ?? '').toString(),
          length: (json['length'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } on DioException catch (e) {
      throw AuthException(
        'No se pudo cargar tipos de documento: ${e.message ?? 'desconocido'}',
      );
    }
  }

  @override
  Future<List<GenderOption>> getGenders() async {
    try {
      final response = await dio.get('/data/genders.json');
      final list = response.data as List<dynamic>? ?? const [];

      return list.whereType<Map<String, dynamic>>().map((json) {
        return GenderOption(
          description: (json['description'] ?? '').toString(),
          shortDescription: (json['shortDescription'] ?? '').toString(),
        );
      }).toList();
    } on DioException catch (e) {
      throw AuthException(
        'No se pudo cargar géneros: ${e.message ?? 'desconocido'}',
      );
    }
  }

  @override
  Future<PatientRegistrationResult> createPatient({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await dio.post(
        '/ms-medical-app/api/patients',
        data: payload,
      );

      final json = response.data as Map<String, dynamic>;
      return PatientRegistrationResult(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: (json['name'] ?? '').toString(),
        lastName: (json['lastName'] ?? '').toString(),
        dataConsent: json['dataConsent'] == true,
        receiveNotifications: json['receiveNotifications'] == true,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final message =
          data is Map<String, dynamic>
              ? data['message']?.toString()
              : e.message;

      throw AuthException(
        'No se pudo crear la cuenta: ${message ?? 'desconocido'}',
      );
    }
  }
}
