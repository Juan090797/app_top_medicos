import 'package:app_top_medicos/domain/entities/doctor.dart';

class DoctorsState {
  final List<Doctor> doctors;
  final bool isLoading;
  final bool hasMore;

  DoctorsState({
    this.doctors = const [],
    this.isLoading = false,
    this.hasMore = true,
  });

  DoctorsState copyWith({
    List<Doctor>? doctors,
    bool? isLoading,
    bool? hasMore,
  }) {
    return DoctorsState(
      doctors: doctors ?? this.doctors,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
