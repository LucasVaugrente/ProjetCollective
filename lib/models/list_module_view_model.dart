import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:factoscope/logic/progression_use_case.dart';
import 'package:factoscope/models/module.dart';
import 'package:factoscope/repositories/module_repository.dart';

// Classe permettant d'extraire la liste des modules
class ListModuleViewModel with ChangeNotifier {
  final progressionUseCase = ProgressionUseCase();

  List<Module> listModule = List.empty();

  Future<void> recupererModule() async {
    try {
      listModule = await ModuleRepository().getAll();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors de la récupération des modules : $e");
      }
    }
  }

  Future<int> getProgressionGlobale() async {
    double progress = await progressionUseCase.calculerProgressionGlobale();
    return progress.round();
  }

  Future<double> getProgressionModule(Module module) async {
    return 0.0;
  }
}
