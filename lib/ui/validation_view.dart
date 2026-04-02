import 'package:flutter/material.dart';
import 'package:factoscope/ui/QCM/qcm_officiel_view.dart';
import 'package:factoscope/ui/cours_selectionne.dart';
import 'package:factoscope/ui/QCM/page_succes_qcm.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kCertificatObtenu = 'certificat_obtenu';

class ValidationView extends StatefulWidget {
  const ValidationView({super.key});

  @override
  State<ValidationView> createState() => _ValidationViewState();
}

class _ValidationViewState extends State<ValidationView> {
  bool _dejaReussi = false;

  @override
  void initState() {
    super.initState();
    _verifierReussite();
  }

  Future<void> _verifierReussite() async {
    final prefs = await SharedPreferences.getInstance();
    final reussi = prefs.getBool(kCertificatObtenu) ?? false;
    if (mounted) setState(() => _dejaReussi = reussi);
  }

  @override
  Widget build(BuildContext context) {
    if (_dejaReussi) {
      return _buildDejaReussi(context);
    }
    return _buildTest(context);
  }

  Widget _buildDejaReussi(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified, size: 100, color: Colors.green),
            ),
            const SizedBox(height: 32),
            const Text(
              "Certification obtenue !",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "Vous avez déjà validé le test officiel.\nVous pouvez régénérer votre certificat à tout moment.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PageSuccesQCM()),
                  );
                },
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text(
                  "Télécharger mon certificat",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTest(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Icône principale
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 3, 47, 122)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                size: 100,
                color: Color.fromARGB(255, 3, 47, 122),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              "Test de Validation",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            const Text(
              "Obtenez votre validation officielle",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Carte d'information
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromARGB(255, 3, 47, 122)
                      .withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.stars,
                    "Score requis",
                    "100%",
                    const Color.fromRGBO(252, 179, 48, 1),
                  ),
                  const Divider(height: 32),
                  _buildInfoRow(
                    Icons.quiz,
                    "Type de test",
                    "QCM officiel",
                    const Color.fromARGB(255, 3, 47, 122),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Règles du test
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(252, 179, 48, 1)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color.fromRGBO(252, 179, 48, 1),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.rule,
                        color: Color.fromRGBO(252, 179, 48, 1),
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "Règles importantes",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildRule("📚",
                      "Complétez tous les modules avant de passer le test"),
                  _buildRule("✅", "Vous devez obtenir 100% de bonnes réponses"),
                  _buildRule("⏱️", "Le test se fera sous 30 minutes"),
                  _buildRule("🏆",
                      "Une fois validé, vous recevrez votre certification"),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Message d'encouragement
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 90, 230, 220)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
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
                      "Conseil : Révisez bien tous les cours avant de commencer le test officiel !",
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

            // Bouton Commencer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final cours = CoursSelectionne.instance.cours;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QCMOfficielView(cours: cours),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color.fromARGB(255, 3, 47, 122),
                ),
                child: const Text(
                  "Commencer",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
} // fin _buildTest

Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ],
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
          style: const TextStyle(fontSize: 20),
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
