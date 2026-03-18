import 'package:app_top_medicos/domain/datasources/favorite_doctor_datasource.dart';
import 'package:app_top_medicos/domain/entities/favorite_doctor.dart';
import 'package:app_top_medicos/domain/repositories/favorite_doctor_repository.dart';

class FavoriteDoctorRepositoryImpl extends FavoriteDoctorRepository {
  final FavoriteDoctorDatasource datasource;

  FavoriteDoctorRepositoryImpl(this.datasource);

  @override
  Future<List<FavoriteDoctor>> getFavorites({
    required String email,
    required String token,
    int page = 0,
    int size = 5,
  }) {
    return datasource.getFavorites(
      email: email,
      token: token,
      page: page,
      size: size,
    );
  }

  @override
  Future<bool> addFavorite({
    required int doctorId,
    required int patientId,
    required String token,
  }) {
    return datasource.addFavorite(
      doctorId: doctorId,
      patientId: patientId,
      token: token,
    );
  }
}
