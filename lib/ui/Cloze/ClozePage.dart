import 'package:flutter/material.dart';
import '../../services/cloze_service.dart';
import '../../models/Cloze/cloze_model.dart';

class ClozePage extends StatefulWidget {
  final int coursId;
  const ClozePage({super.key, required this.coursId});

  @override
  State<ClozePage> createState() => _ClozePageState();
}

class _ClozePageState extends State<ClozePage> {
  final service = ClozeService();
  final controller = TextEditingController();

  List<ClozeQuestion> questions = [];
  int index = 0;
  String feedback = '';

  @override
  void initState() {
    super.initState();
    service.getQuestionsPourCours(widget.coursId).then((value) {
      setState(() => questions = value);
    });
  }

  Future<void> _loadQuestions() async {
    final data = await service.getQuestionsPourCours(widget.coursId);
    setState(() => questions = data);
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final phrase = questions[index].phrase;
    final solution = extraireSolution(phrase);

    return Scaffold(
      appBar: AppBar(title: const Text('Texte à trous')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              masquerSolution(phrase),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Votre réponse',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _validerReponse,
              child: const Text('Valider'),
            ),
            const SizedBox(height: 10),
            Text(
              feedback,
              style: TextStyle(
                  color: feedback == 'Bonne réponse'
                      ? Colors.green
                      : Colors.red,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _validerReponse() {
    final ok = service.verifierReponse(controller.text, extraireSolution(questions[index].phrase));
    setState(() {
      feedback = ok ? 'Bonne réponse' : 'Mauvaise réponse';
      if (ok) {
        if (index < questions.length - 1) {
          index++;
          controller.clear();
        } else {
          feedback = 'Vous avez terminé toutes les questions !';
        }
      }
    });
  }

  String extraireSolution(String phrase) {
    final regex = RegExp(r'\[(.*?)\]');
    return regex.firstMatch(phrase)?.group(1) ?? '';
  }

  String masquerSolution(String phrase) {
    return phrase.replaceAll(RegExp(r'\[(.*?)\]'), '_____');
  }
}
