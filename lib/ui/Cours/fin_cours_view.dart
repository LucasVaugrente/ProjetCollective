import 'package:flutter/material.dart';
import 'package:factoscope/models/cours.dart';
import 'package:go_router/go_router.dart';

class FinCoursView extends StatelessWidget {
  final Cours cours;
  final int? score;
  final int? totalQuestions;
  // Callback pour recommencer le jeu (retour à la transition)
  final VoidCallback? onRecommencer;

  const FinCoursView({
    super.key,
    required this.cours,
    this.score,
    this.totalQuestions,
    this.onRecommencer,
  });

  @override
  Widget build(BuildContext context) {
    final bool aUnJeu =
        score != null && totalQuestions != null && totalQuestions! > 0;
    final bool parfait = aUnJeu && score == totalQuestions;
    final bool bien = aUnJeu && score! >= (totalQuestions! / 2).ceil();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Icône
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (parfait
                        ? Colors.green
                        : bien
                            ? Colors.orange
                            : Colors.red)
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                parfait
                    ? Icons.celebration
                    : bien
                        ? Icons.thumb_up
                        : Icons.sentiment_dissatisfied,
                size: 100,
                color: parfait
                    ? Colors.green
                    : bien
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 32),

            // Titre
            Text(
              parfait
                  ? "Félicitations !"
                  : bien
                      ? "Bien joué !"
                      : "Dommage...",
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Message chapitre terminé
            Text(
              "Vous avez terminé le chapitre\n« ${cours.titre} »",
              style: const TextStyle(fontSize: 18, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Bloc score si jeu présent
            if (aUnJeu) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (parfait
                          ? Colors.green
                          : bien
                              ? Colors.orange
                              : Colors.red)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: parfait
                        ? Colors.green
                        : bien
                            ? Colors.orange
                            : Colors.red,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      size: 50,
                      color: parfait
                          ? Colors.green
                          : bien
                              ? const Color.fromRGBO(252, 179, 48, 1)
                              : Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "$score / $totalQuestions",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: parfait
                            ? Colors.green
                            : bien
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      parfait
                          ? "Excellent ! Tu as tout compris, bravo !"
                          : bien
                              ? "Bon travail ! Continue à t'entraîner pour progresser 💪"
                              : "Ne te décourage pas, révise et réessaie !",
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Bouton recommencer si score insuffisant
              if (!parfait && onRecommencer != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onRecommencer,
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      "Recommencer le jeu",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side: const BorderSide(
                          color: Color.fromRGBO(252, 179, 48, 1), width: 2),
                      foregroundColor: const Color.fromRGBO(252, 179, 48, 1),
                    ),
                  ),
                ),

              const SizedBox(height: 12),
            ] else ...[
              // Pas de jeu — message générique
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 90, 230, 220)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.emoji_events,
                        size: 50, color: Color.fromRGBO(252, 179, 48, 1)),
                    SizedBox(height: 16),
                    Text("Excellent travail !",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Bouton retour aux chapitres
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => GoRouter.of(context).go('/list_cours'),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text(
                  "Retour aux chapitres",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  backgroundColor: const Color.fromRGBO(252, 179, 48, 1),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
