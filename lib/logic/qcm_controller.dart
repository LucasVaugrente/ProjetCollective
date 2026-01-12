import '../../models/QCM/qcm.dart';

class QCMController {
  final List<QCM> qcmList;
  int currentIndex = 0;
  List<int?> selectedAnswers;

  QCMController(this.qcmList)
      : selectedAnswers = List.filled(qcmList.length, null);

  void selectAnswer(int index) {
    selectedAnswers[currentIndex] = index;
  }

  bool canGoNext() => selectedAnswers[currentIndex] != null;
  bool canGoPrevious() => currentIndex > 0;

  void next() {
    if (canGoNext() && currentIndex < qcmList.length - 1) currentIndex++;
  }

  void previous() {
    if (canGoPrevious()) currentIndex--;
  }

  int getScore() {
    int score = 0;
    for (int i = 0; i < qcmList.length; i++) {
      if (selectedAnswers[i] == qcmList[i].numSolution) score++;
    }
    return score;
  }
}
