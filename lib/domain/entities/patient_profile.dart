class PatientProfile {
  final int id;
  final String name;
  final String lastName;
  final String phoneNumber;
  final String gender;
  final String email;

  const PatientProfile({
    required this.id,
    required this.name,
    required this.lastName,
    required this.phoneNumber,
    required this.gender,
    required this.email,
  });

  String get fullName => '${name.trim()} ${lastName.trim()}'.trim();
}