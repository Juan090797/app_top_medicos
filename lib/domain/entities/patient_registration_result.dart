class PatientRegistrationResult {
  final int id;
  final String name;
  final String lastName;
  final bool dataConsent;
  final bool receiveNotifications;

  const PatientRegistrationResult({
    required this.id,
    required this.name,
    required this.lastName,
    required this.dataConsent,
    required this.receiveNotifications,
  });
}
