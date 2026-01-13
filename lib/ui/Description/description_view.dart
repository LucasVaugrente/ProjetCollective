import 'package:flutter/material.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/ui/Cours/cours_view_model.dart';

class DescriptionView extends StatelessWidget {
  const DescriptionView(
      {Key? key, required this.cours, required this.coursViewModel})
      : super(key: key);

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
            // Section des objectifs
            const Text(
              "Objectifs :",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // Liste des objectifs
            if (cours.objectifs != null && cours.objectifs!.isNotEmpty)
              Column(
                children: cours.objectifs!
                    .map(
                      (objectif) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                objectif.description,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Aucun objectif défini pour ce cours."),
              ),
            const SizedBox(height: 32),
            // Bouton pour commencer le cours
            Center(
              child: ElevatedButton(
                onPressed: () {
                  coursViewModel.changementPageSuivante();
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
