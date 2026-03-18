import 'package:app_top_medicos/domain/entities/favorite_doctor.dart';
import 'package:app_top_medicos/presentation/providers/favorites/favorite_doctors_provider.dart';
import 'package:app_top_medicos/presentation/widgets/shared/initials_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FavoritesScreen extends ConsumerWidget {
  static const name = 'favorites_screen';

  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favState = ref.watch(favoriteDoctorsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E2E3F),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Doctores Favoritos',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          // Search header
          Container(
            color: const Color(0xFF0E2E3F),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.white70),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Buscar por nombre o especialidad',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: _buildBody(context, ref, favState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, dynamic favState) {
    if (favState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (favState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                favState.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(favoriteDoctorsProvider.notifier).loadFavorites(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final doctors = favState.doctors as List<FavoriteDoctor>;

    if (doctors.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: 56, color: Color(0xFF94A3B8)),
              SizedBox(height: 14),
              Text(
                'No tienes doctores favoritos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Agrega doctores a tus favoritos para verlos aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(favoriteDoctorsProvider.notifier).loadFavorites(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final d = doctors[index];
          return _DoctorFavoriteCard(
            doctor: d,
            onViewProfile: () {
              context.push('/doctor-detail/${Uri.encodeComponent(d.fullName)}');
            },
          );
        },
      ),
    );
  }
}

class _DoctorFavoriteCard extends StatelessWidget {
  final FavoriteDoctor doctor;
  final VoidCallback onViewProfile;

  const _DoctorFavoriteCard({
    required this.doctor,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = doctor.urlImagen.trim();
    final hasValidImage = imageUrl.isNotEmpty &&
        !imageUrl.endsWith('/null') &&
        !imageUrl.contains('/static/null');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                  hasValidImage
                      ? CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(imageUrl),
                        )
                      : InitialsAvatar(
                          fullName: doctor.fullName,
                          radius: 26,
                        ),
                  if (doctor.hasOnline)
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
                      doctor.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.specialtiesText,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7C87),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star,
                            size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 6),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF334155),
                          ),
                        ),
                        if (doctor.reviewCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '(${doctor.reviewCount})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (doctor.address != null) ...[
                          const SizedBox(width: 10),
                          const Text('•',
                              style: TextStyle(color: Color(0xFF94A3B8))),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              doctor.address!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.favorite, color: Color(0xFFEF4444), size: 26),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onViewProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF0E2E3F),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  child: const Text('Ver Perfil'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onViewProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E2E3F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  child: const Text('Reservar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
