
import 'question.dart';
import 'reponse.dart';

/// Modèle représentant un QCM (Questionnaire à Choix Multiples).
class QCM {
  final int id;
  final int numSolution;
  final int idCours;
  final int idQuestion;
  Question? question;
  List<Reponse>? reponses;

  QCM({
    required this.id,
    required this.numSolution,
    required this.idCours,
    required this.idQuestion,
    this.question,
    this.reponses,
  });

  /// Crée une instance de QCM à partir d'une map.
  factory QCM.fromMap(Map<String, dynamic> map) {
    return QCM(
      id: map['idQCM'],
      numSolution: map['numSolution'],
      idCours: map['idCours'],
      idQuestion: map['idQuestion'],
    );
  }

  /// Convertit l'objet QCM en map pour la base de données.
  Map<String, dynamic> toMap() {
    return {
      'idQCM': id,
      'numSolution': numSolution,
      'idCours': idCours,
      'idQuestion': idQuestion,
    };
  }
}