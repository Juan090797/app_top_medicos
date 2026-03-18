import 'package:app_top_medicos/domain/entities/doctor.dart';
import 'package:app_top_medicos/infrastructure/models/doctordb/doctor_doctordb.dart';

class DoctorMapper {
  static Doctor doctordbToEntity(DoctorDoctorDB doctorDoctorDB) => Doctor(
      fullName: doctorDoctorDB.fullName,
      rating: doctorDoctorDB.rating,
      totalComments: doctorDoctorDB.totalComments,
      totalRating: doctorDoctorDB.totalRating,
      phoneNumber: doctorDoctorDB.phoneNumber,
      email: doctorDoctorDB.email,
      address: doctorDoctorDB.address,
      doctorTitle: doctorDoctorDB.doctorTitle,
      urlImagen: doctorDoctorDB.urlImagen,
      specialtyNames: doctorDoctorDB.specialtyNames
    );
}