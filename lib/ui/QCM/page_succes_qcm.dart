import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class PageSuccesQCM extends StatefulWidget {
  const PageSuccesQCM({super.key});

  @override
  State<PageSuccesQCM> createState() => _PageSuccesQCMState();
}

class _PageSuccesQCMState extends State<PageSuccesQCM> {
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _generating = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    super.dispose();
  }

  String get _dateAujourdhui {
    // initializeDateFormatting est idempotent — sans risque d'appels multiples
    initializeDateFormatting('fr_FR');
    return DateFormat("d MMMM yyyy", "fr_FR").format(DateTime.now());
  }

  Future<void> _genererEtPartagerCertificat() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _generating = true);

    try {
      final pdf = pw.Document();
      final nom = _nomController.text.trim().toUpperCase();
      final prenom = _prenomController.text.trim();
      final date = _dateAujourdhui;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) =>
              _buildCertificatePage(nom, prenom, date),
        ),
      );

      // Aperçu + partage/impression via printing
      await Printing.layoutPdf(
        onLayout: (_) async => pdf.save(),
        name: 'Certificat_Factoscope_${prenom}_$nom.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  pw.Widget _buildCertificatePage(String nom, String prenom, String date) {
    const black = PdfColors.black;
    const white = PdfColors.white;
    const grey = PdfColor.fromInt(0xFF444444);
    const lightGrey = PdfColor.fromInt(0xFF666666);
    const borderGrey = PdfColor.fromInt(0xFFCCCCCC);
    const sepGrey = PdfColor.fromInt(0xFFDDDDDD);

    const marginOuter = 12.0;
    const marginInner = 15.0;

    return pw.Stack(
      children: [
        // ── Fond blanc ──────────────────────────────────────────────────────
        pw.Positioned.fill(
          child: pw.Container(color: white),
        ),

        // ── Bordure externe ─────────────────────────────────────────────────
        pw.Positioned.fill(
          child: pw.Container(
            margin: const pw.EdgeInsets.all(marginOuter),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: black, width: 2),
            ),
          ),
        ),

        // ── Bordure interne ─────────────────────────────────────────────────
        pw.Positioned.fill(
          child: pw.Container(
            margin: const pw.EdgeInsets.all(marginInner),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: black, width: 0.5),
            ),
          ),
        ),

        // ── Contenu centré ───────────────────────────────────────────────────
        pw.Positioned.fill(
          child: pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 30),
            child: pw.Column(
              children: [
                // Bande noire top
                pw.Container(
                  width: double.infinity,
                  color: black,
                  padding: const pw.EdgeInsets.symmetric(vertical: 16),
                  child: pw.Text(
                    "FACTOSCOPE",
                    style: pw.TextStyle(
                      font: pw.Font.helveticaBold(),
                      fontSize: 22,
                      color: white,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),

                pw.SizedBox(height: 36),

                // Titre
                pw.Text(
                  "CERTIFICAT DE RÉUSSITE",
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 26,
                    color: black,
                  ),
                  textAlign: pw.TextAlign.center,
                ),

                pw.SizedBox(height: 8),
                pw.Divider(color: black, thickness: 1),
                pw.SizedBox(height: 28),

                // Décerné à
                pw.Text(
                  "Ce certificat est décerné à",
                  style: pw.TextStyle(
                    font: pw.Font.helvetica(),
                    fontSize: 13,
                    color: grey,
                  ),
                  textAlign: pw.TextAlign.center,
                ),

                pw.SizedBox(height: 16),

                // Nom complet
                pw.Text(
                  "$prenom $nom",
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 32,
                    color: black,
                  ),
                  textAlign: pw.TextAlign.center,
                ),

                pw.SizedBox(height: 10),
                pw.Divider(
                    color: borderGrey,
                    thickness: 0.5,
                    indent: 60,
                    endIndent: 60),
                pw.SizedBox(height: 28),

                // "pour avoir obtenu"
                pw.Text(
                  "pour avoir obtenu la note de",
                  style: pw.TextStyle(
                    font: pw.Font.helvetica(),
                    fontSize: 12,
                    color: grey,
                  ),
                  textAlign: pw.TextAlign.center,
                ),

                pw.SizedBox(height: 12),

                // 100%
                pw.Text(
                  "100%",
                  style: pw.TextStyle(
                    font: pw.Font.helveticaBold(),
                    fontSize: 64,
                    color: black,
                  ),
                  textAlign: pw.TextAlign.center,
                ),

                pw.SizedBox(height: 10),

                pw.Text(
                  "au test de validation officiel Factoscope",
                  style: pw.TextStyle(
                    font: pw.Font.helvetica(),
                    fontSize: 13,
                    color: grey,
                  ),
                  textAlign: pw.TextAlign.center,
                ),

                pw.SizedBox(height: 28),
                pw.Divider(
                    color: sepGrey, thickness: 0.5, indent: 30, endIndent: 30),
                pw.SizedBox(height: 20),

                // Date
                pw.Text(
                  "Délivré le $date",
                  style: pw.TextStyle(
                    font: pw.Font.helvetica(),
                    fontSize: 11,
                    color: lightGrey,
                  ),
                  textAlign: pw.TextAlign.center,
                ),

                pw.Spacer(),

                // Bande noire bas
                pw.Container(
                  width: double.infinity,
                  color: black,
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  child: pw.Text(
                    "Outil pédagogique de vérification de l'information · factoscope.fr",
                    style: pw.TextStyle(
                      font: pw.Font.helvetica(),
                      fontSize: 9,
                      color: white,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color.fromRGBO(41, 36, 96, 1);
    // const orange = Color.fromRGBO(252, 179, 48, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Certification"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Header félicitations
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.emoji_events, size: 64, color: Colors.amber),
                    SizedBox(height: 12),
                    Text(
                      "Félicitations ! 🎉",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Vous avez obtenu 100% au test officiel.\nRenseignez vos informations pour générer votre certificat.",
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              _buildInput(
                label: "Nom",
                controller: _nomController,
                icon: Icons.person,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Le nom est requis" : null,
              ),
              const SizedBox(height: 16),
              _buildInput(
                label: "Prénom",
                controller: _prenomController,
                icon: Icons.person_outline,
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Le prénom est requis"
                    : null,
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    "Date d'obtention : $_dateAujourdhui",
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _generating ? null : _genererEtPartagerCertificat,
                icon: _generating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text(
                  _generating ? "Génération..." : "Générer mon certificat",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
