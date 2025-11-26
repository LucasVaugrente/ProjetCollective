import 'package:factoscope/models/media_cours.dart';

class Page {
  int? id;
  int ordre;
  int idCours;
  String urlAudio;
  int estVue;
  String? description ;
  List<MediaCours>? medias;

  Page({
    this.id,
    required this.ordre,
    this.urlAudio = "",
    this.estVue=0,
    required this.idCours,
     this.description ,
  });

  // Convertir un objet Page en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ordre': ordre,
      'id_cours': idCours,
      'description':description,
      'est_vue':estVue,
      'urlAudio':urlAudio,
    };
  }

  // Créer un objet Page à partir d'une Map SQLite
  factory Page.fromMap(Map<String, dynamic> map) {
    return Page(
      id: map['id'],
      ordre: map['ordre'],
      idCours: map['id_cours'],
      description: map['description'],
      estVue: map['est_vue'],
      urlAudio: map['urlAudio']
    );
  }
}