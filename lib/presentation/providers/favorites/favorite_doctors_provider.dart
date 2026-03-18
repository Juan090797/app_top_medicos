import 'package:app_top_medicos/infrastructure/datasources/favorite_doctor_datasource_impl.dart';
import 'package:app_top_medicos/infrastructure/repositories/favorite_doctor_repository_impl.dart';
import 'package:app_top_medicos/presentation/providers/auth/auth_provider.dart';
import 'package:app_top_medicos/presentation/providers/favorites/favorite_doctors_notifier.dart';
import 'package:app_top_medicos/presentation/providers/favorites/favorite_doctors_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoriteDoctorsProvider = StateNotifierProvider.autoDispose<
    FavoriteDoctorsNotifier, FavoriteDoctorsState>((ref) {
  final authState = ref.watch(authProvider);

  final token = authState.token;
  final email = authState.user?.email;

  if (token == null || token.isEmpty || email == null || email.isEmpty) {
    throw Exception('No hay sesión activa para cargar favoritos');
  }

  final repository =
      FavoriteDoctorRepositoryImpl(FavoriteDoctorDatasourceImpl());

  return FavoriteDoctorsNotifier(
    repository: repository,
    email: email,
    token: token,
  );
});
