class DoctorDetail {
  final int id;
  final String name;
  final String lastName;
  final String professionalTitle;
  final String aboutMe;
  final String urlImage;
  final List<String> specialties; // solo nombres
  final double rating;
  final int reviewCount;
  final String cmp;

  const DoctorDetail({
    required this.id,
    required this.name,
    required this.lastName,
    required this.professionalTitle,
    required this.aboutMe,
    required this.urlImage,
    required this.specialties,
    required this.rating,
    required this.reviewCount,
    required this.cmp,
  });

  String get fullName => '$professionalTitle $name $lastName';
}
