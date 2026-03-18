import 'package:app_top_medicos/domain/entities/auth_cache.dart';
import 'package:app_top_medicos/domain/entities/authenticated_user.dart';

import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthenticatedUser> getCurrentUser({
    required String email,
    required String token,
  });

  Future<void> persistSession(AuthCache authCache);

  Future<AuthCache?> getPersistedSession();

  Future<void> clearSession();
}
