import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'qcm_officiel_view_model.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/models/QCM/qcm.dart';
import 'package:factoscope/ui/QCM/page_succes_qcm.dart';

class QCMOfficielView extends StatelessWidget {
  final Cours cours;

  const QCMOfficielView({super.key, required this.cours});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = QCMOfficielViewModel();

        vm.onSuccess = () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PageSuccesQCM()),
          );
        };

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

          // --- BOUTONS JAUNES ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: vm.currentIndex > 0 ? vm.previous : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  decoration: BoxDecoration(
                    color: vm.currentIndex > 0
                        ? const Color(0xFFFFD54F)
                        : const Color(0xFFFFECB3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.arrow_back, color: Colors.black87),
                      SizedBox(width: 8),
                      Text(
                        "Précédent",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              GestureDetector(
                onTap: vm.selectedIndex != null ? vm.next : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  decoration: BoxDecoration(
                    color: vm.selectedIndex != null
                        ? const Color(0xFFFFD54F)
                        : const Color(0xFFFFECB3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      Text(
                        vm.currentIndex == vm.totalQuestions - 1
                            ? "Terminer"
                            : "Suivant",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.black87),
                    ],
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

//
//  PAGE D’ÉCHEC PROFESSIONNELLE
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
    final List<int> wrongIndexes = [];

    for (int i = 0; i < qcms.length; i++) {
      if (userAnswers[i] != qcms[i].soluce) {
        wrongIndexes.add(i);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Analyse des erreurs"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: wrongIndexes.isEmpty
            ? _buildPerfectScore()
            : _buildWrongAnswersList(wrongIndexes),
      ),
    );
  }

  Widget _buildPerfectScore() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.emoji_events, color: Colors.amber, size: 80),
          SizedBox(height: 20),
          Text(
            "Aucune erreur !",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Vous avez répondu correctement à toutes les questions.",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWrongAnswersList(List<int> wrongIndexes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Vous avez ${wrongIndexes.length} erreur(s)",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 16),

        Expanded(
          child: ListView.builder(
            itemCount: wrongIndexes.length,
            itemBuilder: (context, index) {
              final qIndex = wrongIndexes[index];
              final q = qcms[qIndex];
              final user = userAnswers[qIndex];
              final correct = q.soluce;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.close, color: Colors.red, size: 26),
                          const SizedBox(width: 8),
                          Text(
                            "Question ${qIndex + 1}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Text(
                        q.question,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Votre réponse : ${user != null ? q.getReponses()[user] : "Aucune"}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "Bonne réponse : ${q.getReponses()[correct]}",
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
