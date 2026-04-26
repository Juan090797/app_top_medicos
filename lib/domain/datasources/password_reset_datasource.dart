import 'package:app_top_medicos/domain/entities/password_reset_otp.dart';

abstract class PasswordResetDatasource {
  Future<PasswordResetOtp> sendOtp({required String email});
}
