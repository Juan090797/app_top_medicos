import 'package:app_top_medicos/domain/entities/favorite_doctor.dart';

abstract class FavoriteDoctorRepository {
  Future<List<FavoriteDoctor>> getFavorites({
    required String email,
    required String token,
    int page = 0,
    int size = 5,
  });

  Future<bool> addFavorite({
    required int doctorId,
    required int patientId,
    required String token,
  });
}
