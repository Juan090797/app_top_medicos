import 'dart:convert';

import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';

class JwtTokenService {
  Map<String, dynamic> decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) {
      throw const AuthException('Token de sesión inválido');
    }

    try {
      final normalizedPayload = base64Url.normalize(parts[1]);
      final payloadBytes = base64Url.decode(normalizedPayload);
      final payload = jsonDecode(utf8.decode(payloadBytes));

      if (payload is! Map<String, dynamic>) {
        throw const AuthException('Token de sesión inválido');
      }

      return payload;
    } on FormatException {
      throw const AuthException('Token de sesión inválido');
    }
  }

  DateTime? getExpirationDate(String token) {
    final payload = decodePayload(token);
    final expiresAt = payload['exp'];

    if (expiresAt is int) {
      return DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000, isUtc: true);
    }

    if (expiresAt is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        expiresAt.toInt() * 1000,
        isUtc: true,
      );
    }

    return null;
  }

  bool isExpired(String token, {DateTime? now}) {
    final expirationDate = getExpirationDate(token);
    if (expirationDate == null) return true;

    final currentDate = now?.toUtc() ?? DateTime.now().toUtc();
    return !expirationDate.isAfter(currentDate);
  }

  bool hasAuthority(String token, String expectedAuthority) {
    final payload = decodePayload(token);
    final authorities = payload['authorities'];
    if (authorities is! List) return false;

    return authorities.any((authority) {
      if (authority is Map<String, dynamic>) {
        return authority['authority']?.toString() == expectedAuthority;
      }

      return false;
    });
  }

  String extractEmail(String token) {
    final payload = decodePayload(token);
    final email =
        payload['email']?.toString() ?? payload['sub']?.toString() ?? '';

    if (email.isEmpty) {
      throw const AuthException('El token de sesión no contiene email');
    }

    return email;
  }
}
