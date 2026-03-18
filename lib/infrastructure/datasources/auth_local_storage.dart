import 'dart:convert';

import 'package:app_top_medicos/domain/entities/auth_cache.dart';
import 'package:app_top_medicos/domain/entities/auth_session.dart';
import 'package:app_top_medicos/domain/entities/authenticated_user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthLocalStorage {
  static const _sessionKey = 'auth.session';
  static const _userKey = 'auth.user';

  Future<void> save(AuthCache authCache) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(
      _sessionKey,
      jsonEncode({
        'token': authCache.session.token,
        'email': authCache.session.email,
      }),
    );

    await preferences.setString(
      _userKey,
      jsonEncode({
        'email': authCache.user.email,
        'username': authCache.user.username,
        'urlImagenUser': authCache.user.urlImagenUser,
        'isUpdateData': authCache.user.isUpdateData,
      }),
    );
  }

  Future<AuthCache?> read() async {
    final preferences = await SharedPreferences.getInstance();
    final sessionJson = preferences.getString(_sessionKey);
    final userJson = preferences.getString(_userKey);

    if (sessionJson == null || userJson == null) return null;

    final sessionMap = jsonDecode(sessionJson);
    final userMap = jsonDecode(userJson);

    if (sessionMap is! Map<String, dynamic> || userMap is! Map<String, dynamic>) {
      return null;
    }

    final token = sessionMap['token']?.toString() ?? '';
    final email = sessionMap['email']?.toString() ?? '';

    if (token.isEmpty || email.isEmpty) return null;

    return AuthCache(
      session: AuthSession(
        token: token,
        email: email,
      ),
      user: AuthenticatedUser(
        email: userMap['email']?.toString() ?? '',
        username: userMap['username']?.toString() ?? '',
        urlImagenUser: userMap['urlImagenUser']?.toString() ?? '',
        isUpdateData: userMap['isUpdateData'] == true,
      ),
    );
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
    await preferences.remove(_userKey);
  }
}