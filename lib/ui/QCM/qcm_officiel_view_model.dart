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

      List<int> ids = await _repo.getAllIdByCoursId(kCoursOfficielDistantId);
      if (kDebugMode) {
        print('🔍 IDs trouvés pour cours $kCoursOfficielDistantId: $ids');
      }
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

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _finishExam() {
    timer?.cancel();
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
}
