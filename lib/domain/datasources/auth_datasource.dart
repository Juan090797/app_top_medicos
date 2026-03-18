import '../entities/authenticated_user.dart';
import '../entities/auth_session.dart';

abstract class AuthDatasource {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthenticatedUser> getCurrentUser({
    required String email,
    required String token,
  });
}
