import 'package:app_top_medicos/domain/entities/appointment.dart';
import 'package:app_top_medicos/domain/entities/work_schedule.dart';

List<DateTime> nextDays(int count) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return List.generate(count, (i) => start.add(Duration(days: i)));
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String weekdayShort(DateTime d) {
  const names = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  final wd = d.weekday; // 1..7
  return names[wd - 1];
}

String monthYear(DateTime d) {
  const months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
  return '${months[d.month - 1]} ${d.year}';
}

int toMinutes(String hhmm) {
  final parts = hhmm.split(':');
  final h = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  return h * 60 + m;
}

String toHHMM(int minutes) {
  final h = (minutes ~/ 60).toString().padLeft(2, '0');
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

/// Convierte DateTime.weekday (1..7) a tu API day (L..V = 1..5).
int apiDay(DateTime date) => date.weekday; // coincide para L..V

/// slots disponibles = slots por horario - slots ocupados por appointments (overlap).
List<String> buildAvailableSlotsForDate({
  required DateTime date,
  required List<WorkSchedule> schedules,
  required List<Appointment> appointments,
  required String mode, // "P" o "O"
}) {
  final dayOfWeek = apiDay(date); // 1..7
  if (dayOfWeek < 1 || dayOfWeek > 5) return []; // sáb/dom no hay según tu ejemplo

  final dateStr = '${date.year.toString().padLeft(4,'0')}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';

  // horarios válidos del día
  final daySchedules = schedules.where((s) =>
      s.status == '1' &&
      s.day == dayOfWeek &&
      s.modeAttention == mode).toList();

  if (daySchedules.isEmpty) return [];

  // citas del día (no canceladas) para bloquear
  final dayAppointments = appointments.where((a) =>
      a.dateService == dateStr &&
      a.modeAttention == mode &&
      a.stateAttention.toLowerCase() != 'cancelado').toList();

  final occupiedIntervals = dayAppointments.map((a) {
    final start = toMinutes(a.startTime);
    final end = toMinutes(a.endTime);
    return (start, end);
  }).toList();

  final result = <String>[];

  for (final sch in daySchedules) {
    final start = toMinutes(sch.startTime);
    final end = toMinutes(sch.endTime);
    final step = sch.duration;

    // generamos slots: start, start+duration, ... mientras el slot completo quepa antes del end
    for (int t = start; t + step <= end; t += step) {
      final slotStart = t;
      final slotEnd = t + step;

      final overlaps = occupiedIntervals.any((iv) {
        final aStart = iv.$1;
        final aEnd = iv.$2;
        // overlap si se cruzan los intervalos
        return slotStart < aEnd && slotEnd > aStart;
      });

      if (!overlaps) {
        result.add(toHHMM(slotStart));
      }
    }
  }

  // opcional: ordenar y quitar duplicados si hubiera
  final unique = result.toSet().toList()..sort((a,b) => toMinutes(a).compareTo(toMinutes(b)));
  return unique;
}
