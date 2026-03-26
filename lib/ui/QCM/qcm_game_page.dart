import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:factoscope/models/cours.dart';

import 'jeu_qcm_view_model.dart';
import 'jeu_qcm_view.dart';

class QCMGamePage extends StatelessWidget {
  final Cours cours;
  final void Function(int score, int total) onTermine;

  const QCMGamePage({
    super.key,
    required this.cours,
    required this.onTermine,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JeuQCMViewModel()..chargerQCM(cours),
      child: JeuQCMView(cours: cours, onTermine: onTermine),
    );
  }
}
