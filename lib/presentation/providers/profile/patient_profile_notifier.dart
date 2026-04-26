import 'package:app_top_medicos/domain/repositories/patient_profile_repository.dart';
import 'package:app_top_medicos/domain/entities/gender_option.dart';
import 'package:app_top_medicos/domain/entities/patient_profile.dart';
import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'patient_profile_state.dart';

class PatientProfileNotifier extends StateNotifier<PatientProfileState> {
  final PatientProfileRepository repository;
  final String email;
  final String token;
  final Future<void> Function()? onSessionExpired;

  PatientProfileNotifier({
    required this.repository,
    required this.email,
    required this.token,
    this.onSessionExpired,
  }) : super(const PatientProfileState()) {
    loadProfileData();
  }

  PatientProfileNotifier.empty()
    : repository = _NullRepository(),
      email = '',
      token = '',
      onSessionExpired = null,
      super(const PatientProfileState(isLoading: false));

  Future<void> loadProfileData() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final results = await Future.wait<dynamic>([
        repository.getByEmail(email: email, token: token),
        repository.getGenders(token: token),
      ]);

      final profile = results[0] as PatientProfile;
      final genders = results[1] as List<GenderOption>;

      state = state.copyWith(
        isLoading: false,
        profile: profile,
        genders: genders,
      );
    } catch (e) {
      await _expireSessionIfNeeded(e);
      if (!mounted) return;
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateEditableFields({
    required String phoneNumber,
    required String gender,
  }) async {
    final profile = state.profile;
    if (profile == null) return;

    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      final updated = await repository.updateProfile(
        id: profile.id,
        phoneNumber: phoneNumber,
        gender: gender,
        token: token,
      );

      state = state.copyWith(
        isSaving: false,
        profile: updated,
        successMessage: 'Perfil actualizado correctamente',
      );
    } catch (e) {
      await _expireSessionIfNeeded(e);
      if (!mounted) return;
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String repeatNewPassword,
  }) async {
    if (newPassword != repeatNewPassword) {
      state = state.copyWith(
        errorMessage: 'Las contraseñas nuevas no coinciden',
        clearSuccess: true,
      );
      return;
    }

    state = state.copyWith(
      isSaving: true,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await repository.changePassword(
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword,
        repeatNewPassword: repeatNewPassword,
        token: token,
      );

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Contraseña actualizada correctamente',
      );
    } catch (e) {
      await _expireSessionIfNeeded(e);
      if (!mounted) return;
      state = state.copyWith(isSaving: false, errorMessage: e.toString());
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  Future<void> _expireSessionIfNeeded(Object error) async {
    if (error is SessionExpiredException) {
      await onSessionExpired?.call();
    }
  }
}

/// Implementación nula para cuando no hay sesión activa.
class _NullRepository implements PatientProfileRepository {
  @override
  Future<PatientProfile> getByEmail({
    required String email,
    required String token,
  }) => throw UnimplementedError();
  @override
  Future<List<GenderOption>> getGenders({required String token}) =>
      throw UnimplementedError();
  @override
  Future<PatientProfile> updateProfile({
    required int id,
    required String phoneNumber,
    required String gender,
    required String token,
  }) => throw UnimplementedError();
  @override
  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
    required String repeatNewPassword,
    required String token,
  }) => throw UnimplementedError();
}
