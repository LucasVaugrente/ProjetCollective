class ClozeQuestion {
  final int? id;
  final String phrase;
  final int idCours;

  ClozeQuestion({this.id, required this.phrase, required this.idCours});

  factory ClozeQuestion.fromMap(Map<String, dynamic> map) {
    return ClozeQuestion(
      id: map['idCloze'],
      phrase: map['phrase'],
      idCours: map['idCours'],
    );
  }
}