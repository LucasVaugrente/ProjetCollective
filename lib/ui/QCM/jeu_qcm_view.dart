import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'jeu_qcm_view_model.dart';
import 'package:factoscope/models/cours.dart';

class JeuQCMView extends StatelessWidget {
  final Cours cours;
  final void Function(int score, int total) onTermine;
  final VoidCallback? onPrecedent;

  const JeuQCMView({
    super.key,
    required this.cours,
    required this.onTermine,
    this.onPrecedent,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<JeuQCMViewModel>(
      create: (_) => JeuQCMViewModel()..chargerQCM(cours),
      child: Consumer<JeuQCMViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.hasError || vm.controller == null) {
            return const Center(child: Text("Impossible de charger le QCM"));
          }
          // Quand le QCM est terminé → on notifie CoursView
          if (vm.isFinished) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onTermine(vm.getScore(), vm.totalQuestions);
            });
            // Afficher un loader pendant la transition
            return const Center(child: CircularProgressIndicator());
          }

          return _buildQuestionPage(context, vm);
        },
      ),
    );
  }

  Widget _buildQuestionPage(BuildContext context, JeuQCMViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Question ${vm.currentIndex + 1} / ${vm.totalQuestions}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
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
                    title: Text(vm.options[i],
                        style: const TextStyle(fontSize: 16)),
                    onTap: () {
                      if (vm.selectedAnswer == null) vm.selectAnswer(i);
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // Précédent — retour transition si 1ère question
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: vm.currentIndex > 0 ? vm.previous : onPrecedent,
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
                  onPressed: vm.selectedAnswer != null ? vm.next : null,
                  icon: const Icon(Icons.arrow_forward,
                      size: 18, color: Color(0xFF292466)),
                  label: Text(
                    vm.currentIndex == vm.totalQuestions - 1
                        ? 'Terminer'
                        : 'Suivant',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF292466)),
                  ),
                  iconAlignment: IconAlignment.end,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: vm.selectedAnswer != null
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
