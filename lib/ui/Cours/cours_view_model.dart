import 'package:flutter/foundation.dart';
import 'package:factoscope/logic/progression_use_case.dart';
import 'package:factoscope/repositories/QCM/qcm_repository.dart';
import 'package:factoscope/repositories/page_repository.dart';
import 'package:factoscope/models/cours.dart';

import '../../database_helper.dart';
import '../../repositories/Cloze/cloze_repository.dart';

class CoursViewModel extends ChangeNotifier {
  CoursViewModel();

  // Information de la page actuelle
  // 0 : Page de description
  // 1-nbPage : Page de contenu
  // >nbPage : Page de jeu
  int page = 0;

  final pageRepository = PageRepository();
  final qcmRepository = QCMRepository();
  final progressionUseCase = ProgressionUseCase();

  Future<int> getNombrePageDeContenu(Cours cours) async {
    final lstPage = await pageRepository.getPagesByCourseId(cours.id!);
    return lstPage.length;
  }

  Future<int> getNombrePageQCM(Cours cours) async {
    int nbQCM = await qcmRepository
        .getAllIdByCoursId(cours.id!)
        .then((lstIdPageJeu) => lstIdPageJeu.length);
    return nbQCM;
  }

  Future<int> getNombrePageCloze(Cours cours) async {
    int nbCloze = await progressionUseCase.getNombrePageDeCloze(cours);
    return nbCloze;
  }

  Future<void> setIndexPageVisite(Cours cours) async {
    final indexPage = await pageRepository.getNbPageVisite(cours.id!);
    page = indexPage;
    notifyListeners();
  }

  Future<void> changementPageSuivante(Cours cours) async {
    final nbPages = await getNombrePageDeContenu(cours);
    int nbJeux = await getNombrePageQCM(cours);
    nbJeux += await getNombrePageCloze(cours);

    final bool aucunJeu = nbJeux == 0;

    // Sans jeu : description(0) + pages(nbPages) + fin(1)
    // Avec jeu  : description(0) + pages(nbPages) + transition(1) + jeux(nbJeux) + fin(1)
    final totalPages = aucunJeu ? nbPages + 1 : nbPages + nbJeux + 2;

    if (page < totalPages) {
      page++;

      // Sauter transition + jeux si aucun jeu (on arrive directement à la fin)
      if (aucunJeu && page == nbPages + 1) {
        page = totalPages; // ← page de fin directement
      }

      // Marquer la page comme visitée si c'est une page de contenu
      if (page > 0 && page <= nbPages) {
        final pages = await pageRepository.getPagesByCourseId(cours.id!);
        if (page - 1 < pages.length) {
          await pageRepository.setPageVisite(pages[page - 1].id!);
        }
      }
      notifyListeners();
    }
  }

  void changementPagePrecedente() {
    if (page > 0) {
      page--;
      notifyListeners();
    }
  }

  void resetCours() {
    page = 1;
    notifyListeners();
  }

  final clozeRepository = ClozeRepository();

  Future<double> getProgressionActuelle(Cours cours) async {
    return await progressionUseCase.calculerProgressionActuelleCours(
            cours.id!, page) /
        100;
  }

  Future<void> loadContenu(Cours cours) async {
    // Récupération des pages avec leurs médias déjà parsés
    cours.pages = await pageRepository.getPagesByCourseId(cours.id!);
  }

  Future<String> getTypeJeu(int coursId) async {
    final db = await DatabaseHelper.instance.database;

    final qcmResult = await db.query(
      'qcm',
      where: 'id_cours = ?',
      whereArgs: [coursId],
      limit: 1,
    );
    if (qcmResult.isNotEmpty) return 'qcm';

    final clozeResult = await db.query(
      'Cloze',
      where: 'idCours = ?',
      whereArgs: [coursId],
      limit: 1,
    );
    if (clozeResult.isNotEmpty) return 'cloze';

    return 'aucun';
  }
}
