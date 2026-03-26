import '../../services/cloze_service.dart';
import 'package:flutter/material.dart';
import '../../models/Cloze/cloze_page.dart';

class ClozePage extends StatefulWidget {
  final int coursId;
  final void Function(int score, int total) onTermine;
  // Callback pour revenir à la transition depuis la 1ère question
  final VoidCallback? onPrecedent;

  const ClozePage({
    super.key,
    required this.coursId,
    required this.onTermine,
    this.onPrecedent,
  });

  @override
  State<ClozePage> createState() => _ClozePageState();
}

class _ClozePageState extends State<ClozePage> {
  final service = ClozeService();
  List<ClozeQuestion> questions = [];
  String? selectedAnswer;
  bool? isCorrect;
  int score = 0;
  int currentIndex = 0;

  final double buttonWidth = 140;
  final double buttonHeight = 45;

  late final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFcb330),
    foregroundColor: const Color(0xFF292466),
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );

  @override
  void initState() {
    super.initState();
    service.getQuestionsPourCours(widget.coursId).then((value) {
      setState(() => questions = value);
    });
  }

  void _validerReponse() {
    if (selectedAnswer == null) return;
    final question = questions[currentIndex];
    final soluce = switch (question.soluce) {
      1 => question.rep1,
      2 => question.rep2,
      3 => question.rep3,
      4 => question.rep4,
      _ => "",
    };
    final ok = service.verifierReponse(selectedAnswer!, soluce);
    setState(() {
      isCorrect = ok;
      if (ok) score++;
    });
  }

  Widget _buildAnswer(String answer) {
    Color bgColor = Colors.white;
    if (selectedAnswer != null && answer == selectedAnswer) {
      bgColor = isCorrect! ? Colors.green.shade200 : Colors.red.shade200;
    }
    return GestureDetector(
      onTap: selectedAnswer != null
          ? null
          : () {
              setState(() {
                selectedAnswer = answer;
                _validerReponse();
              });
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(answer,
            style: const TextStyle(fontSize: 16, color: Colors.black87)),
      ),
    );
  }

  void _suivant() {
    if (currentIndex >= questions.length - 1) {
      // Dernière question → notifier CoursView avec le score final
      widget.onTermine(score, questions.length);
    } else {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
        isCorrect = null;
      });
    }
  }

  void _precedent() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        selectedAnswer = null;
        isCorrect = null;
      });
    } else {
      // Première question → retour à la transition
      widget.onPrecedent?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final question = questions[currentIndex];
    final propositions = [
      question.rep1,
      question.rep2,
      question.rep3,
      question.rep4
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Question ${currentIndex + 1} / ${questions.length}",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    question.phrase,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (isCorrect != null)
                    Text(
                      isCorrect! ? "Bonne réponse" : "Mauvaise réponse",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCorrect! ? Colors.green : Colors.red,
                      ),
                    ),
                  const SizedBox(height: 12),
                  ...propositions.map(_buildAnswer),
                ],
              ),
            ),
          ),
          Row(
            children: [
              // Précédent — toujours actif (retour transition si 1ère question)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _precedent,
                  icon: const Icon(Icons.arrow_back,
                      size: 18, color: Color(0xFF292466)),
                  label: const Text('Précédent',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF292466))),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(252, 179, 48, 1),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Suivant / Terminer
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: selectedAnswer != null ? _suivant : null,
                  icon: const Icon(Icons.arrow_forward,
                      size: 18, color: Color(0xFF292466)),
                  label: Text(
                    currentIndex >= questions.length - 1
                        ? 'Terminer'
                        : 'Suivant',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF292466)),
                  ),
                  iconAlignment: IconAlignment.end,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedAnswer != null
                        ? const Color.fromRGBO(252, 179, 48, 1)
                        : const Color.fromRGBO(252, 179, 48, 0.4),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
