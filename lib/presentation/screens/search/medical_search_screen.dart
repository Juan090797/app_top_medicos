import 'dart:async';

import 'package:app_top_medicos/domain/entities/doctor.dart';
import 'package:app_top_medicos/domain/entities/medical_search_suggestion.dart';
import 'package:app_top_medicos/presentation/providers/search/medical_search_provider.dart';
import 'package:app_top_medicos/presentation/widgets/shared/initials_avatar.dart';
import 'package:app_top_medicos/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MedicalSearchScreen extends ConsumerStatefulWidget {
  static const String name = 'medical_search_screen';

  const MedicalSearchScreen({super.key});

  @override
  ConsumerState<MedicalSearchScreen> createState() =>
      _MedicalSearchScreenState();
}

class _MedicalSearchScreenState extends ConsumerState<MedicalSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<MedicalSearchSuggestion> _recentSearches = [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      ref.read(medicalSearchProvider.notifier).clear();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(medicalSearchProvider.notifier).searchSuggestions(value);
    });
  }

  void _selectSuggestion(MedicalSearchSuggestion suggestion) {
    _debounce?.cancel();
    _rememberSuggestion(suggestion);
    _controller.text = suggestion.title;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    ref.read(medicalSearchProvider.notifier).selectSuggestion(suggestion);
  }

  void _searchSubmitted(String value) {
    _debounce?.cancel();
    ref.read(medicalSearchProvider.notifier).searchDoctorsByKeyword(value);
  }

  void _clearSearch() {
    _debounce?.cancel();
    _controller.clear();
    ref.read(medicalSearchProvider.notifier).clear();
  }

  void _rememberSuggestion(MedicalSearchSuggestion suggestion) {
    setState(() {
      _recentSearches.removeWhere(
        (item) =>
            item.type == suggestion.type &&
            item.title.toLowerCase() == suggestion.title.toLowerCase(),
      );
      _recentSearches.insert(0, suggestion);
      if (_recentSearches.length > 8) {
        _recentSearches.removeRange(8, _recentSearches.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicalSearchProvider);
    final topPadding = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, topPadding + 14, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.darkBlue, Color(0xFF153F56)],
              ),
            ),
            child: _TopSearchBar(
              controller: _controller,
              isLoading: state.isLoadingSuggestions || state.isLoadingDoctors,
              onChanged: _onQueryChanged,
              onSubmitted: _searchSubmitted,
              onClear: _clearSearch,
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: SafeArea(
              top: false,
              child: _SearchContent(
                recentSearches: _recentSearches,
                onSuggestionTap: _selectSuggestion,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _TopSearchBar({
    required this.controller,
    required this.isLoading,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
            icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
            tooltip: 'Volver',
          ),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              cursorColor: AppColors.darkBlue,
              style: const TextStyle(
                color: Color(0xFF102027),
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                hintText: 'Buscar especialidad, doctor...',
                hintStyle: TextStyle(
                  color: Color(0xFF7A8A95),
                  fontWeight: FontWeight.w600,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 18),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: AppColors.darkBlue,
                ),
              ),
            )
          else
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (_, value, __) {
                if (value.text.isEmpty) return const SizedBox(width: 12);

                return IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close, color: Color(0xFF7A8A95)),
                  tooltip: 'Limpiar',
                );
              },
            ),
        ],
      ),
    );
  }
}

class _SearchContent extends ConsumerWidget {
  final List<MedicalSearchSuggestion> recentSearches;
  final ValueChanged<MedicalSearchSuggestion> onSuggestionTap;

  const _SearchContent({
    required this.recentSearches,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(medicalSearchProvider);

    if (state.query.isEmpty) {
      return _RecentSearches(
        recentSearches: recentSearches,
        onSuggestionTap: onSuggestionTap,
      );
    }

    if (state.errorMessage != null) {
      return _SearchMessage(
        icon: Icons.info_outline,
        title: 'No pudimos completar la búsqueda',
        subtitle: state.errorMessage!,
      );
    }

    if (state.isLoadingDoctors) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.darkBlue),
      );
    }

    if (state.selectedSuggestion != null || state.doctors.isNotEmpty) {
      if (state.doctors.isEmpty) {
        return const _SearchMessage(
          icon: Icons.person_search_outlined,
          title: 'Sin médicos disponibles',
          subtitle: 'Prueba con otro término de búsqueda.',
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: state.doctors.length + 1,
        separatorBuilder: (_, index) {
          if (index == 0) return const SizedBox(height: 12);
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          if (index == 0) {
            return _ResultsHeader(
              query: state.query,
              count: state.doctors.length,
            );
          }

          return _DoctorSearchResultCard(doctor: state.doctors[index - 1]);
        },
      );
    }

    if (state.isLoadingSuggestions) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.darkBlue),
      );
    }

    final suggestions = state.suggestions;

    if (suggestions.isEmpty) {
      return const _SearchMessage(
        icon: Icons.search_off,
        title: 'Sin resultados',
        subtitle: 'Prueba con otra especialidad, doctor o tratamiento.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: suggestions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return _SuggestionTile(
          suggestion: suggestion,
          onTap: () => onSuggestionTap(suggestion),
        );
      },
    );
  }
}

