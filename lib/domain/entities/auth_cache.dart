import 'package:app_top_medicos/domain/entities/auth_session.dart';
import 'package:app_top_medicos/domain/entities/authenticated_user.dart';

class AuthCache {
  final AuthSession session;
  final AuthenticatedUser user;

  const AuthCache({
    required this.session,
    required this.user,
  });
}