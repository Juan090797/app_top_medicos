import 'package:app_top_medicos/domain/entities/doctor_service_price.dart';
import 'package:app_top_medicos/presentation/providers/booking/appointment_booking_provider.dart';
import 'package:app_top_medicos/presentation/widgets/layout/app_shell.dart';
import 'package:app_top_medicos/shared/colors.dart';
import 'package:app_top_medicos/shared/utils/schedule_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppointmentBookingArgs {
  final int doctorId;
  final String doctorName;
  final DateTime date;
  final String startTime;
  final int durationMinutes;
  final String modeAttention;

  const AppointmentBookingArgs({
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.startTime,
    required this.durationMinutes,
    required this.modeAttention,
  });
}

class AppointmentBookingScreen extends ConsumerStatefulWidget {
  static const name = 'appointment_booking_screen';

  final AppointmentBookingArgs args;

  const AppointmentBookingScreen({super.key, required this.args});

  @override
  ConsumerState<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState
    extends ConsumerState<AppointmentBookingScreen> {
  DoctorServicePrice? selectedService;
  bool isFirstVisit = true;

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(
      doctorServicePricesProvider(widget.args.doctorId),
    );
    final patientAsync = ref.watch(patientBookingInfoProvider);

    return AppShell(
      title: 'Reserva de Cita',
      showBottomNav: false,
      currentIndex: 0,
      onTap: (i) {
        if (i == 0) context.go('/');
        if (i == 1) context.go('/appointments');
        if (i == 2) context.go('/profile');
      },
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FormSectionTitle(title: 'Información de Cita'),
                const SizedBox(height: 16),
                servicesAsync.when(
                  loading:
                      () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  error:
                      (e, _) => _InlineError(
                        message: 'No se pudo cargar los servicios: $e',
                      ),
                  data:
                      (services) => _AppointmentInfoForm(
                        args: widget.args,
                        services: services,
                        selectedService: selectedService,
                        onServiceChanged:
                            (service) =>
                                setState(() => selectedService = service),
                      ),
                ),
                const SizedBox(height: 24),
                const _FormSectionTitle(title: 'Información Personal'),
                const SizedBox(height: 16),
                patientAsync.when(
                  loading:
                      () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  error:
                      (e, _) => _InlineError(
                        message: 'No se pudo cargar tu información: $e',
                      ),
                  data:
                      (patient) => _PersonalInfoForm(
                        names: patient.nombres,
                        lastNames: patient.apellidos,
                        phone: patient.telefono,
                        email: patient.correo,
                      ),
                ),
                const SizedBox(height: 18),
                CheckboxListTile(
                  value: isFirstVisit,
                  onChanged:
                      (value) => setState(() => isFirstVisit = value ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.darkBlue,
                  title: const Text(
                    '¿Es tu primera visita con este especialista?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3C454C),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        selectedService == null ? null : _showPendingMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      disabledBackgroundColor: const Color(0xFF9DB6C6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Reservar Cita',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPendingMessage() {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('El servicio para confirmar la reserva está pendiente'),
        ),
      );
  }
}

class _AppointmentInfoForm extends StatelessWidget {
  final AppointmentBookingArgs args;
  final List<DoctorServicePrice> services;
  final DoctorServicePrice? selectedService;
  final ValueChanged<DoctorServicePrice?> onServiceChanged;

  const _AppointmentInfoForm({
    required this.args,
    required this.services,
    required this.selectedService,
    required this.onServiceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final endTime = toHHMM(toMinutes(args.startTime) + args.durationMinutes);

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 620;
            final children = [
              _ServiceDropdown(
                services: services,
                selectedService: selectedService,
                onChanged: onServiceChanged,
              ),
              _ReadOnlyField(
                label: 'Precio (S/.)*',
                value:
                    selectedService == null
                        ? ''
                        : selectedService!.priceService.toStringAsFixed(2),
              ),
            ];

            if (!isWide) {
              return Column(
                children: [
                  children[0],
                  const SizedBox(height: 14),
                  children[1],
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: children[0]),
                const SizedBox(width: 14),
                Expanded(child: children[1]),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        _ReadOnlyField(
          label: 'Modalidad de Atención',
          value: args.modeAttention == 'P' ? 'Presencial' : 'Online',
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 620;
            final children = [
              _ReadOnlyField(
                label: 'Fecha de la Cita*',
                value: _formatDate(args.date),
                icon: Icons.calendar_month_outlined,
              ),
              _ReadOnlyField(
                label: 'De*',
                value: args.startTime,
                icon: Icons.schedule,
              ),
              _ReadOnlyField(label: 'A*', value: endTime, icon: Icons.schedule),
            ];

            if (!isWide) {
              return Column(
                children: [
                  children[0],
                  const SizedBox(height: 14),
                  children[1],
                  const SizedBox(height: 14),
                  children[2],
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: children[0]),
                const SizedBox(width: 14),
                Expanded(child: children[1]),
                const SizedBox(width: 14),
                Expanded(child: children[2]),
              ],
            );
          },
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _PersonalInfoForm extends StatelessWidget {
  final String names;
  final String lastNames;
  final String phone;
  final String email;

  const _PersonalInfoForm({
    required this.names,
    required this.lastNames,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 620;
        final fields = [
          _ReadOnlyField(
            label: 'Nombre*',
            value: names,
            icon: Icons.account_circle_outlined,
          ),
          _ReadOnlyField(
            label: 'Apellidos*',
            value: lastNames,
            icon: Icons.account_circle_outlined,
          ),
          _ReadOnlyField(
            label: 'Teléfono móvil*',
            value: phone.isEmpty ? '' : '+51  $phone',
            icon: Icons.phone_outlined,
          ),
          _ReadOnlyField(
            label: 'Correo electrónico*',
            value: email,
            icon: Icons.mail_outline,
          ),
        ];

        if (!isWide) {
          return Column(
            children: [
              fields[0],
              const SizedBox(height: 14),
              fields[1],
              const SizedBox(height: 14),
              fields[2],
              const SizedBox(height: 14),
              fields[3],
            ],
          );
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: fields[0]),
                const SizedBox(width: 14),
                Expanded(child: fields[1]),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: fields[2]),
                const SizedBox(width: 14),
                Expanded(child: fields[3]),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ServiceDropdown extends StatelessWidget {
  final List<DoctorServicePrice> services;
  final DoctorServicePrice? selectedService;
  final ValueChanged<DoctorServicePrice?> onChanged;

  const _ServiceDropdown({
    required this.services,
    required this.selectedService,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DoctorServicePrice>(
      value: selectedService,
      isExpanded: true,
      decoration: _fieldDecoration('Servicio*'),
      hint: const Text('Servicio*'),
      items:
          services.map((service) {
            return DropdownMenuItem(
              value: service,
              child: Text(service.nameService, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
      onChanged: services.isEmpty ? null : onChanged,
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _ReadOnlyField({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('$label-$value'),
      initialValue: value,
      readOnly: true,
      decoration: _fieldDecoration(label).copyWith(
        suffixIcon:
            icon == null ? null : Icon(icon, color: const Color(0xFF3C454C)),
      ),
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F252A),
      ),
    );
  }
}

InputDecoration _fieldDecoration(String label) {
  return InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF7D8790)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF7D8790)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.darkBlue, width: 1.4),
    ),
  );
}

class _FormSectionTitle extends StatelessWidget {
  final String title;

  const _FormSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1F252A),
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
      ],
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD2D2)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF9B1C1C),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