class _RecentSearches extends StatelessWidget {
  final List<MedicalSearchSuggestion> recentSearches;
  final ValueChanged<MedicalSearchSuggestion> onSuggestionTap;

  const _RecentSearches({
    required this.recentSearches,
    required this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const Text(
          'Búsquedas recientes',
          style: TextStyle(
            color: AppColors.darkBlue,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        if (recentSearches.isEmpty)
          const _SearchMessage(
            icon: Icons.manage_search,
            title: 'Busca tu atención médica',
            subtitle: 'Tus búsquedas seleccionadas aparecerán aquí.',
          )
        else
          Wrap(
            spacing: 18,
            runSpacing: 18,
            children:
                recentSearches
                    .map(
                      (suggestion) => _RecentSearchItem(
                        suggestion: suggestion,
                        onTap: () => onSuggestionTap(suggestion),
                      ),
                    )
                    .toList(),
          ),
      ],
    );
  }
}

class _RecentSearchItem extends StatelessWidget {
  final MedicalSearchSuggestion suggestion;
  final VoidCallback onTap;

  const _RecentSearchItem({required this.suggestion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            _SuggestionAvatar(suggestion: suggestion, size: 68),
            const SizedBox(height: 8),
            Text(
              suggestion.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF71818C),
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  final String query;
  final int count;

  const _ResultsHeader({required this.query, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Resultados para "$query"',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBlue,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0F5),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBlue,
            ),
          ),
        ),
      ],
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  final MedicalSearchSuggestion suggestion;
  final VoidCallback onTap;

  const _SuggestionTile({required this.suggestion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _SuggestionAvatar(suggestion: suggestion, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      suggestion.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF102027),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      suggestion.typeLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF71818C),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF93A0A8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorSearchResultCard extends StatelessWidget {
  final Doctor doctor;

  const _DoctorSearchResultCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final displayName =
        '${doctor.doctorTitle} ${doctor.fullName}'.replaceAll('  ', ' ').trim();
    final specialtyText =
        doctor.specialtyNames.isEmpty
            ? 'Especialidad no disponible'
            : doctor.specialtyNames.join(', ');
    final addressText =
        doctor.address.isEmpty
            ? 'Consulta online o presencial'
            : doctor.address;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => _openDoctorDetail(context),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                children: [
                  _DoctorAvatar(doctor: doctor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF102027),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          specialtyText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.darkBlue,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  _SearchRatingPill(rating: doctor.rating.toStringAsFixed(1)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 18,
                    color: Color(0xFF71818C),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      addressText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF71818C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openDoctorDetail(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ver perfil',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDoctorDetail(BuildContext context) {
    context.push('/doctor-detail/${Uri.encodeComponent(doctor.fullName)}');
  }
}

class _DoctorAvatar extends StatelessWidget {
  final Doctor doctor;

  const _DoctorAvatar({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundImage:
          doctor.urlImagen.isNotEmpty ? NetworkImage(doctor.urlImagen) : null,
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
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              )
              : null,
    );
  }
}

class _SuggestionAvatar extends StatelessWidget {
  final MedicalSearchSuggestion suggestion;
  final double size;

  const _SuggestionAvatar({required this.suggestion, required this.size});

  @override
  Widget build(BuildContext context) {
    final fallbackIcon = switch (suggestion.type) {
      MedicalSearchSuggestionType.specialty => Icons.medical_services_outlined,
      MedicalSearchSuggestionType.treatment => Icons.healing_outlined,
      MedicalSearchSuggestionType.doctor => Icons.person_outline,
    };

    if (suggestion.imageUrl.isEmpty) {
      return _FallbackSuggestionAvatar(icon: fallbackIcon, size: size);
    }

    return ClipOval(
      child: Image.network(
        suggestion.imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return _FallbackSuggestionAvatar(icon: fallbackIcon, size: size);
        },
      ),
    );
  }
}

class _FallbackSuggestionAvatar extends StatelessWidget {
  final IconData icon;
  final double size;

  const _FallbackSuggestionAvatar({required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE8F0F5),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.darkBlue),
    );
  }
}

class _SearchRatingPill extends StatelessWidget {
  final String rating;

  const _SearchRatingPill({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 15, color: Color(0xFFFFC857)),
          const SizedBox(width: 5),
          Text(
            rating,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFFFFC857),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SearchMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F0F5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 31, color: AppColors.darkBlue),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: Color(0xFF71818C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
