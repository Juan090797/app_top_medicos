import 'package:app_top_medicos/domain/entities/specialty.dart';

class LocalSpecialtyModel {

  final int id;
  final String name;
  final String urlImagenSp;

  LocalSpecialtyModel({
    required this.id,
    required this.name,
    required this.urlImagenSp
  });

  factory LocalSpecialtyModel.fromJson(Map<String, dynamic> json) => LocalSpecialtyModel(

    id: json['id'],
    name: json['name'],
    urlImagenSp: json['urlImagenSp'] 
  );

  Specialty toSpecialtyEntity() => Specialty(
    id: id,
    name: name,
    urlImagenSp: urlImagenSp
  );
  
}