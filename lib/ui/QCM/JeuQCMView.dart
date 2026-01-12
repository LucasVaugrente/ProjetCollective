import 'package:flutter/material.dart';
import 'package:seriouse_game/models/QCM/question.dart';
import 'package:seriouse_game/models/QCM/reponse.dart';
import 'package:seriouse_game/models/cours.dart';
import 'JeuQCMViewModel.dart';

class JeuQCMView extends StatefulWidget {
  final Cours cours;
  final int selectedPageIndex;

  const JeuQCMView({super.key, required this.cours, required this.selectedPageIndex});

  @override
  _JeuQCMViewState createState() => _JeuQCMViewState();
}

class _JeuQCMViewState extends State<JeuQCMView> {
  int? _selectedAnswer;
  bool _validated = false;
  int _currentQuestionIndex = 0;
  int _score = 0;
  late List<int?> _answers;
  late int _totalQuestions;

  @override
  void initState() {
    super.initState();
    _answers = [];
  }

  void _nextQuestion() {
    if (_selectedAnswer != null) {
      _answers.add(_selectedAnswer);
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _validated = false;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _selectedAnswer = _answers[_currentQuestionIndex];
        _validated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jeu QCM")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: JeuQCMViewModel().recupererQCM(widget.cours, _currentQuestionIndex),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("QCM indisponible pour ce cours"));
          }

          var data = snapshot.data!;
          Question question = data["question"];
          List<Reponse> reponses = data["options"];
          int correctAnswer = data["correctAnswer"];
          _totalQuestions = data["totalQuestions"];

          dynamic questionText = question.type == "text" ? question.text : question.imageUrl;
          List<dynamic> reponseText = reponses.map((r) => r.type == "text" ? r.text : r.imageUrl).toList();

          return Column(
            children: [
              _buildQuestionWidget(questionText),
              ...List.generate(reponseText.length, (index) => _buildAnswerWidget(reponseText[index], index + 1, correctAnswer)),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _selectedAnswer == null ? null : () => setState(() => _validated = true),
                child: const Text("Valider"),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                    child: const Text("Précédent"),
                  ),
                  ElevatedButton(
                    onPressed: _validated ? () {
                      if (_selectedAnswer == correctAnswer) _score++;
                      if (_currentQuestionIndex + 1 < _totalQuestions) {
                        _nextQuestion();
                      } else {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Résultat"),
                            content: Text("Score : $_score / $_totalQuestions"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              )
                            ],
                          ),
                        );
                      }
                    } : null,
                    child: const Text("Suivant"),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionWidget(dynamic question) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: question is String
          ? Text(question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
          : Image.network(question),
    );
  }

  Widget _buildAnswerWidget(dynamic answer, int index, int correctAnswer) {
    Color? color;
    if (_validated) {
      if (index == correctAnswer) {
        color = Colors.green;
      } else if (index == _selectedAnswer) {
        color = Colors.red;
      }
    }

    return ListTile(
      title: answer is String ? Text(answer) : Image.network(answer),
      leading: Radio<int>(
        value: index,
        groupValue: _selectedAnswer,
        onChanged: _validated ? null : (int? value) => setState(() => _selectedAnswer = value),
      ),
      tileColor: color,
    );
  }
}
