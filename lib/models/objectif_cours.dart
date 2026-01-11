// lib/models/objectif_cours.dart
class ObjectifCours {
  final int? id;
  final int idCours;
  final String description;

  ObjectifCours({this.id, required this.idCours, required this.description});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_cours': idCours,
      'description': description,
    };
  }

  factory ObjectifCours.fromMap(Map<String, dynamic> map) {
    return ObjectifCours(
      id: map['id'],
      idCours: map['id_cours'],
      description: map['description'],
    );
  }

  factory ObjectifCours.fromJson(Map<String, dynamic> json) {
    return ObjectifCours(
      id: json['id'],
      idCours: json['id_cours'],
      description: json['description'],
    );
  }
}
