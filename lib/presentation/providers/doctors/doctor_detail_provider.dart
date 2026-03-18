import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/doctor_detail.dart';
import '../../../domain/entities/mode_attention.dart';
import '../../../domain/entities/work_schedule.dart';
import '../../../domain/entities/appointment.dart';
import 'doctor_repository_provider.dart';

class DoctorDetailBundle {
  final DoctorDetail doctor;
  final List<ModeAttention> modes;
  final List<WorkSchedule> schedules;
  final List<Appointment> appointments;

  const DoctorDetailBundle({
    required this.doctor,
    required this.modes,
    required this.schedules,
    required this.appointments,
  });
}

final doctorDetailProvider = FutureProvider.family<DoctorDetailBundle, String>((ref, fullName) async {
  final repo = ref.watch(doctorRepositoryProvider);

  final doctor = await repo.getDoctorByFullName(fullName);
  final doctorId = doctor.id;

  final results = await Future.wait([
    repo.getModesAttention(doctorId),
    repo.getWorkSchedules(doctorId),
    repo.getAppointmentsByDoctor(doctorId, page: 0, size: 100),
  ]);
  debugPrint('Fetched doctor detail for $fullName: modes ${results[0].length}, schedules ${results[1].length}, appointments ${results[2].length}');

  return DoctorDetailBundle(
    doctor: doctor,
    modes: results[0] as List<ModeAttention>,
    schedules: results[1] as List<WorkSchedule>,
    appointments: results[2] as List<Appointment>,
  );
});
