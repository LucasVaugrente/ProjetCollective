import 'package:flutter/material.dart';
import 'package:seriouse_game/logic/ProgressionUseCase.dart';
import 'package:seriouse_game/models/module.dart';
import 'package:seriouse_game/repositories/moduleRepository.dart';

//Classe permettant d'extraire la liste des modules
class ListModuleViewModel with ChangeNotifier {
  
  final progressionUseCase = ProgressionUseCase();

  List<Module> listModule = List.empty();

  //Méthode pour changer la liste listmodule par celle correspondant à la liste de tous les modules de l'application
  Future<void> recupererModule() async {

    //Création d'un objet repository pour accéder aux modules de l'application
    ModuleRepository repository = ModuleRepository();

    //On accède à la liste des module de la base de donnée par la méthode de ModuleRepository
    listModule = await repository.getAll();

    //la liste change donc  on avertit les listeners
    notifyListeners();
  }
  
  Future<int> getProgressionGlobale() async {
    double progress = await progressionUseCase.calculerProgressionGlobale();
    return progress.round();
  }

}