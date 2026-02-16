import 'package:flutter/foundation.dart';
import 'package:factoscope/models/QCM/qcm.dart';
import 'package:factoscope/models/cours.dart';

import 'package:factoscope/repositories/QCM/QCMRepository.dart';
import 'package:factoscope/repositories/QCM/qcm_controller.dart';

class JeuQCMViewModel extends ChangeNotifier {
  final QCMRepository _repo = QCMRepository();

  QCMController? controller;
  bool isLoading = true;
  bool hasError = false;

  Future<void> chargerQCM(Cours cours) async {
    try {
      isLoading = true;
      notifyListeners();

      List<int> ids = await _repo.getAllIdByCoursId(cours.id!);
      List<QCM> qcms = [];

      for (int id in ids) {
        QCM? q = await _repo.getById(id);
        if (q != null) qcms.add(q);
      }

      if (qcms.isEmpty) {
        throw Exception("Aucun QCM trouvé");
      }

      controller = QCMController(qcms);
      controller!.start();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      hasError = true;
      isLoading = false;
      notifyListeners();
    }
  }

  // --- Exposition des données à la vue ---
  String get questionText => controller!.currentQuestion.question;

  List<String> get options => controller!.currentQuestion.reponses;

  int? get selectedAnswer => controller!.selectedAnswer;
  int get currentIndex => controller!.currentIndex;
  int get totalQuestions => controller!.qcmList.length;
  bool get isFinished => controller!.state == QCMState.finished;

  bool? get isCorrect => controller!.isCorrect;

  // --- Actions utilisateur ---
  void selectAnswer(int index) {
    controller!.selectAnswer(index);
    notifyListeners();
  }

  void next() {
    controller!.next();
    notifyListeners();
  }

  void previous() {
    controller!.previous();
    notifyListeners();
  }

  int getScore() => controller!.getScore();

  void restart() {
    controller!.restart();
    notifyListeners();
  }
}
