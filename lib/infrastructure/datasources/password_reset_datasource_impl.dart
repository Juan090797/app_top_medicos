import 'package:app_top_medicos/domain/datasources/password_reset_datasource.dart';
import 'package:app_top_medicos/domain/entities/password_reset_otp.dart';
import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';
import 'package:dio/dio.dart';

class PasswordResetDatasourceImpl extends PasswordResetDatasource {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://topmedicosperu.com/ms-medical-app/api',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  @override
  Future<PasswordResetOtp> sendOtp({required String email}) async {
    try {
      final response = await dio.post(
        '/validations/code-otp/send',
        data: {'email': email.trim().toLowerCase()},
      );

      final json = response.data as Map<String, dynamic>;
      return PasswordResetOtp(
        id: (json['id'] as num?)?.toInt() ?? 0,
        expireTime: (json['expireTime'] as num?)?.toInt() ?? 0,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final message =
          data is Map<String, dynamic>
              ? data['message']?.toString()
              : e.message;

      throw AuthException(
        'No se pudo enviar el código: ${message ?? 'desconocido'}',
      );
    }
  }
}
