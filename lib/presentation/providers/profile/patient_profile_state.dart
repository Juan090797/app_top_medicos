import 'package:app_top_medicos/domain/entities/gender_option.dart';
import 'package:app_top_medicos/domain/entities/patient_profile.dart';

class PatientProfileState {
  final bool isLoading;
  final bool isSaving;
  final PatientProfile? profile;
  final List<GenderOption> genders;
  final String? errorMessage;
  final String? successMessage;

  const PatientProfileState({
    this.isLoading = true,
    this.isSaving = false,
    this.profile,
    this.genders = const [],
    this.errorMessage,
    this.successMessage,
  });

  PatientProfileState copyWith({
    bool? isLoading,
    bool? isSaving,
    PatientProfile? profile,
    List<GenderOption>? genders,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return PatientProfileState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      profile: profile ?? this.profile,
      genders: genders ?? this.genders,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}