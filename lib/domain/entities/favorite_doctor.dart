class FavoriteDoctor {
  final int id;
  final String doctorTitle;
  final String fullName;
  final String urlImagen;
  final double rating;
  final int reviewCount;
  final List<String> specialtyNames;
  final String? address;
  final bool hasOnline;
  final String cmp;

  FavoriteDoctor({
    required this.id,
    required this.doctorTitle,
    required this.fullName,
    required this.urlImagen,
    required this.rating,
    required this.reviewCount,
    required this.specialtyNames,
    this.address,
    this.hasOnline = false,
    required this.cmp,
  });

  String get displayName => '$doctorTitle $fullName';

  String get specialtiesText => specialtyNames.join(', ');
}
