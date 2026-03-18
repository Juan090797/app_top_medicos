import 'package:app_top_medicos/domain/datasources/favorite_doctor_datasource.dart';
import 'package:app_top_medicos/domain/entities/favorite_doctor.dart';
import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';
import 'package:dio/dio.dart';

class FavoriteDoctorDatasourceImpl extends FavoriteDoctorDatasource {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://topmedicosperu.com/ms-medical-app/api',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Options _authorizedOptions(String token) {
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<FavoriteDoctor>> getFavorites({
    required String email,
    required String token,
    int page = 0,
    int size = 5,
  }) async {
    try {
      final normalizedEmail = Uri.encodeComponent(email.trim().toLowerCase());
      final response = await dio.get(
        '/doctor-favorites/patient/$normalizedEmail?page=$page&size=$size',
        options: _authorizedOptions(token),
      );

      final json = response.data as Map<String, dynamic>;
      final content = json['content'] as List<dynamic>? ?? [];

      return content.map((item) {
        final doc = item as Map<String, dynamic>;
        final addresses = doc['addresses'] as List<dynamic>? ?? [];

        String? firstAddress;
        bool hasOnline = false;

        for (final addr in addresses) {
          final a = addr as Map<String, dynamic>;
          final tag = a['tag'] as Map<String, dynamic>?;
          final tagTitle = (tag?['title'] ?? '').toString();

          if (tagTitle.toLowerCase().contains('online')) {
            hasOnline = true;
          } else if (firstAddress == null) {
            final location = (a['address'] ?? '').toString();
            if (location.isNotEmpty) {
              firstAddress = location;
            } else {
              firstAddress = '';
            }
          }
        }

        final specialtyNames = (doc['specialtyNames'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();

        return FavoriteDoctor(
          id: (doc['id'] as num?)?.toInt() ?? 0,
          doctorTitle: (doc['doctorTitle'] ?? '').toString(),
          fullName: (doc['fullName'] ?? '').toString(),
          urlImagen: (doc['urlImagen'] ?? '').toString(),
          rating: (doc['rating'] as num?)?.toDouble() ?? 0.0,
          reviewCount: (doc['reviewCount'] as num?)?.toInt() ?? 0,
          specialtyNames: specialtyNames,
          address: firstAddress,
          hasOnline: hasOnline,
          cmp: (doc['cmp'] ?? '').toString(),
        );
      }).toList();
    } on DioException catch (e) {
      throw AuthException(
        'No se pudo cargar los favoritos: ${e.response?.data?['message'] ?? e.message ?? 'desconocido'}',
      );
    }
  }

  @override
  Future<bool> addFavorite({
    required int doctorId,
    required int patientId,
    required String token,
  }) async {
    try {
      final response = await dio.post(
        '/doctor-favorites',
        data: {
          'doctorId': doctorId,
          'patientId': patientId,
        },
        options: _authorizedOptions(token),
      );
      return response.statusCode == 201 || response.data == true;
    } on DioException catch (e) {
      throw AuthException(
        'No se pudo agregar a favoritos: ${e.response?.data?['message'] ?? e.message ?? 'desconocido'}',
      );
    }
  }
}
