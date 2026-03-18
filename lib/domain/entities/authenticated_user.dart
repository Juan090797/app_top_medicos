class AuthenticatedUser {
  final String email;
  final String username;
  final String urlImagenUser;
  final bool isUpdateData;

  const AuthenticatedUser({
    required this.email,
    required this.username,
    required this.urlImagenUser,
    required this.isUpdateData,
  });
}