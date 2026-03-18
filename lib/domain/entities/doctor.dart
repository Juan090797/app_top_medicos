
class Doctor {
    final String fullName;
    final double rating;
    final int totalComments;
    final int totalRating;
    final List<String> phoneNumber;
    final String email;
    final String address;
    final String doctorTitle;
    final String urlImagen;
    final List<String> specialtyNames;
    
    Doctor({
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
}
