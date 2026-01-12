import 'package:flutter/material.dart';
import '../../logic/qcm_controller.dart';
import '../../models/QCM/qcm.dart';

class QCMGamePage extends StatefulWidget {
  final List<QCM> qcmList;

  const QCMGamePage({required this.qcmList});

  @override
  State<QCMGamePage> createState() => _QCMGamePageState();
}

class _QCMGamePageState extends State<QCMGamePage> {
  late QCMController controller;

  @override
  void initState() {
    super.initState();
    controller = QCMController(widget.qcmList);
  }

  @override
  Widget build(BuildContext context) {
    final currentQCM = controller.qcmList[controller.currentIndex];
    final question = currentQCM.question!;
    final reponses = currentQCM.reponses!;

    return Scaffold(
      appBar: AppBar(title: Text("Question ${controller.currentIndex + 1}/${controller.qcmList.length}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.imageUrl != null && question.imageUrl!.isNotEmpty)
              Image.network(question.imageUrl!, height: 150),
            if (question.text != null && question.text!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(question.text!, style: TextStyle(fontSize: 18)),
              ),
            ...List.generate(reponses.length, (i) {
              final rep = reponses[i];
              return ListTile(
                leading: Radio<int>(
                  value: i,
                  groupValue: controller.selectedAnswers[controller.currentIndex],
                  onChanged: (val) => setState(() => controller.selectAnswer(val!)),
                ),
                title: rep.imageUrl != null && rep.imageUrl!.isNotEmpty
                    ? Image.network(rep.imageUrl!, height: 50)
                    : Text(rep.text ?? ""),
              );
            }),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: controller.canGoPrevious() ? () => setState(() => controller.previous()) : null,
                  child: Text("Précédent"),
                ),
                ElevatedButton(
                  onPressed: controller.canGoNext()
                      ? () {
                    setState(() => controller.next());
                    if (controller.currentIndex == controller.qcmList.length - 1) {
                      final score = controller.getScore();
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text("Résultat"),
                          content: Text("Score : $score / ${controller.qcmList.length}"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("OK"),
                            )
                          ],
                        ),
                      );
                    }
                  }
                      : null,
                  child: Text("Suivant"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
