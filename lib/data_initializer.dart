import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:factoscope/models/module.dart';
import 'package:factoscope/repositories/cours_repository.dart';
import 'package:factoscope/repositories/module_repository.dart';
import 'package:factoscope/repositories/page_repository.dart';
import 'package:factoscope/ui/module_selectionne.dart';
import 'package:factoscope/ui/cours_selectionne.dart';
import 'package:flutter/foundation.dart';
import 'package:factoscope/database_helper.dart';
import 'models/cours.dart';
import 'models/page.dart';

final moduleRepository = ModuleRepository();
final coursRepository = CoursRepository();
final pageRepository = PageRepository();

Future<void> insertModule1() async {
  final String response =
  await rootBundle.loadString('lib/data/AppData/Module1/metadata.json');
  final moduleData = await json.decode(response);

  final module = Module(
      titre: moduleData['titre'],
      urlImg: moduleData['urlImg'] ?? 'assets/facto-societe.png',
      description: moduleData['description']);
  final moduleId = await moduleRepository.create(module);

  Cours cours = Cours(
      idModule: moduleId,
      titre: 'Les sources d\'informations',
      contenu: 'Comprendre et évaluer les sources d\'information.',
      description: 'Description des sources d\'informations.');
  final coursId = await coursRepository.create(cours);

  // Page 1 : Introduction aux sources d'information
  Page page1 = Page(
    idCours: coursId,
    description: "Qu'est-ce qu'une source d'information ?",
    medias: [
      MediaItem(
        ordre: 1,
        url: 'lib/data/AppData/Module1/Cours1/source_information_definition.txt',
        type: 'text',
      ),
      MediaItem(
        ordre: 2,
        url: 'lib/data/AppData/Module1/Cours1/journaliste_interview.jpg',
        type: 'image',
        caption: 'Journaliste réalisant une interview',
      ),
    ],
  );
  await pageRepository.create(page1);

  // Page 2 : Les différentes sources
  Page page2 = Page(
    idCours: coursId,
    description: "Types de sources d'information",
    medias: [
      MediaItem(
        ordre: 1,
        url: 'lib/data/AppData/Module1/Cours1/types_sources.txt',
        type: 'text',
      ),
      MediaItem(
        ordre: 2,
        url: 'lib/data/AppData/Module1/Cours1/source_primaire_secondaire.png',
        type: 'image',
        caption: 'Illustration des sources primaires et secondaires',
      ),
    ],
  );
  await pageRepository.create(page2);

  // Page 3 : Évaluer la crédibilité d'une source
  Page page3 = Page(
    idCours: coursId,
    description: "Comment vérifier la fiabilité d'une source ?",
    medias: [
      MediaItem(
        ordre: 1,
        url: 'lib/data/AppData/Module1/Cours1/evaluer_sources.txt',
        type: 'text',
      ),
      MediaItem(
        ordre: 2,
        url: 'lib/data/AppData/Module1/Cours1/fake_news_verification.png',
        type: 'image',
        caption: 'Techniques de vérification des fake news',
      ),
    ],
  );
  await pageRepository.create(page3);
}

Future<void> insertModule2() async {
  final module = Module(
      titre: 'Producteur de contenus',
      urlImg: 'assets/facto-societe.png',
      description:
      'Grâce aux technologies modernes, tout le monde est aujourd\'hui en mesure de diffuser des informations et de produire des contenus.');
  final moduleId = await moduleRepository.create(module);

  Cours cours = Cours(
      idModule: moduleId,
      titre: 'Ethique professionnelle et personnelle',
      contenu: '',
      description: '');
  await coursRepository.create(cours);

  cours = Cours(
      idModule: moduleId,
      titre: 'Journalisme et production de contenus',
      contenu: '',
      description: '');
  await coursRepository.create(cours);
}

Future<void> insertModule3() async {
  final module = Module(
      titre: 'Pros des médias',
      urlImg: 'assets/facto-societe.png',
      description:
      'Les journalistes sont des professionnels de l\'information.');
  final moduleId = await moduleRepository.create(module);

  Cours cours = Cours(
      idModule: moduleId, titre: 'Déontologie', contenu: '', description: '');
  await coursRepository.create(cours);
}

Future<void> insertModule4() async {
  final module = Module(
      titre: 'Pour aller plus loin',
      urlImg: 'assets/facto-societe.png',
      description: 'Toutes les références et ressources en relation avec l\'EMI.');
  final moduleId = await moduleRepository.create(module);

  Cours cours = Cours(
      idModule: moduleId,
      titre: 'Références bibliographiques',
      contenu: '',
      description: '');
  await coursRepository.create(cours);
}

Future<void> insertSampleData() async {
  await DatabaseHelper.instance.resetDB();

  await insertModule1();
  await insertModule2();
  await insertModule3();
  await insertModule4();

  // Init du singleton CoursSelectionne
  CoursSelectionne coursSelectionne = CoursSelectionne.instance;
  List<Cours> lstCours = await coursRepository.getAll();
  if (lstCours.isNotEmpty) {
    coursSelectionne.setCours(lstCours[0]);
  }

  print(coursSelectionne);

  // Init du singleton ModuleSelectionne
  ModuleSelectionne moduleSelectionne = ModuleSelectionne.instance;
  List<Module> lstModule = await moduleRepository.getAll();
  if (lstModule.isNotEmpty) {
    moduleSelectionne.moduleSelectionne = lstModule[0];
  }

  print(moduleSelectionne);

  if (kDebugMode) {
    print('Toutes les données d\'exemple ont été insérées avec succès.');
  }
}