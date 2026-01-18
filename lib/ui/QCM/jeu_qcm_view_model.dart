import 'dart:async';
import 'package:factoscope/models/QCM/qcm.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/repositories/QCM/qcm_repository.dart';
import 'package:flutter/foundation.dart';

class JeuQCMViewModel {
  Future<Map<String, dynamic>> recupererQCM(
      Cours cours, int selectedPageIndex) async {
    try {
      final qcmRepo = QCMRepository();

      // Récupérer tous les QCM du cours
      List<QCM> qcmList = await qcmRepo.getAllByCoursId(cours.id!);

      // Vérifier que l'index est valide
      if (selectedPageIndex >= qcmList.length) {
        throw Exception("Index de QCM invalide");
      }

      QCM qcm = qcmList[selectedPageIndex];

      // Retourner les données du QCM dans le format attendu par la vue
      return {
        "question": qcm.question,
        "options": qcm.getReponses(),
        "correctAnswer": qcm.soluce,
      };
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du chargement du QCM : $e");
      }
      return {};
    }
  }
}
