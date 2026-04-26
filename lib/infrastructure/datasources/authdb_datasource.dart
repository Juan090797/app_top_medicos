import 'package:app_top_medicos/infrastructure/auth/jwt_token_service.dart';
import 'package:dio/dio.dart';
import 'package:app_top_medicos/domain/datasources/auth_datasource.dart';
import 'package:app_top_medicos/domain/entities/auth_session.dart';
import 'package:app_top_medicos/domain/entities/authenticated_user.dart';
import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';
import 'package:app_top_medicos/infrastructure/http/api_error_handler.dart';

class AuthDbDatasource extends AuthDatasource {
  final JwtTokenService tokenService;

  AuthDbDatasource({JwtTokenService? tokenService})
    : tokenService = tokenService ?? JwtTokenService();

  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://topmedicosperu.com/ms-medical-app/api',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  bool _hasUsableImage(String imageUrl) {
    return imageUrl.isNotEmpty &&
        !imageUrl.endsWith('/null') &&
        !imageUrl.contains('/static/null');
  }

  Options _authorizedOptions(String token) {
    if (tokenService.isExpired(token)) {
      throw const SessionExpiredException(
        ApiErrorHandler.sessionExpiredMessage,
      );
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<AuthenticatedUser> getCurrentUser({
    required String email,
    required String token,
  }) async {
    try {
      final resp = await dio.get(
        '/people/me',
        queryParameters: {'email': email.trim().toLowerCase()},
        options: _authorizedOptions(token),
      );

      final json = resp.data as Map<String, dynamic>;
      final imageUrl = (json['urlImagenUser'] ?? '').toString();

      return AuthenticatedUser(
        email: (json['email'] ?? email).toString(),
        username: (json['username'] ?? '').toString(),
        urlImagenUser: _hasUsableImage(imageUrl) ? imageUrl : '',
        isUpdateData: json['isUpdateData'] == true,
      );
    } on DioException catch (e) {
      throw ApiErrorHandler.authExceptionFromDio(
        e,
        fallbackMessage: 'No se pudo obtener la información del usuario',
      );
    }
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final resp = await dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final json = resp.data as Map<String, dynamic>;
      final token = (json['token'] ?? '').toString();

      if (token.isEmpty) {
        throw const AuthException('Respuesta inválida: token vacío');
      }

      if (tokenService.isExpired(token)) {
        throw const SessionExpiredException(
          ApiErrorHandler.sessionExpiredMessage,
        );
      }

      if (!tokenService.hasAuthority(token, 'PATIENT')) {
        throw const AuthException('Debes ser paciente para ingresar');
      }

      final tokenEmail = tokenService.extractEmail(token);

      return AuthSession(token: token, email: tokenEmail);
    } on DioException catch (e) {
      // Caso credenciales incorrectas (401) con body { message: "Credenciales incorrectas" }
      final status = e.response?.statusCode;
      final data = e.response?.data;

      if (status == 401) {
        final msg =
            (data is Map<String, dynamic>)
                ? (data['message']?.toString() ?? 'Credenciales incorrectas')
                : 'Credenciales incorrectas';
        throw AuthException(msg);
      }

      // Otros errores
      throw AuthException('Error de red: ${e.message ?? 'desconocido'}');
    }
  }
}
