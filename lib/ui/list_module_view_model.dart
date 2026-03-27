import 'package:flutter/foundation.dart';
import 'package:factoscope/logic/progression_use_case.dart';
import 'package:factoscope/models/module.dart';
import 'package:factoscope/repositories/module_repository.dart';

class ListModuleViewModel with ChangeNotifier {
  final progressionUseCase = ProgressionUseCase();

  List<Module> listModule = List.empty();

  Future<void> recupererModule() async {
    try {
      listModule = await ModuleRepository().getAll();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print("Erreur lors de la récupération des modules : $e");
    }
  }

  // Progression globale en % entier
  Future<int> getProgressionGlobale() async {
    final progress = await progressionUseCase.calculerProgressionGlobale();
    return progress.round();
  }

  // Progression d'un module → [0.0, 1.0] pour LinearProgressIndicator
  Future<double> getProgressionModule(Module module) async {
    return await progressionUseCase.calculerProgressionModule(module.id!);
  }
}
