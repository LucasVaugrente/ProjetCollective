import 'package:flutter/material.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/ui/Cours/cours_view_model.dart';

class TransitionQCMView extends StatelessWidget {
  final Cours cours;
  final CoursViewModel coursViewModel;

  const TransitionQCMView({
    super.key,
    required this.cours,
    required this.coursViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(252, 179, 48, 1)
                    .withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.quiz,
                size: 80,
                color: Color.fromRGBO(252, 179, 48, 1),
              ),
            ),
            const SizedBox(height: 32),

            // Titre
            const Text(
              "Temps de vérifier vos connaissances !",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Règles du jeu
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📋 Règles du jeu",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRule("✓", "Lisez attentivement chaque question"),
                  _buildRule(
                      "✓", "Sélectionnez la réponse qui vous semble correcte"),
                  _buildRule(
                      "✓", "Validez pour voir si votre réponse est bonne"),
                  _buildRule("✓", "Vous verrez immédiatement le résultat"),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Message d'encouragement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 90, 230, 220)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color.fromARGB(255, 90, 230, 220),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb,
                    color: Color.fromARGB(255, 3, 47, 122),
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Prenez votre temps et réfléchissez bien. Bonne chance !",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Bouton pour commencer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  coursViewModel.changementPageSuivante(cours);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color.fromRGBO(252, 179, 48, 1),
                ),
                child: const Text(
                  "Commencer le jeu",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRule(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            icon,
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 90, 230, 220),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
