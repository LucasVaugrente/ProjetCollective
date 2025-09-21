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

  // Ajout de la logique pour suivre si on est sur la question suivante
  @override
  void didUpdateWidget(covariant JeuQCMView oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si la page sélectionnée change, réinitialiser l'état
    if (oldWidget.selectedPageIndex != widget.selectedPageIndex) {
      setState(() {
        _selectedAnswer = null;
        _validated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Jeu QCM")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: JeuQCMViewModel().recupererQCM(widget.cours, widget.selectedPageIndex),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Erreur lors du chargement"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Aucune donnée disponible"));
          }

          var data = snapshot.data as Map<String, dynamic>;

          Question question = data["question"];
          String? questionText;
          if (question.type == "text") {
            questionText = question.text;
          } else if (question.type == "image") {
            questionText = question.imageUrl;
          } else {
            throw Exception("Format question non respecte : Image ou texte ");
          }

          List<Reponse> reponses = data["options"];
          List<String?> reponseText;
          if (reponses.first.imageUrl == null && reponses.first.text != null) {
            reponseText = reponses.map((r) => r.text).toList();
          } else if (reponses.first.imageUrl != null && reponses.first.text == null) {
            reponseText = reponses.map((r) => r.imageUrl).toList();
          } else {
            throw Exception("Format reponse non respecter : Image ou texte ");
          }

          int correctAnswer = data["correctAnswer"];

          return Column(
            children: [
              _buildQuestionWidget(questionText),
              ...List.generate(reponseText.length, (index) => _buildAnswerWidget(reponseText[index], index + 1, correctAnswer)),
              ElevatedButton(
                onPressed: _selectedAnswer == null
                    ? null
                    : () {
                        setState(() {
                          _validated = true;
                        });
                      },
                child: const Text("Valider"),
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
          : Image.network(question), // Remplace par Image.asset si fichiers locaux
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
        onChanged: _validated
            ? null
            : (int? value) {
                setState(() {
                  _selectedAnswer = value;
                });
              },
      ),
      tileColor: color,
    );
  }
}
