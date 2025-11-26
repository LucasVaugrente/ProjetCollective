import 'package:flutter/material.dart';
import 'package:factoscope/logic/progression_use_case.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/models/module.dart';
import 'package:factoscope/repositories/cours_repository.dart';
import 'package:factoscope/ui/module_selectionne.dart';

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