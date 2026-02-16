import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'JeuQCMViewModel.dart';
import 'package:seriouse_game/models/cours.dart';

class JeuQCMView extends StatelessWidget {
  final Cours cours;

  const JeuQCMView({super.key, required this.cours});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JeuQCMViewModel()..chargerQCM(cours),
      child: Consumer<JeuQCMViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (vm.hasError || vm.controller == null) {
            return const Scaffold(
              body: Center(child: Text("Impossible de charger le QCM")),
            );
          }

          if (vm.isFinished) {
            return _buildResultPage(context, vm);
          }

          return _buildQuestionPage(context, vm);
        },
      ),
    );
  }

  // --- PAGE QUESTION ---
  Widget _buildQuestionPage(BuildContext context, JeuQCMViewModel vm) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QCM"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progression
            Text(
              "Question ${vm.currentIndex + 1} / ${vm.totalQuestions}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // Question
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                vm.questionText,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 20),

            // Message Bonne/Mauvaise réponse
            if (vm.isCorrect != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  vm.isCorrect! ? "Bonne réponse !" : "Mauvaise réponse...",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: vm.isCorrect! ? Colors.green : Colors.red,
                  ),
                ),
              ),

            // Réponses
            Expanded(
              child: ListView.builder(
                itemCount: vm.options.length,
                itemBuilder: (context, i) {
                  final isSelected = vm.selectedAnswer == i;

                  Color tileColor = Colors.white;

                  if (vm.isCorrect != null && isSelected) {
                    tileColor = vm.isCorrect!
                        ? Colors.green.shade200
                        : Colors.red.shade200;
                  }

                  return Card(
                    color: tileColor,
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        vm.options[i],
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        if (vm.selectedAnswer == null) {
                          vm.selectAnswer(i);
                        }
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Boutons navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Bouton précédent
                ElevatedButton(
                  onPressed: vm.currentIndex > 0 ? vm.previous : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Précédent"),
                ),

                // Bouton suivant
                ElevatedButton(
                  onPressed: vm.selectedAnswer != null ? vm.next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    vm.currentIndex == vm.totalQuestions - 1
                        ? "Terminer"
                        : "Suivant",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- PAGE RESULTAT ---
  Widget _buildResultPage(BuildContext context, JeuQCMViewModel vm) {
    final score = vm.getScore();

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
              "$score / ${vm.totalQuestions}",
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: vm.restart,
              child: const Text("Recommencer"),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Retour"),
            ),
          ],
        ),
      ),
    );
  }
}
