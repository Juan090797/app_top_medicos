import 'package:app_top_medicos/domain/entities/gender_option.dart';
import 'package:app_top_medicos/domain/entities/patient_profile.dart';

abstract class PatientProfileRepository {
  Future<PatientProfile> getByEmail({
    required String email,
    required String token,
  });

  Future<List<GenderOption>> getGenders({
    required String token,
  });

  Future<PatientProfile> updateProfile({
    required int id,
    required String phoneNumber,
    required String gender,
    required String token,
  });

  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
    required String repeatNewPassword,
    required String token,
  });
}