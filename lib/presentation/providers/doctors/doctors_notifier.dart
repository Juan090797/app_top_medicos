import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_top_medicos/domain/repositories/doctor_repository.dart';
import 'doctors_state.dart';

class DoctorsNotifier extends StateNotifier<DoctorsState> {

  final DoctorRepository repository;

  int currentPage = 0;

  DoctorsNotifier(this.repository) : super(DoctorsState()) {
    loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    final newDoctors =
        await repository.getTopDoctors(page: currentPage);

    state = state.copyWith(
      doctors: [...state.doctors, ...newDoctors],
      isLoading: false,
      hasMore: newDoctors.isNotEmpty,
    );

    currentPage++;
  }
}
