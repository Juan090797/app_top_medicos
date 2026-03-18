import 'package:app_top_medicos/domain/entities/favorite_doctor.dart';

class FavoriteDoctorsState {
  final bool isLoading;
  final List<FavoriteDoctor> doctors;
  final String? errorMessage;

  const FavoriteDoctorsState({
    this.isLoading = false,
    this.doctors = const [],
    this.errorMessage,
  });

  FavoriteDoctorsState copyWith({
    bool? isLoading,
    List<FavoriteDoctor>? doctors,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoriteDoctorsState(
      isLoading: isLoading ?? this.isLoading,
      doctors: doctors ?? this.doctors,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
