import 'package:app_top_medicos/presentation/widgets/shared/initials_avatar.dart';
import 'package:app_top_medicos/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppointmentsScreen extends StatefulWidget {
  static const name = 'appointments_screen';

  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int tabIndex = 0; // 0: próximas, 1: pasadas

  @override
  Widget build(BuildContext context) {
    final items = tabIndex == 0 ? _upcoming : _past;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Mis citas',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 14),

          // Tabs Próximas / Pasadas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _Segmented(
              leftText: 'Próximas',
              rightText: 'Pasadas',
              selectedIndex: tabIndex,
              onChanged: (i) => setState(() => tabIndex = i),
            ),
          ),

          const SizedBox(height: 14),

          // Encabezado "PRÓXIMAS CONSULTAS" + "Ver calendario"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  tabIndex == 0 ? 'PRÓXIMAS CONSULTAS' : 'CONSULTAS PASADAS',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: Color(0xFF7A8A95),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: const [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                        color: Color(0xFF355A6B),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Ver calendario',
                        style: TextStyle(
                          color: Color(0xFF355A6B),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Lista
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder:
                  (context, index) => _AppointmentCard(item: items[index]),
            ),
          ),

          const SizedBox(height: 4),

          // Nota abajo
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              tabIndex == 0
                  ? 'Recibirás una notificación 24h antes de tu próxima cita.'
                  : 'Historial de consultas anteriores.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9AA7B0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),

      // Bottom nav (Citas seleccionado)
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/'); // Home
          if (i == 1) return; // Citas (esta)
          if (i == 2) context.go('/profile');
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Citas',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  final String leftText;
  final String rightText;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _Segmented({
    required this.leftText,
    required this.rightText,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDF1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegButton(
              text: leftText,
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _SegButton(
              text: rightText,
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SegButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0E2E3F) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF6B7C87),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final _Appointment item;

  const _AppointmentCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  item.avatarUrl.isNotEmpty
                      ? CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(item.avatarUrl),
                      )
                      : InitialsAvatar(fullName: item.doctorName, radius: 24),
                  if (item.online)
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.specialty,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7C87),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(status: item.status),
            ],
          ),
          const SizedBox(height: 14),

          // Fecha / hora
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: Color(0xFF0E2E3F),
                ),
                const SizedBox(width: 10),
                Text(
                  item.dateLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0E2E3F),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('•', style: TextStyle(color: Color(0xFF94A3B8))),
                const SizedBox(width: 10),
                const Icon(
                  Icons.access_time,
                  size: 18,
                  color: Color(0xFF0E2E3F),
                ),
                const SizedBox(width: 10),
                Text(
                  item.timeLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0E2E3F),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              InkWell(
                onTap: () {},
                child: const Row(
                  children: [
                    Text(
                      'Ver detalles',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0E2E3F),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Color(0xFF0E2E3F),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final isConfirm = status.toLowerCase() == 'confirmada';
    final bg = isConfirm ? const Color(0xFFE8F7EC) : const Color(0xFFFFF4D6);
    final fg = isConfirm ? const Color(0xFF16A34A) : const Color(0xFFB7791F);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(fontWeight: FontWeight.w900, color: fg, fontSize: 12),
      ),
    );
  }
}

class _Appointment {
  final String doctorName;
  final String specialty;
  final String status;
  final String dateLabel;
  final String timeLabel;
  final String avatarUrl;
  final bool online;

  const _Appointment({
    required this.doctorName,
    required this.specialty,
    required this.status,
    required this.dateLabel,
    required this.timeLabel,
    required this.avatarUrl,
    required this.online,
  });
}

const _upcoming = <_Appointment>[
  _Appointment(
    doctorName: 'Dr. Ana López',
    specialty: 'Cardiología',
    status: 'Confirmada',
    dateLabel: '15 Nov, 2023',
    timeLabel: '10:00 AM',
    avatarUrl: 'https://i.pravatar.cc/150?img=47',
    online: true,
  ),
  _Appointment(
    doctorName: 'Dr. Mario Ruiz',
    specialty: 'Dermatología',
    status: 'Pendiente',
    dateLabel: '22 Nov, 2023',
    timeLabel: '3:30 PM',
    avatarUrl: 'https://i.pravatar.cc/150?img=12',
    online: false,
  ),
];

const _past = <_Appointment>[
  _Appointment(
    doctorName: 'Dra. Sofía Martinez',
    specialty: 'Cardiología',
    status: 'Confirmada',
    dateLabel: '02 Oct, 2023',
    timeLabel: '9:00 AM',
    avatarUrl: 'https://i.pravatar.cc/150?img=32',
    online: false,
  ),
];
