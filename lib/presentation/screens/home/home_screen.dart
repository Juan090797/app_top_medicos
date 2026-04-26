import 'package:app_top_medicos/presentation/providers/auth/auth_provider.dart';
import 'package:app_top_medicos/domain/entities/doctor.dart';
import 'package:app_top_medicos/presentation/providers/doctors/doctors_provider.dart';
import 'package:app_top_medicos/presentation/providers/specialties/specialty_provider.dart';
import 'package:app_top_medicos/presentation/widgets/shared/initials_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  static const String name = 'home_screen';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeScaffold();
  }
}

class _HomeScaffold extends StatefulWidget {
  const _HomeScaffold();

  @override
  State<_HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<_HomeScaffold> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _HomeView(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/');
          if (i == 1) context.go('/appointments');
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

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _Header(),
          SizedBox(height: 14),
          _BannerCard(),
          SizedBox(height: 18),
          _SectionEspecialidades(),
          SizedBox(height: 18),
          _SectionTopMedicos(),
          SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  bool _hasValidImage(String? url) {
    final imageUrl = (url ?? '').trim();
    return imageUrl.isNotEmpty &&
        !imageUrl.endsWith('/null') &&
        !imageUrl.contains('/static/null');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final displayName =
        (user?.username.trim().isNotEmpty ?? false)
            ? user!.username.trim()
            : 'Paciente';
    final top = MediaQuery.paddingOf(context).top;

    final hasImage = _hasValidImage(user?.urlImagenUser);

    return Container(
      padding: EdgeInsets.fromLTRB(18, top + 16, 18, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E2E3F), Color(0xFF153F56)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              hasImage
                  ? CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF9DC4FF),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(user!.urlImagenUser),
                    ),
                  )
                  : InitialsAvatar(fullName: displayName, radius: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buenos días,',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              _GoRoundIconButton(
                icon: Icons.favorite_border,
                onTap: () => context.push('/favorites'),
              ),
              SizedBox(width: 10),
              _RoundIconButton(icon: Icons.notifications_none),
            ],
          ),
          const SizedBox(height: 16),
          const _SearchBox(),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;

  const _RoundIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push('/search'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: const Row(
            children: [
              Icon(Icons.search, color: Color(0xFF93A0A8)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Buscar especialidad, doctor, ...',
                  style: TextStyle(
                    color: Color(0xFF93A0A8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 160,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4E86FF), Color(0xFF2E5BFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Positioned.fill(
              //   child: Opacity(
              //     opacity: 0.20,
              //     child: Image.network(
              //       'https://images.unsplash.com/photo-1580281657527-47f249e8f92b?auto=format&fit=crop&w=1200&q=60',
              //       fit: BoxFit.cover,
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Medical Checks!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Check your health condition regularly\nto minimize the incidence of disease in\nthe future.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 12),
                          _BannerButton(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?auto=format&fit=crop&w=500&q=60',
                        width: 110,
                        height: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerButton extends StatelessWidget {
  const _BannerButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF2E5BFF),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
        child: const Text('Check Now'),
      ),
    );
  }
}

class _SectionEspecialidades extends ConsumerWidget {
  const _SectionEspecialidades();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final specialtiesAsync = ref.watch(specialtiesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'Especialidades', actionText: '', onTap: () {}),
          const SizedBox(height: 12),

          specialtiesAsync.when(
            data: (specialties) {
              if (specialties.isEmpty) {
                return const Text('No hay especialidades');
              }

              return SizedBox(
                height: 92,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: specialties.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder:
                      (_, i) => _SpecialtyItem(label: specialties[i].name),
                ),
              );
            },
            loading:
                () => const SizedBox(
                  height: 92,
                  child: Center(child: CircularProgressIndicator()),
                ),
            error: (e, _) => Text('Error cargando especialidades: $e'),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyItem extends StatelessWidget {
  final String label;
  const _SpecialtyItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF0E2E3F),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.groups_2_outlined, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            label.length > 9 ? '${label.substring(0, 7)}..' : label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTopMedicos extends ConsumerWidget {
  const _SectionTopMedicos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(doctorsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'Top médicos',
            actionText: 'Ver todos',
            onTap: () => context.push('/doctors'),
          ),
          const SizedBox(height: 12),

          if (state.doctors.isEmpty && state.isLoading)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.doctors.isEmpty)
            const Text('No hay médicos')
          else
            Column(
              children: [
                ...state.doctors.map(
                  (doctor) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DoctorCard(doctor: doctor),
                  ),
                ),

                // loader al final cuando está cargando más páginas
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const _DoctorCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/doctor-detail/${Uri.encodeComponent(doctor.fullName)}');
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundImage:
                      doctor.urlImagen.isNotEmpty
                          ? NetworkImage(doctor.urlImagen)
                          : null,
                  backgroundColor:
                      doctor.urlImagen.isEmpty
                          ? InitialsAvatar.getColor(doctor.fullName)
                          : null,
                  child:
                      doctor.urlImagen.isEmpty
                          ? Text(
                            InitialsAvatar.getInitials(doctor.fullName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 19,
                            ),
                          )
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor.specialtyNames.join(', '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF0E2E3F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor.email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7A8A95),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _RatingPill(rating: doctor.rating.toString()),
              ],
            ),
            const SizedBox(height: 14),
            // botones igual...
          ],
        ),
      ),
    );
  }
}

class _RatingPill extends StatelessWidget {
  final String rating;
  const _RatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, size: 16, color: Color(0xFFB7791F)),
          const SizedBox(width: 6),
          Text(
            rating,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFFB7791F),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0E2E3F),
            ),
          ),
        ),
      ],
    );
  }
}

class _GoRoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GoRoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
