import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';
import 'auth_repository_provider.dart';
import 'jwt_token_service_provider.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final tokenService = ref.watch(jwtTokenServiceProvider);

  return AuthNotifier(repository: repo, tokenService: tokenService);
});
