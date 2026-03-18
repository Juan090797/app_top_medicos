class DoctorDoctorDB {
  String fullName;
  double rating;
  int totalComments;
  int totalRating;
  List<String> phoneNumber;
  String email;
  String address;
  String doctorTitle;
  String urlImagen;
  List<String> specialtyNames;

  DoctorDoctorDB({
    required this.fullName,
    required this.rating,
    required this.totalComments,
    required this.totalRating,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.doctorTitle,
    required this.urlImagen,
    required this.specialtyNames,
  });

  factory DoctorDoctorDB.fromJson(Map<String, dynamic> json) => DoctorDoctorDB(
      fullName: json['fullName'],
      rating: json['rating'].toDouble(),
      totalComments: json['totalComments'],
      totalRating: json['totalRating'],
      phoneNumber: List<String>.from(json['phoneNumber']),
      email: json['email'],
      address: json['address'],
      doctorTitle: json['doctorTitle'],
      urlImagen: json['urlImagen'],
      specialtyNames: List<String>.from(json['specialtyNames']),
    );

  Map<String, dynamic> toJson() => {
      'fullName': fullName,
      'rating': rating,
      'totalComments': totalComments,
      'totalRating': totalRating,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'doctorTitle': doctorTitle,
      'urlImagen': urlImagen,
      'specialtyNames': specialtyNames,
    };

}
