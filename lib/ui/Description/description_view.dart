import 'package:flutter/material.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/ui/Cours/cours_view_model.dart';

class DescriptionView extends StatelessWidget {
  const DescriptionView({
    super.key,
    required this.cours,
    required this.coursViewModel,
  });

  final CoursViewModel coursViewModel;
  final Cours cours;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du cours
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'lib/assets/goals.png',
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 24),
            // Titre du cours
            Text(
              cours.titre,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Description du cours
            Text(
              cours.contenu,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            // ✅ Section objectifs supprimée car n'existe plus
            const SizedBox(height: 32),
            // Bouton pour commencer le cours
            Center(
              child: ElevatedButton(
                onPressed: () {
                  coursViewModel.changementPageSuivante(cours);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color.fromRGBO(252, 179, 48, 1),
                ),
                child: const Text(
                  "Commencer le cours",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
