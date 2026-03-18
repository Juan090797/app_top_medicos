import 'package:app_top_medicos/domain/entities/appointment.dart';
import 'package:app_top_medicos/domain/entities/doctor.dart';
import 'package:app_top_medicos/domain/entities/doctor_detail.dart';
import 'package:app_top_medicos/domain/entities/mode_attention.dart';
import 'package:app_top_medicos/domain/entities/work_schedule.dart';

abstract class DoctorRepository {

  Future<List<Doctor>> getTopDoctors({int page});
  Future<DoctorDetail> getDoctorByFullName(String fullName);
  Future<List<ModeAttention>> getModesAttention(int doctorId);
  Future<List<WorkSchedule>> getWorkSchedules(int doctorId);
  Future<List<Appointment>> getAppointmentsByDoctor(int doctorId, {int page = 0, int size = 100});

}
