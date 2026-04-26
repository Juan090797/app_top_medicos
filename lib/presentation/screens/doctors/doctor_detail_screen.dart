import 'package:app_top_medicos/domain/entities/work_schedule.dart';
import 'package:app_top_medicos/infrastructure/datasources/favorite_doctor_datasource_impl.dart';
import 'package:app_top_medicos/infrastructure/datasources/patient_profile_datasource_impl.dart';
import 'package:app_top_medicos/infrastructure/errors/auth_errors.dart';
import 'package:app_top_medicos/infrastructure/repositories/favorite_doctor_repository_impl.dart';
import 'package:app_top_medicos/presentation/providers/auth/auth_provider.dart';
import 'package:app_top_medicos/presentation/providers/auth/jwt_token_service_provider.dart';
import 'package:app_top_medicos/presentation/screens/booking/appointment_booking_screen.dart';
import 'package:app_top_medicos/presentation/widgets/layout/app_shell.dart';
import 'package:app_top_medicos/presentation/widgets/shared/initials_avatar.dart';
import 'package:app_top_medicos/shared/utils/schedule_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/providers/doctors/doctor_detail_provider.dart';

class DoctorDetailScreen extends ConsumerStatefulWidget {
  static const name = 'doctor_detail_screen';
  final String fullName;

  const DoctorDetailScreen({super.key, required this.fullName});

