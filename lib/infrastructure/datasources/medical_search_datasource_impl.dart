import 'package:app_top_medicos/domain/datasources/medical_search_datasource.dart';
import 'package:app_top_medicos/domain/entities/doctor.dart';
import 'package:app_top_medicos/domain/entities/medical_search_suggestion.dart';
import 'package:app_top_medicos/infrastructure/auth/jwt_token_service.dart';
import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';
import 'package:app_top_medicos/infrastructure/http/api_error_handler.dart';
import 'package:dio/dio.dart';

class MedicalSearchDatasourceImpl extends MedicalSearchDatasource {
  final JwtTokenService tokenService;

  MedicalSearchDatasourceImpl({JwtTokenService? tokenService})
    : tokenService = tokenService ?? JwtTokenService();

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://topmedicosperu.com/ms-medical-app/api',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Options _authorizedOptions(String token) {
    if (tokenService.isExpired(token)) {
      throw const SessionExpiredException(
        ApiErrorHandler.sessionExpiredMessage,
      );
    }

    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  @override
  Future<List<MedicalSearchSuggestion>> searchSuggestions({
    required String keyword,
    required String token,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await dio.get(
        '/results',
        queryParameters: {
          'keyWord': keyword.trim(),
          'page': page,
          'size': size,
        },
        options: _authorizedOptions(token),
      );

      final json = response.data as Map<String, dynamic>;
      final suggestions = <MedicalSearchSuggestion>[
        ..._readSuggestionPage(
          json['specialties'],
          MedicalSearchSuggestionType.specialty,
        ),
        ..._readSuggestionPage(
          json['treateDisease'],
          MedicalSearchSuggestionType.treatment,
        ),
        ..._readSuggestionPage(
          json['doctors'],
          MedicalSearchSuggestionType.doctor,
        ),
      ];

      final seenKeys = <String>{};
      return suggestions.where((suggestion) {
        final key = '${suggestion.type.name}:${suggestion.title.toLowerCase()}';
        return seenKeys.add(key);
      }).toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.authExceptionFromDio(
        e,
        fallbackMessage: 'No se pudo buscar resultados',
      );
    }
  }

  @override
  Future<List<Doctor>> searchDoctors({
    required String keyword,
    required String token,
    String city = '',
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await dio.get(
        '/doctors/search',
        queryParameters: {
          'keyWord': keyword.trim(),
          'city': city.trim(),
          'page': page,
          'size': size,
        },
        options: _authorizedOptions(token),
      );

      final json = response.data as Map<String, dynamic>;
      final content = json['content'] as List<dynamic>? ?? const [];

      return content
          .whereType<Map<String, dynamic>>()
          .map(_doctorFromSearchJson)
          .toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.authExceptionFromDio(
        e,
        fallbackMessage: 'No se pudo buscar médicos',
      );
    }
  }

  List<MedicalSearchSuggestion> _readSuggestionPage(
    Object? page,
    MedicalSearchSuggestionType type,
  ) {
    if (page is! Map<String, dynamic>) return const [];

    final content = page['content'] as List<dynamic>? ?? const [];
    return content
        .whereType<Map<String, dynamic>>()
        .map((json) {
          final title = _readString(json, [
            'name',
            'fullName',
            'description',
            'title',
          ]);

          return MedicalSearchSuggestion(
            id: (json['id'] as num?)?.toInt() ?? 0,
            title: title,
            imageUrl: _validImageUrl(
              _readString(json, ['urlImagenSp', 'urlImagen', 'urlImage']),
            ),
            type: type,
          );
        })
        .where((suggestion) => suggestion.title.trim().isNotEmpty)
        .toList();
  }

  Doctor _doctorFromSearchJson(Map<String, dynamic> json) {
    final specialtyNames =
        (json['specialtyNames'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .where((item) => item.trim().isNotEmpty)
            .toList();

    return Doctor(
      fullName: _readString(json, ['fullName', 'name']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalComments:
          (json['totalComments'] as num?)?.toInt() ??
          (json['reviewCount'] as num?)?.toInt() ??
          0,
      totalRating: (json['totalRating'] as num?)?.toInt() ?? 0,
      phoneNumber: _readStringList(json['phoneNumber']),
      email: _readString(json, ['email']),
      address: _readAddress(json['addresses']),
      doctorTitle: _readString(json, ['doctorTitle', 'professionalTitle']),
      urlImagen: _validImageUrl(_readString(json, ['urlImagen', 'urlImage'])),
      specialtyNames: specialtyNames,
    );
  }

  String _readAddress(Object? addressesValue) {
    final addresses = addressesValue as List<dynamic>? ?? const [];

    for (final item in addresses.whereType<Map<String, dynamic>>()) {
      final tag = item['tag'] as Map<String, dynamic>?;
      final tagTitle = (tag?['title'] ?? '').toString().toLowerCase();
      if (tagTitle.contains('online')) continue;

      final address = _readString(item, [
        'address',
        'street',
        'placeOfService',
      ]);
      if (address.isNotEmpty) return address;
    }

    return '';
  }

  String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value == null) continue;

      final text = value.toString().trim();
      if (text.isNotEmpty && text.toLowerCase() != 'null') return text;
    }

    return '';
  }

  List<String> _readStringList(Object? value) {
    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty && item != 'null')
          .toList();
    }

    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text.toLowerCase() == 'null' ? const [] : [text];
  }

  String _validImageUrl(String value) {
    final imageUrl = value.trim();
    if (imageUrl.isEmpty ||
        imageUrl.toLowerCase() == 'null' ||
        imageUrl.endsWith('/null') ||
        imageUrl.contains('/static/null')) {
      return '';
    }

    return imageUrl;
  }
}
