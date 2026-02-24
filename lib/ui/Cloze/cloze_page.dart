import '../../services/cloze_service.dart';
import 'package:flutter/material.dart';
import '../../models/Cloze/cloze_page.dart';
import 'cloze_result_page.dart';

class ClozePage extends StatefulWidget {
  final int coursId;

  const ClozePage({
    super.key,
    required this.coursId,
  });

  @override
  State<ClozePage> createState() => _ClozePageState();
}

class _ClozePageState extends State<ClozePage> {
  final service = ClozeService();
  List<ClozeQuestion> questions = [];
  String? selectedAnswer;
  String feedback = '';
  bool? isCorrect;
  int score = 0;
  bool isFinished = false;
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

  Widget _buildAnswer(String answer) {
    Color bgColor = Colors.white;
    if (selectedAnswer != null && answer == selectedAnswer) {
      bgColor = isCorrect! ? Colors.green[200]! : Colors.red[200]!;
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
        child: Text(
          answer,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  void _validerReponse() {
    if (selectedAnswer == null)  return;

    final question = questions[currentIndex];
    String soluce;
    switch (question.soluce) {
      case 1:
        soluce = question.rep1;
        break;
      case 2:
        soluce = question.rep2;
        break;
      case 3:
        soluce = question.rep3;
        break;
      case 4:
        soluce = question.rep4;
        break;
      default:
        soluce = "";
    }

    final ok = service.verifierReponse(selectedAnswer!, soluce);

    setState(() {
      isCorrect = ok;
      feedback = ok ? 'Bonne réponse' : 'Mauvaise réponse';
      if (ok) {
        score++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (isFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text("Résultat")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Votre score",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                "$score / ${questions.length}",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    score = 0;
                    isFinished = false;
                    selectedAnswer = null;
                    isCorrect = null;
                  });
                },
                child: const Text("Recommencer"),
              ),
            ],
          ),
        ),
      );
    }

    final question = questions[currentIndex];
    final List<String> propositions = [
      question.rep1,
      question.rep2,
      question.rep3,
      question.rep4,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Texte à trous'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.phrase,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: currentIndex > 0
                        ? () {
                      setState(() {
                        currentIndex--;
                        selectedAnswer = null;
                        isCorrect = null;
                      });
                    }
                        : null,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back,
                            size: 14, color: Color(0xFF292466)),
                        SizedBox(width: 4),
                        Text('Précédent'),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: () {
                      if (currentIndex >= questions.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClozeResultPage(
                              score: score,
                              totalQuestions: questions.length,
                              coursId: widget.coursId,
                            ),
                          ),
                        );

                      } else {
                        setState(() {
                          currentIndex++;
                          selectedAnswer = null;
                          isCorrect = null;
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentIndex >= questions.length - 1
                              ? 'Terminer'
                              : 'Suivant',),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward,
                            size: 14, color: Color(0xFF292466)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
