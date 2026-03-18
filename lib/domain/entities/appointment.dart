class Appointment {
  final int id;
  final int doctorId;
  final String dateService; // "2026-02-18"
  final String startTime;   // "20:00"
  final String endTime;     // "20:40"
  final String stateAttention; // "Confirmado", "Pendiente", etc.
  final String modeAttention;  // "P"/"O"

  const Appointment({
    required this.id,
    required this.doctorId,
    required this.dateService,
    required this.startTime,
    required this.endTime,
    required this.stateAttention,
    required this.modeAttention,
  });
}
