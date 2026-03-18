import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_top_medicos/domain/entities/auth_cache.dart';
import 'package:app_top_medicos/domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repository;

  AuthNotifier(this.repository) : super(const AuthState()) {
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

    state = state.copyWith(
      isCheckingSession: false,
      token: authCache.session.token,
      user: authCache.user,
      errorMessage: null,
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final session = await repository.login(email: email, password: password);
      final user = await repository.getCurrentUser(
        email: session.email,
        token: session.token,
      );

      await repository.persistSession(
        AuthCache(
          session: session,
          user: user,
        ),
      );

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
}
