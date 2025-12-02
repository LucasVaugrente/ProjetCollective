import 'package:flutter/foundation.dart';
import 'package:seriouse_game/repositories/coursRepository.dart';
import 'package:seriouse_game/repositories/moduleRepository.dart';
import 'package:seriouse_game/repositories/pageRepository.dart';

class ProgressionUseCase {
  final pageRepository = PageRepository();
  final coursRepository = CoursRepository();
  final moduleRepository = ModuleRepository(); 

  ProgressionUseCase();

  // Méthode pour récupérer le pourcentage de pages vues pour un module donné en passant l'ID du module en paramètre
  Future<double> calculerProgressionGlobale() async {
    try {
      // Récupération des modules
      final lstModules = await moduleRepository.getAll();

      // Somme des progressions des modules
      double pourcentage = 0;
      for (final module in lstModules) {
        pourcentage += await calculerProgressionModule(module.id!);
      }

      // Moyenne
      pourcentage /= lstModules.length;

      return pourcentage;
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du calcul du pourcentage de progression globale : $e");
      }
      return 0;
    }
  }

  // Méthode pour récupérer le pourcentage de pages vues pour un module donné en passant l'ID du module en paramètre
  Future<double> calculerProgressionModule(int moduleId) async {
    try {
      // Récupération des cours du module
      final lstCours = await coursRepository.getCoursesByModuleId(moduleId);

      // Somme des progressions des cours du module
      double pourcentage = 0;
      for (final cours in lstCours) {
        pourcentage += await calculerProgressionCours(cours.id!);
      }

      // Moyenne
      pourcentage /= lstCours.length;

      return pourcentage;
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du calcul du pourcentage de progression de module : $e");
      }
      return 0;
    }
  }

  // Méthode pour récupérer le pourcentage de pages vues pour un cours donné en passant l'ID du cours en paramètre
  Future<double> calculerProgressionCours(int coursId) async {
    try {
      // Récupération du nombre total de pages pour le cours
      final totalPages = await pageRepository.getNbPageByCourseId(coursId);

      // Récupération du nombre de pages vues pour le cours
      final pagesVues = await pageRepository.getNbPageVisite(coursId);

      // Calcul du pourcentage de pages vues
      double pourcentage;
      if (totalPages>0) {
        pourcentage = (pagesVues / totalPages) * 100;
      } else {
        pourcentage = 0;
      }

      return pourcentage;
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du calcul du pourcentage de pages vues : $e");
      }
      return 0;
    }
  }

  // Méthode pour récupérer le pourcentage de pages vues pour un cours donné en passant l'ID du cours en paramètre
  Future<double> calculerProgressionActuelleCours(int coursId, int page) async {
    try {
      // Récupération du nombre total de pages pour le cours
      final totalPages = await pageRepository.getNbPageByCourseId(coursId);

      // Calcul du pourcentage de pages vues
      final pourcentage = (page / totalPages) * 100;

      return pourcentage;
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du calcul du pourcentage de pages vues : $e");
      }
      return 0;
    }
  }
}
