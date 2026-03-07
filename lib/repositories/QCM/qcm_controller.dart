import '../../models/QCM/qcm.dart';

enum QCMState { notStarted, inProgress, finished }

class QCMController {
  final List<QCM> qcmList;

  int _currentIndex = 0;
  List<int?> _selectedAnswers = [];
  QCMState _state = QCMState.notStarted;

  bool? isCorrect; // null = pas encore répondu

  QCMController(this.qcmList) {
    _selectedAnswers = List.filled(qcmList.length, null);
  }

  // --- GETTERS ---
  int get currentIndex => _currentIndex;
  QCM get currentQuestion => qcmList[_currentIndex];
  QCMState get state => _state;
  int? get selectedAnswer => _selectedAnswers[_currentIndex];
  bool get isLastQuestion => _currentIndex == qcmList.length - 1;

  // --- ACTIONS ---
  void start() {
    _state = QCMState.inProgress;
    _currentIndex = 0;
    isCorrect = null;
  }

  /// L'utilisateur clique sur une réponse
  void selectAnswer(int index) {
    _selectedAnswers[_currentIndex] = index;

    // Vérifie si c'est correct
    isCorrect = (index == currentQuestion.soluce);
  }

  bool canGoNext() => selectedAnswer != null;
  bool canGoPrevious() => _currentIndex > 0;

  /// Passe à la question suivante
  void next() {
    if (!canGoNext()) return;

    if (isLastQuestion) {
      _state = QCMState.finished;
    } else {
      _currentIndex++;
      isCorrect = null; // reset pour la prochaine question
    }
  }

  void previous() {
    if (canGoPrevious()) {
      _currentIndex--;
      isCorrect = null;
    }
  }

  /// Calcul du score final
  int getScore() {
    int score = 0;
    for (int i = 0; i < qcmList.length; i++) {
      if (_selectedAnswers[i] == qcmList[i].soluce) {
        score++;
      }
    }
    return score;
  }

  /// Redémarre le QCM
  void restart() {
    _currentIndex = 0;
    _selectedAnswers = List.filled(qcmList.length, null);
    _state = QCMState.notStarted;
    isCorrect = null;
  }
}
