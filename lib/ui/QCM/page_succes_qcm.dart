import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _dateNaissController = TextEditingController();
  final _lieuNaissController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _generating = false;
  String _dateAujourdhui = '';

  @override
  void initState() {
    super.initState();
    _initDate();
  }

  Future<void> _initDate() async {
    await initializeDateFormatting('fr_FR');
    if (mounted) {
      setState(() {
        _dateAujourdhui =
            DateFormat("d MMMM yyyy", "fr_FR").format(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _dateNaissController.dispose();
    _lieuNaissController.dispose();
    super.dispose();
  }

  static const _blue = PdfColor.fromInt(0xFF1F3A8A);
  static const _grey = PdfColor.fromInt(0xFF555555);
  static const _teal = PdfColor.fromInt(0xFF4DBDB5);

  Future<Uint8List> _buildPdf(String prenom, String nom, String dateNaiss,
      String lieuNaiss, String dateObtention) async {
    final pdf = pw.Document();

    final logoEpjtData = await rootBundle.load('assets/logo_epjt.jpeg');
    final logoFactoscopeData =
        await rootBundle.load('assets/logo_factoscope.png');
    final logoUnivData = await rootBundle.load('assets/logo_universite.png');
    final fontData =
        await rootBundle.load('assets/LiberationSerif-Regular.ttf');
    final fontBoldData =
        await rootBundle.load('assets/LiberationSerif-Bold.ttf');

    final logoEpjt = pw.MemoryImage(logoEpjtData.buffer.asUint8List());
    final logoFactoscope =
        pw.MemoryImage(logoFactoscopeData.buffer.asUint8List());
    final logoUniv = pw.MemoryImage(logoUnivData.buffer.asUint8List());
    final ttf = pw.Font.ttf(fontData);
    final ttfBold = pw.Font.ttf(fontBoldData);

    const footerTxt =
        "Ecole Publique de Journalisme de Tours (EPJT) \u2013 \u00c9cole agr\u00e9\u00e9e par la CPNEJ"
        " - 29 rue du Pont Volant 37100 TOURS \u2013 EPJT.fr";

    pw.Widget footer() => pw.Text(
          footerTxt,
          style: pw.TextStyle(font: ttf, fontSize: 7, color: _teal),
          textAlign: pw.TextAlign.center,
        );

    // ── PAGE 1 ────────────────────────────────────────────────────────────────
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: pw.EdgeInsets.fromLTRB(14, 12, 14, 10),
      build: (ctx) => pw.Stack(
        children: [
          // Watermark université — grand, centré
          pw.Positioned(
            left: ctx.page.pageFormat.availableWidth * 0.08,
            top: ctx.page.pageFormat.availableHeight * 0.28,
            child: pw.Opacity(
              opacity: 0.10,
              child: pw.Image(logoUniv,
                  width: ctx.page.pageFormat.availableWidth * 0.84),
            ),
          ),

          pw.Positioned.fill(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // ── Logos
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Image(logoEpjt,
                        width: 130, height: 130, fit: pw.BoxFit.contain),
                    pw.Image(logoFactoscope,
                        width: 220, height: 60, fit: pw.BoxFit.contain),
                  ],
                ),

                pw.SizedBox(height: 18),

                // ── ATTESTATION
                pw.Text("ATTESTATION",
                    style: pw.TextStyle(
                        font: ttfBold, fontSize: 48, color: _blue)),

                pw.SizedBox(height: 22),

                // ── M./Mme Prénom NOM
                pw.RichText(
                    text: pw.TextSpan(children: [
                  pw.TextSpan(
                      text: "M./Mme ",
                      style: pw.TextStyle(
                          font: ttfBold, fontSize: 20, color: PdfColors.black)),
                  pw.TextSpan(
                      text: "$prenom ${nom.toUpperCase()}",
                      style: pw.TextStyle(
                          font: ttfBold, fontSize: 20, color: PdfColors.black)),
                ])),

                pw.SizedBox(height: 12),

                // ── Né(e) le DATE A LIEU
                pw.RichText(
                    text: pw.TextSpan(children: [
                  pw.TextSpan(
                      text: "N\u00e9(e) le ",
                      style: pw.TextStyle(
                          font: ttfBold, fontSize: 20, color: PdfColors.black)),
                  pw.TextSpan(
                      text: dateNaiss,
                      style: pw.TextStyle(
                          font: ttfBold, fontSize: 20, color: PdfColors.black)),
                  pw.TextSpan(
                      text: " A ",
                      style: pw.TextStyle(
                          font: ttfBold, fontSize: 20, color: PdfColors.black)),
                  pw.TextSpan(
                      text: lieuNaiss,
                      style: pw.TextStyle(
                          font: ttfBold, fontSize: 20, color: PdfColors.black)),
                ])),

                pw.SizedBox(height: 20),

                // ── "a validé..."
                pw.Text("a valid\u00e9 avec succ\u00e8s une action de",
                    style: pw.TextStyle(
                        font: ttf, fontSize: 13, color: PdfColors.black)),

                pw.SizedBox(height: 12),

                // ── SENSIBILISATION EMI
                pw.Text("SENSIBILISATION EMI",
                    style: pw.TextStyle(
                        font: ttfBold, fontSize: 30, color: _blue)),

                pw.SizedBox(height: 18),

                // ── Texte explicatif
                pw.Text(
                    "via l\u2019application EMI du m\u00e9dia francophone Factoscope.fr",
                    style: pw.TextStyle(
                        font: ttf, fontSize: 12, color: PdfColors.black)),
                pw.Text(
                    "con\u00e7ue par l\u2019\u00c9cole publique de journalisme de Tours (France).",
                    style: pw.TextStyle(
                        font: ttfBold, fontSize: 12, color: PdfColors.black)),

                pw.SizedBox(height: 22),

                // ── Date d'obtention
                pw.Text("A Tours, le $dateObtention.",
                    style: pw.TextStyle(
                        font: ttf, fontSize: 12, color: PdfColors.black)),

                pw.Spacer(),
                footer(),
              ],
            ),
          ),
        ],
      ),
    ));

    // ── PAGE 2 ────────────────────────────────────────────────────────────────
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: pw.EdgeInsets.fromLTRB(14, 12, 30, 10),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.SizedBox(height: 40),
          pw.Text("Le directeur de l\u2019EPJT",
              style: pw.TextStyle(font: ttf, fontSize: 12, color: _grey)),
          pw.SizedBox(height: 4),
          pw.Text("M. Laurent BIGOT",
              style: pw.TextStyle(font: ttfBold, fontSize: 12, color: _grey)),
          pw.Spacer(),
          pw.Align(
            alignment: pw.Alignment.center,
            child: footer(),
          ),
        ],
      ),
    ));

    return pdf.save();
  }

  Future<void> _genererAttestation() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _generating = true);
    try {
      final bytes = await _buildPdf(
        _prenomController.text.trim(),
        _nomController.text.trim(),
        _dateNaissController.text.trim(),
        _lieuNaissController.text.trim(),
        _dateAujourdhui,
      );
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'Attestation_Factoscope_${_prenomController.text.trim()}_'
            '${_nomController.text.trim().toUpperCase()}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandBlue = Color.fromRGBO(41, 36, 96, 1);

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
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Column(children: [
                  Icon(Icons.emoji_events, size: 64, color: Colors.amber),
                  SizedBox(height: 12),
                  Text("Félicitations ! 🎉",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  Text(
                    "Vous avez obtenu 100% au test officiel.\n"
                    "Renseignez vos informations pour générer votre attestation.",
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ]),
              ),
              const SizedBox(height: 32),
              _buildInput(
                  label: "Nom",
                  controller: _nomController,
                  icon: Icons.person,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? "Le nom est requis"
                      : null),
              const SizedBox(height: 16),
              _buildInput(
                  label: "Prénom",
                  controller: _prenomController,
                  icon: Icons.person_outline,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? "Le prénom est requis"
                      : null),
              const SizedBox(height: 16),
              _buildInput(
                  label: "Date de naissance (JJ/MM/AAAA)",
                  controller: _dateNaissController,
                  icon: Icons.cake,
                  keyboardType: TextInputType.datetime,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Requis" : null),
              const SizedBox(height: 16),
              _buildInput(
                  label: "Lieu de naissance",
                  controller: _lieuNaissController,
                  icon: Icons.location_city,
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? "Requis" : null),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text("Date d'obtention : $_dateAujourdhui",
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ]),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _generating ? null : _genererAttestation,
                icon: _generating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text(
                  _generating ? "Génération..." : "Générer mon attestation",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
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
