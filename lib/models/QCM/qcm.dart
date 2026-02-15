/// Nouveau modèle QCM correspondant à la nouvelle structure SQL.
/// La table contient désormais :
/// question (String)
/// rep1, rep2, rep3, rep4 (String)
/// soluce (int)
/// id_cours (int)

class QCM {
  final int id;
  final String question;
  final List<String> reponses;
  final int soluce;
  final int idCours;

  QCM({
    required this.id,
    required this.question,
    required this.reponses,
    required this.soluce,
    required this.idCours,
  });

  /// Création d'un QCM depuis la base de données
  factory QCM.fromMap(Map<String, dynamic> map) {
    return QCM(
      id: map['id'],
      question: map['question'],
      reponses: [
        map['rep1'],
        map['rep2'],
        map['rep3'],
        map['rep4'],
      ],
      soluce: map['soluce'],
      idCours: map['id_cours'],
    );
  }

  /// Conversion en map pour insertion dans la base
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'rep1': reponses[0],
      'rep2': reponses[1],
      'rep3': reponses[2],
      'rep4': reponses[3],
      'soluce': soluce,
      'id_cours': idCours,
    };
  }
}
