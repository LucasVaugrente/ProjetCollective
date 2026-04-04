import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  static const brandBlue = Color.fromRGBO(41, 36, 96, 1);
  static const textColor = Color(0xFF666666);

  // Contrôleurs pour les champs de config
  final _apiController = TextEditingController();
  final _mediasController = TextEditingController();
  bool _configVisible = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _chargerConfig();
  }

  Future<void> _chargerConfig() async {
    final prefs = await SharedPreferences.getInstance();
    _apiController.text =
        prefs.getString('config_api_url') ?? AppConfig.effectiveApiUrl;
    _mediasController.text =
        prefs.getString('config_url_medias') ?? AppConfig.urlMedias;
  }

  Future<void> _sauvegarderConfig() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('config_api_url', _apiController.text.trim());
    await prefs.setString('config_url_medias', _mediasController.text.trim());
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuration sauvegardée ✓'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _reinitialiserConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('config_api_url');
    await prefs.remove('config_url_medias');
    await _chargerConfig();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Configuration réinitialisée'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _apiController.dispose();
    _mediasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
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
                  borderRadius: BorderRadius.circular(15)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Factoscope est un outil pédagogique conçu pour vous accompagner dans votre formation. Notre objectif est de vous donner les clés pour décrypter l'information au quotidien.",
                  style: TextStyle(fontSize: 16, height: 1.5, color: textColor),
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

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),

            // ─── Section configuration discrète ───────────────────────────────
            GestureDetector(
              onTap: () => setState(() => _configVisible = !_configVisible),
              child: Row(
                children: [
                  Icon(
                    _configVisible ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[400],
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Configuration avancée",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            if (_configVisible) ...[
              const SizedBox(height: 16),
              _buildConfigField(
                label: "URL de l'API (Site d'hébergement des Cours)",
                controller: _apiController,
                hint: "http://192.168.x.x:8000",
                icon: Icons.api,
              ),
              const SizedBox(height: 12),
              _buildConfigField(
                label: "URL des médias (Cloudflare)",
                controller: _mediasController,
                hint: "https://pub-xxxx.r2.dev",
                icon: Icons.cloud,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reinitialiserConfig,
                      icon: const Icon(Icons.restart_alt, size: 16),
                      label: const Text("Réinitialiser"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _sauvegarderConfig,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save, size: 16),
                      label: const Text("Sauvegarder"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Un redémarrage de l'application est nécessaire pour appliquer les changements.",
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontStyle: FontStyle.italic),
              ),
            ],

            const SizedBox(height: 32),
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

  Widget _buildConfigField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: Colors.grey[400]),
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[300]),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
        ),
      ],
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
              color: iconColor.withValues(alpha: 0.1),
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
