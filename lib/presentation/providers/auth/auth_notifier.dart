import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_top_medicos/domain/entities/auth_cache.dart';
import 'package:app_top_medicos/domain/repositories/auth_repository.dart';
import 'package:app_top_medicos/infrastructure/auth/jwt_token_service.dart';
import 'package:app_top_medicos/infrastructure/http/api_error_handler.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;
  final JwtTokenService tokenService;

  AuthNotifier({required this.repository, required this.tokenService})
    : super(const AuthState()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final authCache = await repository.getPersistedSession();

    if (authCache == null) {
      state = state.copyWith(
        isCheckingSession: false,
        token: null,
        user: null,
        errorMessage: null,
      );
      return;
    }

    try {
      if (tokenService.isExpired(authCache.session.token)) {
        await expireSession(showMessage: false);
        return;
      }

      state = state.copyWith(
        isCheckingSession: false,
        token: authCache.session.token,
        user: authCache.user,
        errorMessage: null,
      );
    } catch (_) {
      await expireSession(showMessage: false);
    }
  }

  Future<void> login({required String email, required String password}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final session = await repository.login(email: email, password: password);
      final user = await repository.getCurrentUser(
        email: session.email,
        token: session.token,
      );

      await repository.persistSession(AuthCache(session: session, user: user));

      state = state.copyWith(
        isLoading: false,
        isCheckingSession: false,
        token: session.token,
        user: user,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        token: null,
        user: null,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await repository.clearSession();
    state = const AuthState(isCheckingSession: false);
  }

  Future<void> expireSession({bool showMessage = true}) async {
    await repository.clearSession();
    state = AuthState(
      isCheckingSession: false,
      errorMessage: showMessage ? ApiErrorHandler.sessionExpiredMessage : null,
    );
  }
}
