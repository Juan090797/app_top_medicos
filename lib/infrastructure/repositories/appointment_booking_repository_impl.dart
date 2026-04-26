import 'package:app_top_medicos/domain/datasources/appointment_booking_datasource.dart';
import 'package:app_top_medicos/domain/entities/doctor_service_price.dart';
import 'package:app_top_medicos/domain/entities/patient_booking_info.dart';
import 'package:app_top_medicos/domain/repositories/appointment_booking_repository.dart';

class AppointmentBookingRepositoryImpl implements AppointmentBookingRepository {
  final AppointmentBookingDatasource datasource;

  AppointmentBookingRepositoryImpl(this.datasource);

  @override
  Future<List<DoctorServicePrice>> getDoctorServicePrices({
    required int doctorId,
    required String token,
  }) {
    return datasource.getDoctorServicePrices(doctorId: doctorId, token: token);
  }

  @override
  Future<PatientBookingInfo> getPatientInfo({
    required int userId,
    required String token,
  }) {
    return datasource.getPatientInfo(userId: userId, token: token);
  }
}
