import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'qcm_officiel_view_model.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/models/QCM/qcm.dart';

// 👉 Page succès (déjà créée)
import 'package:factoscope/ui/QCM/page_succes_qcm.dart';

class QCMOfficielView extends StatelessWidget {
  final Cours cours;

  const QCMOfficielView({super.key, required this.cours});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = QCMOfficielViewModel();

        // 👉 Redirection quand score = 100%
        vm.onSuccess = () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PageSuccesQCM()),
          );
        };

        // 👉 Redirection quand score < 100%
        vm.onFailure = (score) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PageEchecDetaillee(
                score: score,
                qcms: vm.controller!.qcmList,
                userAnswers: vm.userAnswers,
              ),
            ),
          );
        };

        vm.chargerQCM(cours);
        return vm;
      },
      child: Consumer<QCMOfficielViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 2,
              title: _buildTimer(vm),
              centerTitle: true,
            ),
            body: _buildQuestion(context, vm),
          );
        },
      ),
    );
  }

  Widget _buildTimer(QCMOfficielViewModel vm) {
    Color color;

    if (vm.duration > 180) {
      color = Colors.green;
    } else if (vm.duration > 60) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Temps restant : ${vm.timerText}",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context, QCMOfficielViewModel vm) {
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

          Text(
            vm.questionText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: vm.options.length,
              itemBuilder: (context, i) {
                bool isSelected = vm.selectedIndex == i;

                return GestureDetector(
                  onTap: () => vm.selectAnswer(i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      vm.options[i],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: vm.currentIndex == 0 ? null : vm.previous,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  vm.currentIndex == 0 ? Colors.grey : Colors.blueGrey,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: const Text(
                  "Précédent",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              ElevatedButton(
                onPressed: vm.selectedIndex == null ? null : vm.next,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  vm.selectedIndex == null ? Colors.grey : Colors.blue,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: Text(
                  vm.currentIndex == vm.totalQuestions - 1
                      ? "Terminer"
                      : "Suivant",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//
//  PAGE ECHEC DÉTAILLÉE
//

class PageEchecDetaillee extends StatelessWidget {
  final double score;
  final List<QCM> qcms;
  final List<int?> userAnswers;

  const PageEchecDetaillee({
    super.key,
    required this.score,
    required this.qcms,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Résultat du QCM officiel")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Vous étiez proche !",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              "Score : ${(score * 100).toStringAsFixed(0)}%",
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            const Text(
              "Analyse de vos réponses",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: qcms.length,
                itemBuilder: (context, index) {
                  final q = qcms[index];
                  final user = userAnswers[index];
                  final correct = q.soluce;

                  final bool isCorrect = user == correct;

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Question ${index + 1}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            q.question,
                            style: const TextStyle(fontSize: 16),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              const Text("Votre réponse : ",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                user != null
                                    ? q.getReponses()[user]
                                    : "Aucune réponse",
                                style: TextStyle(
                                  color: isCorrect ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Row(
                            children: [
                              const Text("Bonne réponse : ",
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                q.getReponses()[correct],
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isCorrect ? "Correct" : "Incorrect",
                              style: TextStyle(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
