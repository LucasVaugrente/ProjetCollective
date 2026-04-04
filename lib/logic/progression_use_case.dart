import 'package:factoscope/repositories/cours_repository.dart';
import 'package:factoscope/repositories/page_repository.dart';
import 'package:flutter/foundation.dart';

import '../models/cours.dart';
import '../repositories/Cloze/cloze_repository.dart';

class ProgressionUseCase {
  final pageRepository = PageRepository();
  final coursRepository = CoursRepository();
  final ClozeRepository _repository = ClozeRepository();

  ProgressionUseCase();

  // ─── Un chapitre est "terminé" si toutes ses pages sont vues ───────────────

  Future<bool> estChapitreTermine(int coursId) async {
    final total = await pageRepository.getNbPageByCourseId(coursId);
    if (total == 0) return false;
    final vues = await pageRepository.getNbPageVisite(coursId);
    return vues >= total;
  }

  // ─── Progression d'un module : chapitres terminés / chapitres téléchargés ──
  // Utilise les cours locaux (les modules ne sont pas sauvegardés en BDD locale)

  Future<double> calculerProgressionModule(int moduleId) async {
    try {
      final lstCours = await coursRepository.getCoursesByModuleId(moduleId);
      if (lstCours.isEmpty) return 0.0;

      int termines = 0;
      for (final cours in lstCours) {
        if (await estChapitreTermine(cours.id!)) termines++;
      }

      return termines / lstCours.length;
    } catch (e) {
      if (kDebugMode) print("Erreur progression module $moduleId : $e");
      return 0.0;
    }
  }

  // ─── Progression globale : chapitres terminés / chapitres téléchargés ──────
  // Calculée directement depuis tous les cours locaux

  Future<double> calculerProgressionGlobale() async {
    try {
      final tousLesCours = await coursRepository.getAll();
      if (tousLesCours.isEmpty) return 0.0;

      int termines = 0;
      for (final cours in tousLesCours) {
        if (await estChapitreTermine(cours.id!)) termines++;
      }

      return (termines / tousLesCours.length) * 100;
    } catch (e) {
      if (kDebugMode) print("Erreur progression globale : $e");
      return 0.0;
    }
  }

  // ─── Progression d'un cours (pages vues / total) — pour la barre in-cours ──

  Future<double> calculerProgressionCours(int coursId) async {
    try {
      final total = await pageRepository.getNbPageByCourseId(coursId);
      if (total == 0) return 0.0;
      final vues = await pageRepository.getNbPageVisite(coursId);
      return (vues / total) * 100;
    } catch (e) {
      if (kDebugMode) print("Erreur progression cours $coursId : $e");
      return 0.0;
    }
  }

  // ─── Progression actuelle dans le cours (page courante / total pages) ──────

  Future<double> calculerProgressionActuelleCours(int coursId, int page) async {
    try {
      final totalPages = await pageRepository.getNbPageByCourseId(coursId);
      if (totalPages == 0) return 0.0;
      return (page / totalPages) * 100;
    } catch (e) {
      if (kDebugMode) print("Erreur progression actuelle cours : $e");
      return 0.0;
    }
  }

  Future<int> getNombrePageDeCloze(Cours cours) async {
    final clozes = await _repository.getByCoursId(cours.id!);
    return clozes.length;
  }
}
