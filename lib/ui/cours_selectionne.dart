import 'package:flutter/foundation.dart';
import 'package:factoscope/models/cours.dart';

class CoursSelectionne with ChangeNotifier {
  static final CoursSelectionne instance = CoursSelectionne._internal();
  factory CoursSelectionne() => instance;
  CoursSelectionne._internal();

  Cours cours = Cours(
    idModule: 0,
    titre: "UTILISE POUR INIT LE SINGLETON COURSSELECTIONNE",
    contenu: "UTILISE POUR INIT LE SINGLETON COURSSELECTIONNE",
    description: "UTILISE POUR INIT LE SINGLETON COURSSELECTIONNE",
    isDownloaded: 0,
  );

  void setCours(Cours nouveauCours) {
    if (kDebugMode) {
      print("Mise à jour du cours sélectionné : ${nouveauCours.titre}");
    }
    cours = nouveauCours; // FIX : c'était "cours = cours" avant
    notifyListeners();
  }
}