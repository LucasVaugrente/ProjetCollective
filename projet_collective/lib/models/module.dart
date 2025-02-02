import 'package:seriouse_game/models/cours.dart';


class Module {
   int? id; // `id` est nullable pour les nouvelles entrées
   String titre;
   String description;
   List<Cours>? cours;
  Module({
    this.id,
    required this.titre,
    required this.description,
  });

  // Convertir un objet en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
    };
  }

  // Convertir une ligne SQLite en objet Module
  static Module fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'],
      titre: map['titre'],
      description: map['description'],
    );
  }

}
