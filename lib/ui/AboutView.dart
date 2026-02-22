import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color.fromRGBO(41, 36, 96, 1);
    const textColor = Color(0xFF666666);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: brandBlue),
              label: const Text(
                "Retour à l'accueil",
                style: TextStyle(color: brandBlue, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "À propos de Factoscope",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: brandBlue,
              ),
            ),
            const Text(
              "Version 1.0.0",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Notre Mission", brandBlue),
            const SizedBox(height: 12),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Factoscope est un outil pédagogique conçu pour vous accompagner dans votre formation. Notre objectif est de vous donner les clés pour décrypter l'information au quotidien.",
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle("Fonctionnalités", brandBlue),
            const SizedBox(height: 12),
            _buildFeatureItem(
              Icons.download_for_offline_rounded,
              "Mode Hors-ligne",
              "Téléchargez vos cours pour étudier partout, même sans connexion.",
              brandBlue,
            ),
            _buildFeatureItem(
              Icons.extension_rounded,
              "Mini-jeux interactifs",
              "Testez vos connaissances de manière ludique après chaque leçon.",
              brandBlue,
            ),
            _buildFeatureItem(
              Icons.workspace_premium_rounded,
              "Validation des acquis",
              "Obtenez un document officiel validant votre parcours de formation.",
              brandBlue,
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                "© 2026 Factoscope - Tous droits réservés",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildFeatureItem(
      IconData icon, String title, String description, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSectionTitle(String title, Color color) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: color,
    ),
  );
}

Widget _buildFeatureItem(
    IconData icon, String title, String description, Color iconColor) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
