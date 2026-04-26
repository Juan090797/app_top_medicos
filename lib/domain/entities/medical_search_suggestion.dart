enum MedicalSearchSuggestionType { specialty, treatment, doctor }

class MedicalSearchSuggestion {
  final int id;
  final String title;
  final String imageUrl;
  final MedicalSearchSuggestionType type;

  const MedicalSearchSuggestion({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.type,
  });

  String get typeLabel {
    switch (type) {
      case MedicalSearchSuggestionType.specialty:
        return 'Especialidad';
      case MedicalSearchSuggestionType.treatment:
        return 'Tratamiento';
      case MedicalSearchSuggestionType.doctor:
        return 'Doctor';
    }
  }
}
