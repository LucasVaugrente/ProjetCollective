import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seriouse_game/models/cours.dart';
import 'JeuQCMViewModel.dart';
import 'JeuQCMView.dart';

class QCMGamePage extends StatelessWidget {
  final Cours cours;

  const QCMGamePage({super.key, required this.cours});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JeuQCMViewModel()..chargerQCM(cours),
      child: JeuQCMView(cours: cours),
    );
  }
}
