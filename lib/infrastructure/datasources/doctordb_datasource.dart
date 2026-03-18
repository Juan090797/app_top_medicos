
import 'package:app_top_medicos/domain/datasources/doctor_datasource.dart';
import 'package:app_top_medicos/domain/entities/appointment.dart';
import 'package:app_top_medicos/domain/entities/doctor.dart';
import 'package:app_top_medicos/domain/entities/doctor_detail.dart';
import 'package:app_top_medicos/domain/entities/mode_attention.dart';
import 'package:app_top_medicos/domain/entities/work_schedule.dart';
import 'package:app_top_medicos/infrastructure/mappers/doctor_mapper.dart';
import 'package:app_top_medicos/infrastructure/models/doctordb/doctordb_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class DoctordbDatasource extends DoctorDatasource {

  final dio = Dio(BaseOptions(
    baseUrl: 'https://topmedicosperu.com/ms-medical-app/api',
  ));

  List<Doctor> _jsonToDoctors( Map<String,dynamic> json ) {
    debugPrint('Inicio de _jsonToDoctors con json');
    final doctordbResponse = DoctordbResponse.fromJson(json);
    debugPrint('Parsed DoctordbResponse: $doctordbResponse');
    final List<Doctor> doctors = doctordbResponse.content
    .map(
      (doctorDoctorDB) => DoctorMapper.doctordbToEntity(doctorDoctorDB)
    )
    .toList();
    return doctors;
  }

  @override
  Future<List<Doctor>> getTopDoctors({int page = 0}) async {
    final response = await dio.get(
      '/doctors/top',
      queryParameters: {
        'page': page,
        'size': 15,
      },
    );

    return _jsonToDoctors(response.data);
  }

  @override
  Future<DoctorDetail> getDoctorByFullName(String fullName) async {
    final resp = await dio.get(
      '/doctors/search-by-fullname',
      queryParameters: {'fullName': fullName},
    );

    final json = resp.data as Map<String, dynamic>;

    final specialties = (json['specialties'] as List<dynamic>?)
            ?.map((e) => (e as Map<String, dynamic>)['name'].toString())
            .toList() ??
        const <String>[];

    return DoctorDetail(
      id: json['id'],
      name: json['name'] ?? '',
      lastName: json['lastName'] ?? '',
      professionalTitle: json['professionalTitle'] ?? '',
      aboutMe: json['aboutMe'] ?? '',
      urlImage: json['urlImage'] ?? '',
      specialties: specialties,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      cmp: json['cmp']?.toString() ?? '',
    );
  }

  @override
  Future<List<ModeAttention>> getModesAttention(int doctorId) async {
    final resp = await dio.get(
      '/modes-attention-doctor/list',
      queryParameters: {'doctorId': doctorId},
    );

    final list = resp.data as List<dynamic>;
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return ModeAttention(
        doctorId: m['doctorId'],
        modesAttentionId: m['modesAttentionId'],
        description: m['description'] ?? '',
      );
    }).toList();
  }

  @override
  Future<List<WorkSchedule>> getWorkSchedules(int doctorId) async {
    final resp = await dio.get(
      '/work-schedules/doctor',
      queryParameters: {'doctorId': doctorId},
    );

    final list = resp.data as List<dynamic>;
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      debugPrint('Fetched ${resp.data.length} work schedules for doctorId $doctorId');
      return WorkSchedule(
        id: m['id'],
        day: m['day'],
        startTime: m['startTime'] ?? '',
        endTime: m['endTime'] ?? '',
        duration: m['duration'],
        status: m['status'] ?? '',
        modeAttention: m['modeAttention'] ?? '',
      );
    }).toList();
  }

  @override
  Future<List<Appointment>> getAppointmentsByDoctor(int doctorId, {int page = 0, int size = 100}) async {
    final resp = await dio.get(
      '/appointments/by-doctor',
      queryParameters: {'doctorId': doctorId, 'page': page, 'size': size},
    );

    final json = resp.data as Map<String, dynamic>;
    final content = (json['content'] as List<dynamic>?) ?? const [];

    return content.map((e) {
      final m = e as Map<String, dynamic>;
      return Appointment(
        id: m['id'],
        doctorId: m['doctorId'],
        dateService: m['dateService'] ?? '',
        startTime: m['startTime'] ?? '',
        endTime: m['endTime'] ?? '',
        stateAttention: m['stateAttention'] ?? '',
        modeAttention: m['modeAttention'] ?? '',
      );
    }).toList();
  }

}
