class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class SessionExpiredException extends AuthException {
  const SessionExpiredException(super.message);
}
