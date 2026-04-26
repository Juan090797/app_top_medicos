import 'package:app_top_medicos/domain/entities/medical_search_suggestion.dart';
import 'package:app_top_medicos/domain/repositories/medical_search_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'medical_search_state.dart';

class MedicalSearchNotifier extends StateNotifier<MedicalSearchState> {
  final MedicalSearchRepository repository;
  final String? token;

  int _requestSerial = 0;

  MedicalSearchNotifier({required this.repository, required this.token})
    : super(const MedicalSearchState());

  Future<void> searchSuggestions(String value) async {
    final query = value.trim();
    final requestId = ++_requestSerial;

    if (query.isEmpty) {
      state = const MedicalSearchState();
      return;
    }

    if (!_hasToken) {
      state = state.copyWith(
        query: query,
        isLoadingSuggestions: false,
        suggestions: const [],
        doctors: const [],
        errorMessage: 'Inicia sesión nuevamente para buscar.',
      );
      return;
    }

    state = state.copyWith(
      query: query,
      isLoadingSuggestions: true,
      suggestions: const [],
      doctors: const [],
      selectedSuggestion: null,
      errorMessage: null,
    );

    try {
      final suggestions = await repository.searchSuggestions(
        keyword: query,
        token: token!,
      );

      if (!mounted || requestId != _requestSerial) return;

      state = state.copyWith(
        isLoadingSuggestions: false,
        suggestions: suggestions,
      );
    } catch (e) {
      if (!mounted || requestId != _requestSerial) return;

      state = state.copyWith(
        isLoadingSuggestions: false,
        suggestions: const [],
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> selectSuggestion(MedicalSearchSuggestion suggestion) async {
    final requestId = ++_requestSerial;

    if (!_hasToken) {
      state = state.copyWith(
        isLoadingDoctors: false,
        errorMessage: 'Inicia sesión nuevamente para buscar.',
      );
      return;
    }

    state = state.copyWith(
      query: suggestion.title,
      selectedSuggestion: suggestion,
      isLoadingSuggestions: false,
      isLoadingDoctors: true,
      suggestions: const [],
      doctors: const [],
      errorMessage: null,
    );

    try {
      final doctors = await repository.searchDoctors(
        keyword: suggestion.title,
        token: token!,
      );

      if (!mounted || requestId != _requestSerial) return;

      state = state.copyWith(isLoadingDoctors: false, doctors: doctors);
    } catch (e) {
      if (!mounted || requestId != _requestSerial) return;

      state = state.copyWith(
        isLoadingDoctors: false,
        doctors: const [],
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> searchDoctorsByKeyword(String value) async {
    final query = value.trim();
    final requestId = ++_requestSerial;

    if (query.isEmpty) return;

    if (!_hasToken) {
      state = state.copyWith(
        query: query,
        isLoadingDoctors: false,
        errorMessage: 'Inicia sesión nuevamente para buscar.',
      );
      return;
    }

    state = state.copyWith(
      query: query,
      selectedSuggestion: null,
      isLoadingSuggestions: false,
      isLoadingDoctors: true,
      suggestions: const [],
      doctors: const [],
      errorMessage: null,
    );

    try {
      final doctors = await repository.searchDoctors(
        keyword: query,
        token: token!,
      );

      if (!mounted || requestId != _requestSerial) return;

      state = state.copyWith(isLoadingDoctors: false, doctors: doctors);
    } catch (e) {
      if (!mounted || requestId != _requestSerial) return;

      state = state.copyWith(
        isLoadingDoctors: false,
        doctors: const [],
        errorMessage: e.toString(),
      );
    }
  }

  void clear() {
    _requestSerial++;
    state = const MedicalSearchState();
  }

  bool get _hasToken => token != null && token!.trim().isNotEmpty;
}
