import 'package:app_top_medicos/domain/entities/doctor_service_price.dart';
import 'package:app_top_medicos/domain/entities/patient_booking_info.dart';

abstract class AppointmentBookingRepository {
  Future<List<DoctorServicePrice>> getDoctorServicePrices({
    required int doctorId,
    required String token,
  });

  Future<PatientBookingInfo> getPatientInfo({
    required int userId,
    required String token,
  });
}
