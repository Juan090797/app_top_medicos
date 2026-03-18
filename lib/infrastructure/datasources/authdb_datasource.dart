import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:app_top_medicos/domain/datasources/auth_datasource.dart';
import 'package:app_top_medicos/domain/entities/auth_session.dart';
import 'package:app_top_medicos/domain/entities/authenticated_user.dart';
import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';

class AuthDbDatasource extends AuthDatasource {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://topmedicosperu.com/ms-medical-app/api',
    headers: {'Content-Type': 'application/json'},
  ));

  Map<String, dynamic> _decodeTokenPayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) {
      throw const AuthException('Respuesta inválida: token malformado');
    }

    try {
      final normalizedPayload = base64Url.normalize(parts[1]);
      final payloadBytes = base64Url.decode(normalizedPayload);
      final payloadMap = jsonDecode(utf8.decode(payloadBytes));

      if (payloadMap is! Map<String, dynamic>) {
        throw const AuthException('Respuesta inválida: payload de token inválido');
      }

      return payloadMap;
    } on FormatException {
      throw const AuthException('Respuesta inválida: no se pudo leer el token');
    }
  }

  bool _hasPatientAuthority(String token) {
    final payloadMap = _decodeTokenPayload(token);
    final authorities = payloadMap['authorities'];
    if (authorities is! List) return false;

    return authorities.any((authority) {
      if (authority is Map<String, dynamic>) {
        return authority['authority']?.toString() == 'PATIENT';
      }

      return false;
    });
  }

  String _extractEmailFromToken(String token) {
    final payloadMap = _decodeTokenPayload(token);
    final email = payloadMap['email']?.toString() ?? payloadMap['sub']?.toString() ?? '';

    if (email.isEmpty) {
      throw const AuthException('Respuesta inválida: el token no contiene email');
    }

    return email;
  }

  bool _hasUsableImage(String imageUrl) {
    return imageUrl.isNotEmpty &&
        !imageUrl.endsWith('/null') &&
        !imageUrl.contains('/static/null');
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
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
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
      throw AuthException(
        'No se pudo obtener la información del usuario: ${e.message ?? 'desconocido'}',
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
        data: {
          'email': email,
          'password': password,
        },
      );

      final json = resp.data as Map<String, dynamic>;
      final token = (json['token'] ?? '').toString();

      if (token.isEmpty) {
        throw const AuthException('Respuesta inválida: token vacío');
      }

      if (!_hasPatientAuthority(token)) {
        throw const AuthException('Debes ser paciente para ingresar');
      }

      dio.options.headers['Authorization'] = 'Bearer $token';

      final tokenEmail = _extractEmailFromToken(token);

      return AuthSession(token: token, email: tokenEmail);
    } on DioException catch (e) {
      // Caso credenciales incorrectas (401) con body { message: "Credenciales incorrectas" }
      final status = e.response?.statusCode;
      final data = e.response?.data;

      if (status == 401) {
        final msg = (data is Map<String, dynamic>)
            ? (data['message']?.toString() ?? 'Credenciales incorrectas')
            : 'Credenciales incorrectas';
        throw AuthException(msg);
      }

      // Otros errores
      throw AuthException('Error de red: ${e.message ?? 'desconocido'}');
    }
  }
}
