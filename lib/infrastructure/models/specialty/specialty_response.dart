import 'package:app_top_medicos/domain/entities/specialty.dart';

class SpecialtyResponse {

  final List<Specialty> results;

  SpecialtyResponse({
    required this.results,
  });

  factory SpecialtyResponse.fromJson(dynamic json) {

    final List<dynamic> list = json as List<dynamic>;

    return SpecialtyResponse(
      results: list.map((e) {

        final map = e as Map<String, dynamic>;

        return Specialty(
          id: map['id'],
          name: map['name'] ?? '',
          urlImagenSp: map['urlImagenSp'] ?? '',
        );

      }).toList(),
    );
  }
}
