import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_top_medicos/domain/repositories/auth_repository.dart';
import 'package:app_top_medicos/infrastructure/datasources/auth_local_storage.dart';
import 'package:app_top_medicos/infrastructure/datasources/authdb_datasource.dart';
import 'package:app_top_medicos/infrastructure/repositories/auth_repository_impl.dart';
import 'jwt_token_service_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final tokenService = ref.watch(jwtTokenServiceProvider);

  return AuthRepositoryImpl(
    AuthDbDatasource(tokenService: tokenService),
    AuthLocalStorage(),
  );
});
