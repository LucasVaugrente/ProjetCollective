class ClozeQuestion {
  final int? id;
  final String phrase;
  final String rep1;
  final String rep2;
  final String rep3;
  final String rep4;
  final int soluce;
  final int idCours;

  ClozeQuestion({this.id, required this.phrase, required this.rep1, required this.rep2, required this.rep3, required this.rep4, required this.soluce, required this.idCours});

  factory ClozeQuestion.fromMap(Map<String, dynamic> map) {
    return ClozeQuestion(
      id: map['idCloze'],
      phrase: map['phrase'],
      rep1: map['rep1'],
      rep2: map['rep2'],
      rep3: map['rep3'],
      rep4: map['rep4'],
      soluce: map['soluce'],
      idCours: map['idCours'],
    );
  }
}