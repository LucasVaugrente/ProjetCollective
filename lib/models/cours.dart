import 'package:factoscope/models/objectif_cours.dart';
import 'package:factoscope/models/page.dart';

class Cours {
   int? id;
   int idModule;
   String titre;
   String contenu;
   List<Page>? pages;
   List<ObjectifCours>? objectifs;
  Cours({
    this.id,
    required this.idModule,
    required this.titre,
    required this.contenu,
  });

  // Convertir une Cours en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_Module': idModule,
      'titre': titre,
      'contenu': contenu,
    };
  }

  // Construire une Cours depuis un Map (SQLite)
  factory Cours.fromMap(Map<String, dynamic> map) {
    return Cours(
      id: map['id'],
      idModule: map['id_module'],
      titre: map['titre'],
      contenu: map['contenu'],
    );
  }


}
