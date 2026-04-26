import 'package:app_top_medicos/domain/datasources/password_reset_datasource.dart';
import 'package:app_top_medicos/domain/entities/password_reset_otp.dart';
import 'package:app_top_medicos/domain/repositories/password_reset_repository.dart';

class PasswordResetRepositoryImpl implements PasswordResetRepository {
  final PasswordResetDatasource datasource;

  PasswordResetRepositoryImpl(this.datasource);

  @override
  Future<PasswordResetOtp> sendOtp({required String email}) {
    return datasource.sendOtp(email: email);
  }
}
