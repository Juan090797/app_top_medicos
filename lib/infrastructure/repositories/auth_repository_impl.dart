import 'package:app_top_medicos/domain/entities/auth_cache.dart';
import 'package:app_top_medicos/domain/datasources/auth_datasource.dart';
import 'package:app_top_medicos/domain/entities/auth_session.dart';
import 'package:app_top_medicos/domain/entities/authenticated_user.dart';
import 'package:app_top_medicos/domain/repositories/auth_repository.dart';
import 'package:app_top_medicos/infrastructure/datasources/auth_local_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDatasource datasource;
  final AuthLocalStorage localStorage;

  AuthRepositoryImpl(this.datasource, this.localStorage);

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) {
    return datasource.login(email: email, password: password);
  }

  @override
  Future<AuthenticatedUser> getCurrentUser({
    required String email,
    required String token,
  }) {
    return datasource.getCurrentUser(email: email, token: token);
  }

  @override
  Future<void> persistSession(AuthCache authCache) {
    return localStorage.save(authCache);
  }

  @override
  Future<AuthCache?> getPersistedSession() {
    return localStorage.read();
  }

  @override
  Future<void> clearSession() {
    return localStorage.clear();
  }
}
