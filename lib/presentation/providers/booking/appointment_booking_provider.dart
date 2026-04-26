import 'package:app_top_medicos/domain/entities/doctor_service_price.dart';
import 'package:app_top_medicos/domain/entities/patient_booking_info.dart';
import 'package:app_top_medicos/infrastructure/datasources/appointment_booking_datasource_impl.dart';
import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';
import 'package:app_top_medicos/infrastructure/repositories/appointment_booking_repository_impl.dart';
import 'package:app_top_medicos/presentation/providers/auth/auth_provider.dart';
import 'package:app_top_medicos/presentation/providers/auth/jwt_token_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appointmentBookingRepositoryProvider = Provider((ref) {
  final tokenService = ref.watch(jwtTokenServiceProvider);
  return AppointmentBookingRepositoryImpl(
    AppointmentBookingDatasourceImpl(tokenService: tokenService),
  );
});

final doctorServicePricesProvider =
    FutureProvider.family<List<DoctorServicePrice>, int>((ref, doctorId) async {
      final token = _readToken(ref);
      final repository = ref.watch(appointmentBookingRepositoryProvider);

      return repository.getDoctorServicePrices(
        doctorId: doctorId,
        token: token,
      );
    });

final patientBookingInfoProvider = FutureProvider<PatientBookingInfo>((
  ref,
) async {
  final token = _readToken(ref);
  final tokenService = ref.watch(jwtTokenServiceProvider);
  final payload = tokenService.decodePayload(token);
  final userId = _readUserId(payload);
  final repository = ref.watch(appointmentBookingRepositoryProvider);

  return repository.getPatientInfo(userId: userId, token: token);
});

String _readToken(Ref ref) {
  final token = ref.watch(authProvider).token;
  if (token == null || token.trim().isEmpty) {
    throw const AuthException(
      'Inicia sesión nuevamente para reservar una cita',
    );
  }

  return token;
}

int _readUserId(Map<String, dynamic> payload) {
  for (final key in ['userId', 'id', 'user_id', 'idUser']) {
    final value = payload[key];
    if (value is int) return value;
    if (value is num) return value.toInt();

    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
  }

  for (final key in ['user', 'usuario', 'account']) {
    final value = payload[key];
    if (value is Map<String, dynamic>) {
      try {
        return _readUserId(value);
      } on AuthException {
        continue;
      }
    }
  }

  throw const AuthException('El token de sesión no contiene userId');
}
