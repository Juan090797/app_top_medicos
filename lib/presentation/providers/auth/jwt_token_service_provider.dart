import 'package:app_top_medicos/infrastructure/auth/jwt_token_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final jwtTokenServiceProvider = Provider<JwtTokenService>((ref) {
  return JwtTokenService();
});
