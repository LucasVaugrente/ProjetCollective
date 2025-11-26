class MiniJeu {
   int? id;
   int idCours;
   String nom;
   String? description;
   int progression;

  MiniJeu({
    this.id,
    required this.idCours,
    required this.nom,
    this.description,
    required this.progression,
  });

  // Conversion en Map pour SQLite (sans les mots croisés)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_cours': idCours,
      'nom': nom,
      'description': description,
      'progression': progression,
    };
  }

  // Conversion d'une Map SQLite en objet (sans les mots croisés)
  factory MiniJeu.fromMap(Map<String, dynamic> map) {
    return MiniJeu(
      id: map['id'],
      idCours: map['id_cours'],
      nom: map['nom'],
      description: map['description'],
      progression: map['progression'],
    );
  }


}
