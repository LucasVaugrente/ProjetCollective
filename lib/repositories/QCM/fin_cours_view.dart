import 'package:flutter/material.dart';
import 'package:factoscope/models/cours.dart';
import 'package:go_router/go_router.dart';

class FinCoursView extends StatelessWidget {
  final Cours cours;

  const FinCoursView({
    Key? key,
    required this.cours,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            // Icône de succès
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                size: 100,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 32),

            // Titre
            const Text(
              "Félicitations !",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Message
            Text(
              "Vous avez terminé le cours\n« ${cours.titre} »",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Message d'encouragement
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 90, 230, 220).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 50,
                    color: Color.fromRGBO(252, 179, 48, 1),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Excellent travail !",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Vous avez acquis de nouvelles connaissances importantes sur ${cours.titre.toLowerCase()}.",
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Bouton retour au module
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Retour à la liste des cours du module
                  GoRouter.of(context).go('/list_cours');
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text(
                  "Retour au module",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
              ),
            ),
            const SizedBox(height: 16),

            // Bouton retour à l'accueil (optionnel)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Retour à l'accueil
                  GoRouter.of(context).go('/');
                },
                icon: const Icon(
                  Icons.home,
                  color: Color.fromARGB(255, 3, 47, 122),
                ),
                label: const Text(
                  "Retour à l'accueil",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color.fromARGB(255, 3, 47, 122),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(
                    color: Color.fromARGB(255, 3, 47, 122),
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
