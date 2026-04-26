import 'package:app_top_medicos/domain/entities/doctor.dart';
import 'package:app_top_medicos/domain/entities/medical_search_suggestion.dart';

class MedicalSearchState {
  final String query;
  final bool isLoadingSuggestions;
  final bool isLoadingDoctors;
  final List<MedicalSearchSuggestion> suggestions;
  final List<Doctor> doctors;
  final MedicalSearchSuggestion? selectedSuggestion;
  final String? errorMessage;

  const MedicalSearchState({
    this.query = '',
    this.isLoadingSuggestions = false,
    this.isLoadingDoctors = false,
    this.suggestions = const [],
    this.doctors = const [],
    this.selectedSuggestion,
    this.errorMessage,
  });

  MedicalSearchState copyWith({
    String? query,
    bool? isLoadingSuggestions,
    bool? isLoadingDoctors,
    List<MedicalSearchSuggestion>? suggestions,
    List<Doctor>? doctors,
    Object? selectedSuggestion = _unset,
    Object? errorMessage = _unset,
  }) {
    return MedicalSearchState(
      query: query ?? this.query,
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      isLoadingDoctors: isLoadingDoctors ?? this.isLoadingDoctors,
      suggestions: suggestions ?? this.suggestions,
      doctors: doctors ?? this.doctors,
      selectedSuggestion:
          identical(selectedSuggestion, _unset)
              ? this.selectedSuggestion
              : selectedSuggestion as MedicalSearchSuggestion?,
      errorMessage:
          identical(errorMessage, _unset)
              ? this.errorMessage
              : errorMessage as String?,
    );
  }
}

const _unset = Object();
