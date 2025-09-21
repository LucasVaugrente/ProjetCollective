import 'package:seriouse_game/models/mot.dart';
class MotsCroises {
   int? id;
   int idMiniJeu;
   String tailleGrille;
   String? description;
   List<Mot>? mots; // Liste des mots associés

  MotsCroises({
    this.id,
    required this.idMiniJeu,
    required this.tailleGrille,
    this.description,
  });

  // Conversion en Map pour SQLite (sans les mots, car ils sont dans une table séparée)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_minijeu': idMiniJeu,
      'taille_grille': tailleGrille,
      'description': description,
    };
  }

  // Conversion d'une Map SQLite en objet (sans les mots)
  factory MotsCroises.fromMap(Map<String, dynamic> map) {
    return MotsCroises(
      id: map['id'],
      idMiniJeu: map['id_minijeu'],
      tailleGrille: map['taille_grille'],
      description: map['description'],
    );
  }


}
