
import 'package:app_top_medicos/domain/entities/authenticated_user.dart';

const _unset = Object();

class AuthState {
  final bool isLoading;
  final bool isCheckingSession;
  final String? token;
  final AuthenticatedUser? user;
  final String? errorMessage;

  const AuthState({
    this.isLoading = false,
    this.isCheckingSession = true,
    this.token,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  AuthState copyWith({
    bool? isLoading,
    bool? isCheckingSession,
    Object? token = _unset,
    Object? user = _unset,
    Object? errorMessage = _unset,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isCheckingSession: isCheckingSession ?? this.isCheckingSession,
      token: identical(token, _unset) ? this.token : token as String?,
      user: identical(user, _unset) ? this.user : user as AuthenticatedUser?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}
