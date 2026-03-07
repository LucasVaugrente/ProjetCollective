class QCM {
  int? id;
  String question;
  String rep1;
  String rep2;
  String rep3;
  String rep4;
  int soluce;
  int idCours;

  QCM({
    this.id,
    required this.question,
    required this.rep1,
    required this.rep2,
    required this.rep3,
    required this.rep4,
    required this.soluce,
    required this.idCours,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'rep1': rep1,
      'rep2': rep2,
      'rep3': rep3,
      'rep4': rep4,
      'soluce': soluce,
      'id_cours': idCours,
    };
  }

  factory QCM.fromMap(Map<String, dynamic> map) {
    return QCM(
      id: map['id'],
      question: map['question'],
      rep1: map['rep1'],
      rep2: map['rep2'],
      rep3: map['rep3'],
      rep4: map['rep4'],
      soluce: map['soluce'],
      idCours: map['id_cours'],
    );
  }

  // Helper pour obtenir les réponses sous forme de liste
  List<String> getReponses() {
    return [rep1, rep2, rep3, rep4];
  }
}
