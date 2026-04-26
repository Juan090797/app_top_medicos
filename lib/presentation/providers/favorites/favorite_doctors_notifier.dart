import 'package:app_top_medicos/domain/repositories/favorite_doctor_repository.dart';
import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'favorite_doctors_state.dart';

class FavoriteDoctorsNotifier extends StateNotifier<FavoriteDoctorsState> {
  final FavoriteDoctorRepository repository;
  final String email;
  final String token;
  final Future<void> Function()? onSessionExpired;

  FavoriteDoctorsNotifier({
    required this.repository,
    required this.email,
    required this.token,
    this.onSessionExpired,
  }) : super(const FavoriteDoctorsState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final doctors = await repository.getFavorites(email: email, token: token);

      state = state.copyWith(isLoading: false, doctors: doctors);
    } catch (e) {
      if (e is SessionExpiredException) {
        await onSessionExpired?.call();
        if (!mounted) return;
      }

      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
