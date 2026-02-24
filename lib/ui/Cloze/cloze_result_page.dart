import 'package:flutter/material.dart';
import 'cloze_page.dart';

class ClozeResultPage extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final int coursId;

  const ClozeResultPage({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.coursId,

  });

  @override
  Widget build(BuildContext context) {
    bool isPerfect = score == totalQuestions;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text("Résultat"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Icon(
                isPerfect ? Icons.celebration : Icons.thumb_up,
                size: 80,
                color: isPerfect ? Colors.green : Colors.orange,
              ),

              const SizedBox(height: 20),

              Text(
                isPerfect ? "Félicitations !" : "Bravo !",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                isPerfect
                    ? "Excellent travail ! Vous avez tout réussi 🎉"
                    : "Bon travail ! Continuez à vous entraîner pour progresser 💪",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              Text(
                "Score : $score / $totalQuestions",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClozePage(
                        coursId: coursId,
                      ),
                    ),
                  );
                },
                child: const Text("Recommencer"),
              ),

              const SizedBox(height: 12),

            ],
          ),
        ),
      ),
    );
  }
}