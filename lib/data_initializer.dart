import 'package:factoscope/models/module.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/repositories/cours_repository.dart';
import 'package:factoscope/repositories/module_repository.dart';
import 'package:factoscope/repositories/page_repository.dart';
import 'package:factoscope/ui/module_selectionne.dart';
import 'package:factoscope/ui/cours_selectionne.dart';
import 'package:flutter/foundation.dart';

final moduleRepository = ModuleRepository();
final coursRepository = CoursRepository();
final pageRepository = PageRepository();

Future<void> insertSampleData() async {
  CoursSelectionne coursSelectionne = CoursSelectionne.instance;
  List<Cours> lstCours = await coursRepository.getAll();
  if (lstCours.isNotEmpty) {
    coursSelectionne.setCours(lstCours[0]);
  }

  if (kDebugMode) {
    print(coursSelectionne);
  }

  // Init du singleton ModuleSelectionne
  ModuleSelectionne moduleSelectionne = ModuleSelectionne.instance;
  List<Module> lstModule = await moduleRepository.getAll();
  if (lstModule.isNotEmpty) {
    moduleSelectionne.moduleSelectionne = lstModule[0];
  }
}
