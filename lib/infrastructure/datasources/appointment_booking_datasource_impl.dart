import 'package:app_top_medicos/domain/datasources/appointment_booking_datasource.dart';
import 'package:app_top_medicos/domain/entities/doctor_service_price.dart';
import 'package:app_top_medicos/domain/entities/patient_booking_info.dart';
import 'package:app_top_medicos/infrastructure/auth/jwt_token_service.dart';
import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';
import 'package:app_top_medicos/infrastructure/http/api_error_handler.dart';
import 'package:dio/dio.dart';

class AppointmentBookingDatasourceImpl extends AppointmentBookingDatasource {
  final JwtTokenService tokenService;

  AppointmentBookingDatasourceImpl({JwtTokenService? tokenService})
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
  Future<List<DoctorServicePrice>> getDoctorServicePrices({
    required int doctorId,
    required String token,
  }) async {
    try {
      final response = await dio.get(
        '/service-prices/by-doctor',
        queryParameters: {'doctorId': doctorId},
        options: _authorizedOptions(token),
      );

      final list = response.data as List<dynamic>? ?? const [];
      return list.whereType<Map<String, dynamic>>().map((json) {
        return DoctorServicePrice(
          idService: (json['idService'] as num?)?.toInt() ?? 0,
          nameService: (json['nameService'] ?? '').toString(),
          priceService: (json['priceService'] as num?)?.toDouble() ?? 0,
        );
      }).toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.authExceptionFromDio(
        e,
        fallbackMessage: 'No se pudo cargar los servicios del doctor',
      );
    }
  }

  @override
  Future<PatientBookingInfo> getPatientInfo({
    required int userId,
    required String token,
  }) async {
    try {
      final response = await dio.get(
        '/patients/patient-info',
        queryParameters: {'userId': userId},
        options: _authorizedOptions(token),
      );

      final json = response.data as Map<String, dynamic>;
      return PatientBookingInfo(
        idPaciente: (json['idPaciente'] as num?)?.toInt() ?? 0,
        nombres: (json['nombres'] ?? '').toString(),
        apellidos: (json['apellidos'] ?? '').toString(),
        telefono: (json['telefono'] ?? '').toString(),
        correo: (json['correo'] ?? '').toString(),
      );
    } on DioException catch (e) {
      throw ApiErrorHandler.authExceptionFromDio(
        e,
        fallbackMessage: 'No se pudo cargar la información del paciente',
      );
    }
  }
}
