import 'package:flutter/material.dart';
import 'package:seriouse_game/logic/ProgressionUseCase.dart';
import 'package:seriouse_game/models/cours.dart';
import 'package:seriouse_game/models/module.dart';
import 'package:seriouse_game/repositories/coursRepository.dart';
import 'package:seriouse_game/ui/ModuleSelectionne.dart';

//Classe permettant d'extraire les cours d'un module 
class ListCoursViewModel with ChangeNotifier {
  
  final progressionUseCase = ProgressionUseCase();

  //Méthode pour changer la liste coursDuModule du Singleton ModuleSelectionne par celle correspondant à la liste des cours du module d'id idModule
  Future<void> recupererCours(int? idModule) async {

    CoursRepository repository = CoursRepository();

    //On accède à la liste des cours de la base de donnée par la méthode de CoursRepository
    ModuleSelectionne().updateListModule(await repository.getCoursesByModuleId(idModule!));

    //la liste change donc  on avertit les listeners
    notifyListeners();
  }

  Future<double> getProgressionModule(Module module) async {
    return await progressionUseCase.calculerProgressionCours(module.id!)/100;
  }

  Future<double> getProgressionCours(Cours cours) async {
    return await progressionUseCase.calculerProgressionCours(cours.id!)/100;
  }
  

}