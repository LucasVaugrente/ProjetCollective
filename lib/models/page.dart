import 'package:factoscope/models/media_cours.dart';

class Page {
  int? id;
  String? description;
  int idCours;
  int estVue;
  List<MediaCours>? medias;

  Page({
    this.id,
    this.description,
    required this.idCours,
    this.estVue = 0,
    this.medias,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'id_cours': idCours,
      'est_vue': estVue,
    };
  }

  factory Page.fromMap(Map<String, dynamic> map) {
    return Page(
      id: map['id'],
      description: map['description'],
      idCours: map['id_cours'],
      estVue: map['est_vue'] ?? 0,
    );
  }

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      id: json['id'],
      description: json['description'],
      idCours: json['id_cours'],
      estVue: json['est_vue'] ?? 0,
      medias: json['medias'] != null
          ? (json['medias'] as List).map((m) => MediaCours.fromJson(m)).toList()
          : null,
    );
  }
}
