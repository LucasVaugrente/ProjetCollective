import 'package:flutter/foundation.dart';
import 'package:factoscope/logic/progression_use_case.dart';
import 'package:factoscope/repositories/QCM/qcm_repository.dart';
import 'package:factoscope/repositories/page_repository.dart';
import 'package:factoscope/models/cours.dart';

class CoursViewModel extends ChangeNotifier {
  CoursViewModel();

  int page = 0;

  final pageRepository = PageRepository();
  final qcmRepository = QCMRepository();
  final progressionUseCase = ProgressionUseCase();

  Future<int> getNombrePageDeContenu(Cours cours) async {
    final lstPage = await pageRepository.getPagesByCourseId(cours.id!);
    return lstPage.length;
  }

  Future<int> getNombrePageDeJeu(Cours cours) async {
    final lstIdPageJeu = await qcmRepository.getAllIdByCoursId(cours.id!);
    return lstIdPageJeu.length;
  }

  Future<void> setIndexPageVisite(Cours cours) async {
    final indexPage = await pageRepository.getNbPageVisite(cours.id!);
    page = indexPage;
    notifyListeners();
  }

  void changementPageSuivante() async {
    page++;
    await pageRepository.setPageVisite(page);
    notifyListeners();
  }

  void changementPagePrecedente() {
    if (page > 0) {
      page--;
      notifyListeners();
    }
  }

  Future<double> getProgressionActuelle(Cours cours) async {
    return await progressionUseCase.calculerProgressionActuelleCours(cours.id!, page) / 100;
  }

  Future<void> loadContenu(Cours cours) async {
    // Récupération des pages avec leurs médias déjà parsés
    cours.pages = await pageRepository.getPagesByCourseId(cours.id!);
    if (kDebugMode) {
      print("Nombre de pages récupérées : ${cours.pages?.length}");
      for (var page in cours.pages ?? []) {
        print("Page ${page.id} : ${page.medias?.length ?? 0} médias");
      }
    }
  }
}