  @override
  ConsumerState<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends ConsumerState<DoctorDetailScreen> {
  DateTime selectedDate = DateTime.now();
  String selectedMode = 'P';

  String? selectedTime;
  bool aboutExpanded = false;
  bool _isFaving = false;

  Future<void> _addToFavorites(int doctorId) async {
    final authState = ref.read(authProvider);
    final token = authState.token;
    final email = authState.user?.email;

    if (token == null || email == null) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener la información del paciente'),
            ),
          );
      }
      return;
    }

    setState(() => _isFaving = true);

    try {
      final tokenService = ref.read(jwtTokenServiceProvider);
      final profileDs = PatientProfileDatasourceImpl(
        tokenService: tokenService,
      );
      final patient = await profileDs.getByEmail(email: email, token: token);

      final repo = FavoriteDoctorRepositoryImpl(
        FavoriteDoctorDatasourceImpl(tokenService: tokenService),
      );
      await repo.addFavorite(
        doctorId: doctorId,
        patientId: patient.id,
        token: token,
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(content: Text('Doctor agregado a favoritos')),
          );
      }
    } catch (e) {
      if (e is SessionExpiredException) {
        await ref.read(authProvider.notifier).expireSession();
      }

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isFaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(doctorDetailProvider(widget.fullName));

    return AppShell(
      title: 'Horario del Doctor',
      showBottomNav: false,
      currentIndex: 0,
      onTap: (i) {
        if (i == 0) context.go('/');
        if (i == 1) context.go('/appointments');
        if (i == 2) context.go('/profile');
      },
      actions: [
        async.whenOrNull(
              data:
                  (bundle) => IconButton(
                    onPressed:
                        _isFaving
                            ? null
                            : () => _addToFavorites(bundle.doctor.id),
                    icon:
                        _isFaving
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(
                              Icons.favorite_border,
                              color: Colors.white,
                            ),
                  ),
            ) ??
            const SizedBox.shrink(),
      ],
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bundle) {
          final modeSet = bundle.modes.map((m) => m.description).toSet();
          final effectiveMode =
              modeSet.contains(selectedMode)
                  ? selectedMode
                  : (modeSet.isNotEmpty ? modeSet.first : 'P');

          // Días hoy → +30,
          final days = nextDays(31); //.where((d) => d.weekday <= 5).toList();

          final slots = buildAvailableSlotsForDate(
            date: selectedDate,
            schedules: bundle.schedules,
            appointments: bundle.appointments,
            mode: effectiveMode,
          );

          final morning = slots.where((s) => toMinutes(s) < 12 * 60).toList();
          final afternoon =
              slots.where((s) => toMinutes(s) >= 12 * 60).toList();
          final bottomSafeArea = MediaQuery.paddingOf(context).bottom;
          final reserveButtonBottom = bottomSafeArea + 18;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  18,
                  14,
                  18,
                  140 + bottomSafeArea,
                ), // 👈 deja espacio para botón inferior
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== HEADER CENTRADO =====
                    Center(
                      child: Column(
                        children: [
                          bundle.doctor.urlImage.isNotEmpty
                              ? CircleAvatar(
                                radius: 52,
                                backgroundImage: NetworkImage(
                                  bundle.doctor.urlImage,
                                ),
                              )
                              : InitialsAvatar(
                                fullName: bundle.doctor.fullName,
                                radius: 52,
                              ),
                          const SizedBox(height: 12),
                          Text(
                            bundle.doctor.fullName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              if (bundle.doctor.specialties.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE6F0FF),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    bundle.doctor.specialties.first,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0E2E3F),
                                    ),
                                  ),
                                ),
                              Text(
                                'CMP ${bundle.doctor.cmp}',
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ===== CARDS METRICAS =====
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.groups_2_outlined,
                            value: '500+',
                            label: 'Pacientes',
                            iconColor: Colors.blue,
                            bgColor: Colors.blue.withValues(alpha: 0.15),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.star,
                            value: bundle.doctor.rating.toStringAsFixed(1),
                            label: 'Valoración',
                            iconColor: Colors.amber,
                            bgColor: Colors.amber.withValues(alpha: 0.2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            icon: Icons.chat_bubble_outline,
                            value: '${bundle.doctor.reviewCount}',
                            label: 'Reseñas',
                            iconColor: Colors.purple,
                            bgColor: Colors.purple.withValues(alpha: 0.15),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // ===== ABOUT =====
                    const Text(
                      'Sobre el Doctor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _AboutText(
                      text: bundle.doctor.aboutMe,
                      expanded: aboutExpanded,
                      onToggle:
                          () => setState(() => aboutExpanded = !aboutExpanded),
                    ),

                    const SizedBox(height: 18),

                    // ===== MODOS DE ATENCIÓN (opcional) =====
                    if (modeSet.isNotEmpty) ...[
                      const Text(
                        'Tipo de atención',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children:
                            modeSet.map((m) {
                              final selected = m == effectiveMode;
                              return ChoiceChip(
                                label: Text(m == 'P' ? 'Presencial' : 'Online'),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() {
                                    selectedMode = m;
                                    selectedTime =
                                        null; // 👈 si cambia el modo, reinicia hora
                                  });
                                },
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 18),
                    ],

                    // ===== HORARIOS DISPONIBLES =====
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Horarios Disponibles',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          monthYear(selectedDate),
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ===== LISTA DE DÍAS =====
                    SizedBox(
                      height: 84,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: days.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final d = days[i];
                          final selected = isSameDay(d, selectedDate);

                          return InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap:
                                () => setState(() {
                                  selectedDate = d;
                                  selectedTime =
                                      null; // 👈 cambia día, reinicia hora
                                }),
                            child: Container(
                              width: 64,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color:
                                    selected
                                        ? const Color(0xFF0E2E3F)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.black12),
                                boxShadow:
                                    selected
                                        ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.10,
                                            ),
                                            blurRadius: 14,
                                            offset: const Offset(0, 8),
                                          ),
                                        ]
                                        : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    weekdayShort(d),
                                    style: TextStyle(
                                      color:
                                          selected
                                              ? Colors.white70
                                              : Colors.black54,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${d.day}',
                                    style: TextStyle(
                                      color:
                                          selected
                                              ? Colors.white
                                              : Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ===== HORAS =====
                    if (slots.isEmpty)
                      const Text(
                        'No hay horarios disponibles para este día.',
                        style: TextStyle(color: Colors.black54),
                      )
                    else ...[
                      if (morning.isNotEmpty) ...[
                        const Text(
                          'Mañana',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children:
                              morning.map((t) {
                                final isSelected = selectedTime == t;
                                return _TimeChip(
                                  time: t,
                                  selected: isSelected,
                                  enabled: true,
                                  onTap: () => setState(() => selectedTime = t),
                                );
                              }).toList(),
                        ),
                        const SizedBox(height: 18),
                      ],
                      if (afternoon.isNotEmpty) ...[
                        const Text(
                          'Tarde',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children:
                              afternoon.map((t) {
                                final isSelected = selectedTime == t;
                                return _TimeChip(
                                  time: t,
                                  selected: isSelected,
                                  enabled: true,
                                  onTap: () => setState(() => selectedTime = t),
                                );
                              }).toList(),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              // ===== BOTÓN RESERVAR (solo si hay día+h ora) =====
              if (selectedTime != null)
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: reserveButtonBottom, // respeta navegación Android
                  child: _ReserveButton(
                    onTap: () {
                      context.push(
                        '/appointment-booking',
                        extra: AppointmentBookingArgs(
                          doctorId: bundle.doctor.id,
                          doctorName: bundle.doctor.fullName,
                          date: selectedDate,
                          startTime: selectedTime!,
                          durationMinutes: _durationForSelection(
                            date: selectedDate,
                            schedules: bundle.schedules,
                            mode: effectiveMode,
                            time: selectedTime!,
                          ),
                          modeAttention: effectiveMode,
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  int _durationForSelection({
    required DateTime date,
    required List<WorkSchedule> schedules,
    required String mode,
    required String time,
  }) {
    final dayOfWeek = apiDay(date);
    final selectedMinutes = toMinutes(time);

    final matchingSchedules =
        schedules.where((schedule) {
          if (schedule.status != '1' ||
              schedule.day != dayOfWeek ||
              schedule.modeAttention != mode) {
            return false;
          }

          final start = toMinutes(schedule.startTime);
          final end = toMinutes(schedule.endTime);
          return selectedMinutes >= start &&
              selectedMinutes + schedule.duration <= end;
        }).toList();

    if (matchingSchedules.isEmpty) return 30;

    matchingSchedules.sort(
      (a, b) => toMinutes(a.startTime).compareTo(toMinutes(b.startTime)),
    );
    return matchingSchedules.first.duration;
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color bgColor;

  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor, // 👈 fondo del círculo
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class _AboutText extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  const _AboutText({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final safe = text.trim().isEmpty ? 'Sin descripción.' : text.trim();

    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(
          text: safe,
          style: const TextStyle(
            color: Colors.black54,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
        );

        final tp = TextPainter(
          text: span,
          maxLines: 4,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final exceeds = tp.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              safe,
              maxLines: expanded ? null : 4,
              overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black54,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (exceeds)
              InkWell(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    expanded ? 'Ver menos' : 'Leer más',
                    style: const TextStyle(
                      color: Color(0xFF2E5BFF),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _TimeChip({
    required this.time,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF0E2E3F) : Colors.white;
    final fg = selected ? Colors.white : Colors.black87;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
            boxShadow:
                selected
                    ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ]
                    : null,
          ),
          child: Text(
            time,
            style: TextStyle(fontWeight: FontWeight.w900, color: fg),
          ),
        ),
      ),
    );
  }
}

class _ReserveButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ReserveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(16),
      color: const Color(0xFF0E2E3F),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: const Center(
            child: Text(
              'Reservar Cita',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
