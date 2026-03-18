import 'package:app_top_medicos/domain/repositories/favorite_doctor_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'favorite_doctors_state.dart';

class FavoriteDoctorsNotifier extends StateNotifier<FavoriteDoctorsState> {
  final FavoriteDoctorRepository repository;
  final String email;
  final String token;

  FavoriteDoctorsNotifier({
    required this.repository,
    required this.email,
    required this.token,
  }) : super(const FavoriteDoctorsState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final doctors = await repository.getFavorites(
        email: email,
        token: token,
      );

      state = state.copyWith(
        isLoading: false,
        doctors: doctors,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}
