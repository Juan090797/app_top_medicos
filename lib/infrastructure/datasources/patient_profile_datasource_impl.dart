import 'package:app_top_medicos/domain/datasources/patient_profile_datasource.dart';
import 'package:app_top_medicos/domain/entities/gender_option.dart';
import 'package:app_top_medicos/domain/entities/patient_profile.dart';
import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';
import 'package:dio/dio.dart';

class PatientProfileDatasourceImpl extends PatientProfileDatasource {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://topmedicosperu.com/ms-medical-app/api',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Options _authorizedOptions(String token) {
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  PatientProfile _toPatientProfile(Map<String, dynamic> json) {
    return PatientProfile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      phoneNumber: (json['phoneNumber'] ?? '').toString(),
      gender: (json['gender'] ?? '').toString().toUpperCase(),
      email: (json['email'] ?? '').toString(),
    );
  }

  @override
  Future<PatientProfile> getByEmail({
    required String email,
    required String token,
  }) async {
    try {
      final normalizedEmail = Uri.encodeComponent(email.trim().toLowerCase());
      final response = await dio.get(
        '/patients/email/$normalizedEmail',
        options: _authorizedOptions(token),
      );

      final json = response.data as Map<String, dynamic>;
      return _toPatientProfile(json);
    } on DioException catch (e) {
      throw AuthException(
        'No se pudo cargar el perfil: ${e.response?.data?['message'] ?? e.message ?? 'desconocido'}',
      );
    }
  }

  @override
  Future<List<GenderOption>> getGenders({required String token}) async {
    try {
      final response = await dio.get(
        'https://topmedicosperu.com/data/genders.json',
        options: _authorizedOptions(token),
      );

      final list = response.data as List<dynamic>;
      return list.map((item) {
        final json = item as Map<String, dynamic>;
        return GenderOption(
          description: (json['description'] ?? '').toString(),
          shortDescription: (json['shortDescription'] ?? '').toString().toUpperCase(),
        );
      }).toList();
    } on DioException catch (e) {
      throw AuthException(
        'No se pudo cargar géneros: ${e.response?.data?['message'] ?? e.message ?? 'desconocido'}',
      );
    }
  }

  @override
  Future<PatientProfile> updateProfile({
    required int id,
    required String phoneNumber,
    required String gender,
    required String token,
  }) async {
    try {
      final response = await dio.put(
        '/patients/$id',
        data: {
          'id': id,
          'phoneNumber': phoneNumber,
          'gender': gender.toUpperCase(),
        },
        options: _authorizedOptions(token),
      );

      final json = response.data as Map<String, dynamic>;
      return _toPatientProfile(json);
    } on DioException catch (e) {
      throw AuthException(
        'No se pudo actualizar el perfil: ${e.response?.data?['message'] ?? e.message ?? 'desconocido'}',
      );
    }
  }

  @override
  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
    required String repeatNewPassword,
    required String token,
  }) async {
    try {
      await dio.post(
        '/users/change-password',
        data: {
          'email': email,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'repeatNewPassword': repeatNewPassword,
        },
        options: _authorizedOptions(token),
      );
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Error desconocido';
      throw AuthException('No se pudo cambiar la contraseña: $errorMessage');
    }
  }
}