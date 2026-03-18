class WorkSchedule {
  final int id;
  final int day; // 1..5 (L..V)
  final String startTime; // "18:00"
  final String endTime;   // "21:00"
  final int duration;     // minutos
  final String status;    // "1"
  final String modeAttention; // "P" o "O"

  const WorkSchedule({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.status,
    required this.modeAttention,
  });
}
