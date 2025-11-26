import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:seriouse_game/models/QCM/qcm.dart';
import 'package:seriouse_game/models/QCM/question.dart';
import 'package:seriouse_game/models/QCM/reponse.dart';
import 'package:seriouse_game/models/cours.dart';
import 'package:seriouse_game/repositories/QCM/QCMRepository.dart';
 
class JeuQCMViewModel {
  Future<Map<String, dynamic>> recupererQCM(Cours cours, int selectedPageIndex) async {
    try {
      final qcmRepo = QCMRepository();
      List<int> idQCMList = await qcmRepo.getAllIdByCoursId(cours.id!);
      QCM? qcm = await qcmRepo.getById(idQCMList[selectedPageIndex]);
      
      Question? question;
      List<Reponse>? reponses = [];
      int? solution;
      
      if (qcm == null || qcm.question == null || qcm.reponses == null) {
        throw Exception("QCM incomplet ou invalide");
      }

      question = qcm.question;
      reponses = qcm.reponses;
      solution = qcm.numSolution;
      
      return {
        "question": question,
        "options": reponses,
        "correctAnswer": solution,
      };
    
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du chargement du QCM : $e");
      }
      return {};
    }
  }
}

   
