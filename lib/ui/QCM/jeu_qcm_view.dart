import 'package:flutter/material.dart';
import 'package:factoscope/models/cours.dart';
import 'jeu_qcm_view_model.dart';

class JeuQCMView extends StatefulWidget {
  final Cours cours;
  final int selectedPageIndex;

  const JeuQCMView({
    super.key,
    required this.cours,
    required this.selectedPageIndex,
  });

  @override
  _JeuQCMViewState createState() => _JeuQCMViewState();
}

class _JeuQCMViewState extends State<JeuQCMView> {
  int? _selectedAnswer;
  bool _validated = false;

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
    return FutureBuilder<Map<String, dynamic>>(
      future: JeuQCMViewModel()
          .recupererQCM(widget.cours, widget.selectedPageIndex),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Erreur lors du chargement: ${snapshot.error}"),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Aucune donnée disponible"));
        }

        var data = snapshot.data!;

        // ✅ Données simplifiées
        String questionText = data["question"] as String;
        List<String> reponses = data["options"] as List<String>;
        int correctAnswer = data["correctAnswer"] as int;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuestionWidget(questionText),
              const SizedBox(height: 20),
              ...List.generate(
                reponses.length,
                (index) => _buildAnswerWidget(
                  reponses[index],
                  index + 1,
                  correctAnswer,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _selectedAnswer == null
                      ? null
                      : () {
                          setState(() {
                            _validated = true;
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: const Color.fromRGBO(252, 179, 48, 1),
                  ),
                  child: const Text(
                    "Valider",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionWidget(String question) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        question,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildAnswerWidget(String answer, int index, int correctAnswer) {
    Color? color;
    if (_validated) {
      if (index == correctAnswer) {
        color = Colors.green.withValues(alpha: 0.3);
      } else if (index == _selectedAnswer) {
        color = Colors.red.withValues(alpha: 0.3);
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: color,
      child: ListTile(
        title: Text(answer),
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
      ),
    );
  }
}
