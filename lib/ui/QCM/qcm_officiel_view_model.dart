import 'dart:async';
import 'package:factoscope/services/qcm_officiel_service.dart';
import 'package:flutter/foundation.dart';
import 'package:factoscope/models/QCM/qcm.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/repositories/QCM/qcm_controller.dart';
import 'package:factoscope/repositories/QCM/qcm_repository.dart';

class QCMOfficielViewModel extends ChangeNotifier {
  final QCMRepository _repo = QCMRepository();

  QCMController? controller;
  bool isLoading = true;
  bool hasError = false;

  int duration = 300;
  Timer? timer;

  List<int?> userAnswers = [];
  int? selectedIndex;
  bool _isDisposed = false;

  VoidCallback? onSuccess;
  Function(double score)? onFailure;

  String get timerText {
    int min = duration ~/ 60;
    int sec = duration % 60;
    return "$min:${sec.toString().padLeft(2, '0')}";
  }

  Future<void> chargerQCM(Cours cours) async {
    try {
      isLoading = true;
      notifyListeners();

      // Récupérer l'ID du cours officiel mémorisé dynamiquement
      final coursOfficielId =
          await QCMOfficielService().getCoursOfficielIdLocal();
      if (kDebugMode) {
        print('🔍 Chargement QCM officiel pour cours id=$coursOfficielId');
      }

      List<int> ids = coursOfficielId != -1
          ? await _repo.getAllIdByCoursId(coursOfficielId)
          : [];
      if (kDebugMode) print('🔍 IDs trouvés: $ids');
      List<QCM> qcms = [];

      for (int id in ids) {
        QCM? q = await _repo.getById(id);
        if (q != null) qcms.add(q);
      }

      controller = QCMController(qcms);
      controller!.start();

      userAnswers = List.filled(qcms.length, null);
      selectedIndex = null;

      _startTimer();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      hasError = true;
      isLoading = false;
      notifyListeners();
    }
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_isDisposed) {
        t.cancel();
        return;
      }
      duration--;
      notifyListeners();

      if (duration <= 0) {
        t.cancel();
        _finishExam();
      }
    });
  }

  String get questionText => controller!.currentQuestion.question;
  List<String> get options => controller!.currentQuestion.getReponses();
  int get currentIndex => controller!.currentIndex;
  int get totalQuestions => controller!.qcmList.length;

  void selectAnswer(int index) {
    selectedIndex = index;
    userAnswers[currentIndex] = index;
    controller!.selectAnswer(index);
    notifyListeners();
  }

  void next() {
    if (currentIndex < totalQuestions - 1) {
      controller!.next();
      selectedIndex = userAnswers[currentIndex];
      if (selectedIndex != null) controller!.selectAnswer(selectedIndex!);
      notifyListeners();
    } else {
      _finishExam();
    }
  }

  void previous() {
    if (currentIndex > 0) {
      controller!.previous();
      selectedIndex = userAnswers[currentIndex];
      if (selectedIndex != null) controller!.selectAnswer(selectedIndex!);
      notifyListeners();
    }
  }

  void _finishExam() {
    int correct = 0;

    for (int i = 0; i < totalQuestions; i++) {
      final q = controller!.qcmList[i];
      final userAnswer = userAnswers[i];

      if (userAnswer != null && userAnswer == q.soluce) {
        correct++;
      }
    }

    double score = correct / totalQuestions;

    if (score == 1.0) {
      onSuccess?.call();
    } else {
      onFailure?.call(score);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    timer?.cancel();
    super.dispose();
  }
}
