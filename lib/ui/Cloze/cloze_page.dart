import 'package:flutter/material.dart';
import '../../services/cloze_service.dart';
import '../../models/Cloze/cloze_page.dart';

class ClozePage extends StatefulWidget {
  final int coursId;
  final int clozeIndex;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const ClozePage({
    super.key,
    required this.coursId,
    required this.clozeIndex,
    this.onNext,
    this.onPrevious,
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
    final bool isSelected = selectedAnswer == answer;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAnswer = answer;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF292466) : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Expanded(
              child: Text(
                answer,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validerReponse() {
    if (selectedAnswer == null) {
      setState(() {
        isCorrect = false;
        feedback = 'Veuillez choisir une réponse';
      });
      return;
    }

    final question = questions[widget.clozeIndex];
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
    });
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[widget.clozeIndex];
    final List<String> propositions = [
      question.rep1,
      question.rep2,
      question.rep3,
      question.rep4,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Texte à trous')),
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
                    const SizedBox(height: 12),
                    ...propositions.map(_buildAnswer),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: buttonWidth,
              height: buttonHeight,
              child: ElevatedButton(
                style: buttonStyle,
                onPressed: _validerReponse,
                child: const Text('Valider'),
              ),
            ),

            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isCorrect == null
                    ? Colors.transparent
                    : isCorrect!
                        ? Colors.green[200]
                        : Colors.red[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                feedback,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: ElevatedButton(
                    style: buttonStyle,
                    onPressed: widget.onPrevious,
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
                    onPressed: widget.onNext,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Suivant'),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward,
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
