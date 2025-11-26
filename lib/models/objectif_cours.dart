class ObjectifCours {
  int? id;
  int idCours;
  String description;

  ObjectifCours({this.id, required this.idCours, required this.description});

  // Convertir en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_cours': idCours,
      'description': description,
    };
  }

  // Conversion Map vers l'objet ObjectifCours
  factory ObjectifCours.fromMap(Map<String, dynamic> map) {
    return ObjectifCours(
      id: map['id'],
      idCours: map['id_cours'],
      description: map['description'],
    );
  }
}
