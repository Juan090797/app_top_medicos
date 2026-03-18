import 'package:app_top_medicos/domain/datasources/patient_profile_datasource.dart';
import 'package:app_top_medicos/domain/entities/gender_option.dart';
import 'package:app_top_medicos/domain/entities/patient_profile.dart';
import 'package:app_top_medicos/domain/repositories/patient_profile_repository.dart';

class PatientProfileRepositoryImpl extends PatientProfileRepository {
  final PatientProfileDatasource datasource;

  PatientProfileRepositoryImpl(this.datasource);

  @override
  Future<PatientProfile> getByEmail({
    required String email,
    required String token,
  }) {
    return datasource.getByEmail(email: email, token: token);
  }

  @override
  Future<List<GenderOption>> getGenders({required String token}) {
    return datasource.getGenders(token: token);
  }

  @override
  Future<PatientProfile> updateProfile({
    required int id,
    required String phoneNumber,
    required String gender,
    required String token,
  }) {
    return datasource.updateProfile(
      id: id,
      phoneNumber: phoneNumber,
      gender: gender,
      token: token,
    );
  }

  @override
  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
    required String repeatNewPassword,
    required String token,
  }) {
    return datasource.changePassword(
      email: email,
      oldPassword: oldPassword,
      newPassword: newPassword,
      repeatNewPassword: repeatNewPassword,
      token: token,
    );
  }
}