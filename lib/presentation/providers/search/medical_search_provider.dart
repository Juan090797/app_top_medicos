import 'package:app_top_medicos/infrastructure/datasources/medical_search_datasource_impl.dart';
import 'package:app_top_medicos/infrastructure/repositories/medical_search_repository_impl.dart';
import 'package:app_top_medicos/presentation/providers/auth/auth_provider.dart';
import 'package:app_top_medicos/presentation/providers/auth/jwt_token_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'medical_search_notifier.dart';
import 'medical_search_state.dart';

final medicalSearchProvider = StateNotifierProvider.autoDispose<
  MedicalSearchNotifier,
  MedicalSearchState
>((ref) {
  final authState = ref.watch(authProvider);
  final tokenService = ref.watch(jwtTokenServiceProvider);
  final datasource = MedicalSearchDatasourceImpl(tokenService: tokenService);

  return MedicalSearchNotifier(
    repository: MedicalSearchRepositoryImpl(datasource),
    token: authState.token,
  );
});
