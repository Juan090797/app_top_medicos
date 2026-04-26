import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';
import 'package:dio/dio.dart';

class ApiErrorHandler {
  const ApiErrorHandler._();

  static const sessionExpiredMessage =
      'Tu sesión expiró. Inicia sesión nuevamente.';

  static bool isUnauthorizedStatus(int? statusCode) {
    return statusCode == 401 || statusCode == 403;
  }

  static AuthException authExceptionFromDio(
    DioException exception, {
    required String fallbackMessage,
  }) {
    if (isUnauthorizedStatus(exception.response?.statusCode)) {
      return const SessionExpiredException(sessionExpiredMessage);
    }

    final responseMessage = _readResponseMessage(exception.response?.data);
    return AuthException(
      '$fallbackMessage: ${responseMessage ?? exception.message ?? 'desconocido'}',
    );
  }

  static String? _readResponseMessage(Object? data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString();
    }

    return null;
  }
}
