import 'package:seriouse_game/models/objectifCours.dart';
import 'package:seriouse_game/models/page.dart';

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
    this.pages,
    this.objectifs,
  });

  // Convertir un Cours en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_module': idModule, // ✅ cohérence avec fromMap
      'titre': titre,
      'contenu': contenu,
    };
  }

  // Construire un Cours depuis un Map (SQLite)
  factory Cours.fromMap(Map<String, dynamic> map) {
    return Cours(
      id: map['id'],
      idModule: map['id_module'], // ✅ même clé que dans toMap
      titre: map['titre'],
      contenu: map['contenu'],
    );
  }
}
