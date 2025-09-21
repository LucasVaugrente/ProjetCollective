class Mot {
  final int? id;
  final int idMotsCroises;
  final String mot;
  final String indice;
  final String direction;
  final int positionDepartX;
  final int positionDepartY;

  Mot({
    this.id,
    required this.idMotsCroises,
    required this.mot,
    required this.indice,
    required this.direction,
    required this.positionDepartX,
    required this.positionDepartY,
  });

  // Conversion en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_motscroises': idMotsCroises,
      'mot': mot,
      'indice': indice,
      'direction': direction,
      'position_depart_x': positionDepartX,
      'position_depart_y': positionDepartY,
    };
  }

  // Conversion d'une Map SQLite en objet
  factory Mot.fromMap(Map<String, dynamic> map) {
    return Mot(
      id: map['id'],
      idMotsCroises: map['id_motscroises'],
      mot: map['mot'],
      indice: map['indice'],
      direction: map['direction'],
      positionDepartX: map['position_depart_x'],
      positionDepartY: map['position_depart_y'],
    );
  }
}
