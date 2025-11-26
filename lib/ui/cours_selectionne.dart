import 'package:factoscope/models/cours.dart';

class CoursSelectionne {
  CoursSelectionne._privateConstructor();

  static final CoursSelectionne _instance = CoursSelectionne._privateConstructor();

  static CoursSelectionne get instance => _instance;

  Cours cours = Cours(idModule: 0, titre: "UTILISE POUR INIT LE SINGLETON COURSSELECTIONNE", contenu: "UTILISE POUR INIT LE SINGLETON COURSSELECTIONNE");

  void setCours(Cours cours) {
    this.cours = cours;
  }
}