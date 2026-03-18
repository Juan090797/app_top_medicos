import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_top_medicos/infrastructure/datasources/doctordb_datasource.dart';
import 'package:app_top_medicos/infrastructure/repositories/doctor_repository_impl.dart';
import 'doctors_notifier.dart';
import 'doctors_state.dart';

final doctorsProvider =
    StateNotifierProvider<DoctorsNotifier, DoctorsState>((ref) {

  final repository =
      DoctorRepositoryImpl(DoctordbDatasource());

  return DoctorsNotifier(repository);
});
