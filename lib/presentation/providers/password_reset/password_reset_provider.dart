import 'package:app_top_medicos/infrastructure/datasources/password_reset_datasource_impl.dart';
import 'package:app_top_medicos/infrastructure/repositories/password_reset_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final passwordResetRepositoryProvider = Provider((ref) {
  return PasswordResetRepositoryImpl(PasswordResetDatasourceImpl());
});
