import 'package:app_top_medicos/presentation/providers/auth/auth_provider.dart';
import 'package:app_top_medicos/presentation/providers/profile/patient_profile_notifier.dart';
import 'package:app_top_medicos/presentation/providers/profile/patient_profile_repository_provider.dart';
import 'package:app_top_medicos/presentation/providers/profile/patient_profile_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final patientProfileProvider = StateNotifierProvider.autoDispose<
    PatientProfileNotifier,
    PatientProfileState>((ref) {
  final authState = ref.watch(authProvider);
  final repository = ref.watch(patientProfileRepositoryProvider);

  final token = authState.token;
  final email = authState.user?.email;

  if (token == null || token.isEmpty || email == null || email.isEmpty) {
    return PatientProfileNotifier.empty();
  }

  return PatientProfileNotifier(
    repository: repository,
    email: email,
    token: token,
  );
});