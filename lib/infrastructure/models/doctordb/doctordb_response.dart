import 'package:app_top_medicos/infrastructure/models/doctordb/doctor_doctordb.dart';
import 'package:app_top_medicos/infrastructure/models/pagination/pageable.dart';
import 'package:app_top_medicos/infrastructure/models/pagination/sort.dart';

class DoctordbResponse {
  final List<DoctorDoctorDB> content;
  final Pageable pageable;
  final int totalElements;
  final int totalPages;
  final bool last;
  final int size;
  final int number;
  final Sort sort;
  final int numberOfElements;
  final bool first;
  final bool empty;

  DoctordbResponse({
    required this.content,
    required this.pageable,
    required this.totalElements,
    required this.totalPages,
    required this.last,
    required this.size,
    required this.number,
    required this.sort,
    required this.numberOfElements,
    required this.first,
    required this.empty,
  });

  factory DoctordbResponse.fromJson(Map<String, dynamic> json) => DoctordbResponse(
      content: List<DoctorDoctorDB>.from(json['content'].map((x) => DoctorDoctorDB.fromJson(x))),
      pageable: Pageable.fromJson(json['pageable']),
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      last: json['last'],
      size: json['size'],
      number: json['number'],
      sort: Sort.fromJson(json['sort']),
      numberOfElements: json['numberOfElements'],
      first: json['first'],
      empty: json['empty'],
    );

}
