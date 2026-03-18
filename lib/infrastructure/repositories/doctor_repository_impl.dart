
import 'package:app_top_medicos/domain/datasources/doctor_datasource.dart';
import 'package:app_top_medicos/domain/entities/appointment.dart';
import 'package:app_top_medicos/domain/entities/doctor.dart';
import 'package:app_top_medicos/domain/entities/doctor_detail.dart';
import 'package:app_top_medicos/domain/entities/mode_attention.dart';
import 'package:app_top_medicos/domain/entities/work_schedule.dart';
import 'package:app_top_medicos/domain/repositories/doctor_repository.dart';

class DoctorRepositoryImpl  implements DoctorRepository {
  
  final DoctorDatasource doctorDatasource;

  DoctorRepositoryImpl(this.doctorDatasource);

  @override
  Future<List<Doctor>> getTopDoctors({int page = 0}) {
    return doctorDatasource.getTopDoctors(page: page);
  }

  @override
  Future<DoctorDetail> getDoctorByFullName(String fullName) => doctorDatasource.getDoctorByFullName(fullName);

  @override
  Future<List<ModeAttention>> getModesAttention(int doctorId) => doctorDatasource.getModesAttention(doctorId);

  @override
  Future<List<WorkSchedule>> getWorkSchedules(int doctorId) => doctorDatasource.getWorkSchedules(doctorId);

  @override
  Future<List<Appointment>> getAppointmentsByDoctor(int doctorId, {int page = 0, int size = 100}) => doctorDatasource.getAppointmentsByDoctor(doctorId, page: page, size: size);

}
