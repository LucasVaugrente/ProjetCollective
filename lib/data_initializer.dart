import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:factoscope/models/module.dart';
import 'package:factoscope/repositories/cours_repository.dart';

import 'package:factoscope/repositories/module_repository.dart';
import 'package:factoscope/repositories/mot_repository.dart';
import 'package:factoscope/repositories/mots_croises_repository.dart';
import 'package:factoscope/repositories/minijeu_repository.dart';
import 'package:factoscope/repositories/media_cours_repository.dart';
import 'package:factoscope/repositories/objectif_cours_repository.dart';
import 'package:factoscope/repositories/page_repository.dart';

import 'package:factoscope/repositories/QCM/qcm_repository.dart';
import 'package:factoscope/repositories/QCM/question_repository.dart';
import 'package:factoscope/repositories/QCM/reponse_repository.dart';
import 'package:factoscope/ui/module_selectionne.dart';
import 'package:factoscope/ui/cours_selectionne.dart';
import 'package:flutter/foundation.dart';

import 'package:factoscope/database_helper.dart';
import 'models/cours.dart';
import 'models/media_cours.dart';
import 'models/objectif_cours.dart';
import 'models/page.dart';

final moduleRepository = ModuleRepository();
final coursRepository = CoursRepository();
final motRepository = MotRepository();
final motsCroisesRepository = MotsCroisesRepository();
final miniJeuRepository = MiniJeuRepository();
final mediaCoursRepository = MediaCoursRepository();
final pageRepository = PageRepository();
final objectifCoursRepository = ObjectifCoursRepository();

final questionRepo = QuestionRepository();
final reponseRepo = ReponseRepository();
final qcmRepo = QCMRepository();

Future<void> insertModule1() async {
  final String response = await rootBundle.loadString('lib/data/AppData/Module1/metadata.json');
  final moduleData = await json.decode(response);

  final module = Module(
      titre: moduleData['titre'],
      urlImg: moduleData['urlImg'] ?? 'assets/facto-societe.png',
      description: moduleData['description']);
  final moduleId = await moduleRepository.create(module);

  Cours cours = Cours(
      idModule: moduleId,
      titre: 'Les sources d’informations',
      contenu: 'Comprendre et évaluer les sources d’information.',
      description: 'Description des sources d’informations.');
  final coursId = await coursRepository.create(cours);

  // Ajout des Objectifs du Cours
  final objectif1 = ObjectifCours(
    idCours: coursId,
    description: 'Comprendre les différents types de sources d’information',
  );
  final objectif2 = ObjectifCours(
    idCours: coursId,
    description: 'Savoir évaluer la crédibilité d’une source',
  );
  final objectif3 = ObjectifCours(
    idCours: coursId,
    description: 'Identifier les signes de désinformation',
  );

  await objectifCoursRepository.create(objectif1);
  await objectifCoursRepository.create(objectif2);
  await objectifCoursRepository.create(objectif3);

  // Page 1 : Introduction aux sources d'information
  Page page1 = Page(idCours: coursId, description: "Qu'est-ce qu'une source d'information ?");
  int pageId1 = await pageRepository.create(page1);

  await mediaCoursRepository.create(MediaCours(
      idPage: pageId1,
      ordre: 1,
      url: 'lib/data/AppData/Module1/Cours1/source_information_definition.txt',
      type: 'text'));

  await mediaCoursRepository.create(MediaCours(
      idPage: pageId1,
      ordre: 2,
      url: 'lib/data/AppData/Module1/Cours1/journaliste_interview.jpg',
      type: 'image',
      caption: 'Journaliste réalisant une interview'));

  // Page 2 : Les différentes sources
  Page page2 = Page(idCours: coursId, description: "Types de sources d'information");
  int pageId2 = await pageRepository.create(page2);

  await mediaCoursRepository.create(MediaCours(
      idPage: pageId2,
      ordre: 1,
      url: 'lib/data/AppData/Module1/Cours1/types_sources.txt',
      type: 'text'));

  await mediaCoursRepository.create(MediaCours(
      idPage: pageId2,
      ordre: 2,
      url: 'lib/data/AppData/Module1/Cours1/source_primaire_secondaire.png',
      type: 'image',
      caption: 'Illustration des sources primaires et secondaires'));

  // Page 3 : Évaluer la crédibilité d'une source
  Page page3 = Page(idCours: coursId, description: "Comment vérifier la fiabilité d'une source ?");
  int pageId3 = await pageRepository.create(page3);

  await mediaCoursRepository.create(MediaCours(
      idPage: pageId3,
      ordre: 1,
      url: 'lib/data/AppData/Module1/Cours1/evaluer_sources.txt',
      type: 'text'));

  await mediaCoursRepository.create(MediaCours(
      idPage: pageId3,
      ordre: 2,
      url: 'lib/data/AppData/Module1/Cours1/fake_news_verification.png',
      type: 'image',
      caption: 'Techniques de vérification des fake news'));

  // /// Données de test pour les QCM
  // List<QCM> testQCMs = [
  //   QCM(
  //     id: 1,
  //     numSolution: 2,
  //     idCours: 1,
  //     idQuestion: 1,
  //     question:
  //       Question(
  //         id: 1,
  //         text: "Quel est le principal indicateur de la fiabilité d’une source d’information ?",
  //         type: "text",
  //       ),
  //
  //     reponses: [
  //       Reponse(id: 1, idQCM: 1, text: "Sa popularité sur les réseaux sociaux", type: "text"),
  //       Reponse(id: 2, idQCM: 1, text: "La vérifiabilité des informations par d’autres sources fiables", type: "text"),
  //       Reponse(id: 3, idQCM: 1, text: "Le nombre de commentaires sous l’article", type: "text"),
  //       Reponse(id: 4, idQCM: 1, text: "Le design du site web", type: "text"),
  //     ],
  //   ),
  //   QCM(
  //     id: 2,
  //     numSolution: 2,
  //     idCours: 1,
  //     idQuestion: 2,
  //     question:
  //       Question(
  //         id: 2,
  //         text: "Quelle est la meilleure manière de vérifier une information trouvée en ligne ?",
  //         type: "text",
  //       ),
  //
  //     reponses: [
  //       Reponse(id: 5, idQCM: 2, text: "La partager immédiatement avec ses amis", type: "text"),
  //       Reponse(id: 6, idQCM: 2, text: "Consulter plusieurs sources fiables et vérifier la cohérence de l’information", type: "text"),
  //       Reponse(id: 7, idQCM: 2, text: "Faire confiance à la première source trouvée", type: "text"),
  //       Reponse(id: 8, idQCM: 2, text: "Vérifier si l’information est amusante avant de la croire", type: "text"),
  //     ],
  //   ),
  //   QCM(
  //     id: 3,
  //     numSolution: 2,
  //     idCours: 1,
  //     idQuestion: 3,
  //     question:
  //       Question(
  //         id: 3,
  //         text: "Quel est un signe révélateur d’une fausse information ?",
  //         type: "text",
  //       ),
  //
  //     reponses: [
  //       Reponse(id: 9, idQCM: 3, text: "Elle provient d’un média reconnu et sérieux", type: "text"),
  //       Reponse(id: 10, idQCM: 3, text: "Elle utilise un ton sensationnaliste et manque de sources vérifiables", type: "text"),
  //       Reponse(id: 11, idQCM: 3, text: "Elle cite plusieurs experts et références", type: "text"),
  //       Reponse(id: 12, idQCM: 3, text: "Elle est reprise par plusieurs médias de confiance", type: "text"),
  //     ],
  //   ),
  // ];
  //
  // // Insertion des qcm dans la bdd
  // for (var qcm in testQCMs) {
  //   await qcmRepo.insert(qcm);
  //   await questionRepo.insert(qcm.question!);
  //
  //   for (var reponse in qcm.reponses!) {
  //     await reponseRepo.insert(reponse);
  //   }
  // }
}

Future<void> insertModule2() async {
  // Création du Module
  final module = Module(
      titre: 'Producteur de contenus',
      urlImg: 'assets/facto-societe.png',
      description: 'Grâce aux technologies modernes, tout le monde est aujourd’hui en mesure de diffuser des informations et de produire des contenus. Mais tout le monde n’a pas appris les codes, règles et enjeux d’une information responsable à destination du grand public. Que vous ayez 1 à 1 million de followers, ce module est fait pour vous !');
  final moduleId = await moduleRepository.create(module);

  // Création des Cours
  Cours cours = Cours(
      idModule: moduleId,
      titre: 'Ethique professionnelle et personnelle',
      contenu: '',
      description: '');
  // final coursId = await coursRepository.create(cours);

  cours = Cours(
      idModule: moduleId,
      titre: 'Journalisme et production de contenus',
      contenu: '',
      description: '');
  await coursRepository.create(cours);

  cours = Cours(
      idModule: moduleId,
      titre: 'Risques économiques et sociétaux',
      contenu: '',
      description: '');
  await coursRepository.create(cours);

  cours = Cours(
      idModule: moduleId,
      titre: 'EMI - Education aux médias et à l’information',
      contenu: '',
      description: '');
  await coursRepository.create(cours);
}

Future<void> insertModule3() async {
  // Création du Module
  final module = Module(
      titre: 'Pros des médias',
      urlImg: 'assets/facto-societe.png',
      description: 'Les journalistes sont des professionnels de l’information. Pourtant, face à la profusion des sources et, parfois aussi, à l’urgence des situations, ils ne maîtrisent pas tous les clés d’une information traitée éthiquement, professionnellement et de manière responsable. Pourquoi ne pas profiter de ce module pour réviser ses classiques, voire en apprendre davantage sur les techniques de vérification  les plus performantes ?'
      );
  final moduleId = await moduleRepository.create(module);

  // Création des Cours
  Cours cours = Cours(
      idModule: moduleId,
      titre: 'Déontologie',
      contenu: '',
      description: '');
  // final coursId = await coursRepository.create(cours);

  cours = Cours(
      idModule: moduleId,
      titre: 'Osint et Investigation numérique',
      contenu: '',
      description: '');
  await coursRepository.create(cours);

  cours = Cours(
      idModule: moduleId,
      titre: 'SR et fact-checking',
      contenu: '',
      description: '');
  await coursRepository.create(cours);

  cours = Cours(
      idModule: moduleId,
      titre: 'EMI - Education aux médias et à l’information',
      contenu: '',
      description: '');
  await coursRepository.create(cours);

}

Future<void> insertModule4() async {
  // Création du Module
  final module = Module(
      titre: 'Pour aller plus loin',
      urlImg: 'assets/facto-societe.png',
      description: 'Toutes les références et ressources en relation avec l\'Éducation aux médias et à l’information sont répertoriées ici. '
      );
  final moduleId = await moduleRepository.create(module);

  // Création des Cours
  Cours cours = Cours(
      idModule: moduleId,
      titre: 'Références bibliographiques',
      contenu: '',
      description: '');
  // final coursId = await coursRepository.create(cours);

  cours = Cours(
      idModule: moduleId,
      titre: 'Ressources en ligne',
      contenu: '',
      description: '');
  await coursRepository.create(cours);
}

Future<void> insertSampleData() async {
  await DatabaseHelper.instance.resetDB();

  await insertModule1();
  // insertModule2();
  // insertModule3();
  // insertModule4();

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

  //testRepositories();
}

Future<void> testRepositories() async {
  final moduleRepository = ModuleRepository();
  final coursRepository = CoursRepository();
  final motRepository = MotRepository();
  final motsCroisesRepository = MotsCroisesRepository();
  final miniJeuRepository = MiniJeuRepository();
  final mediaCoursRepository = MediaCoursRepository();
  final pageRepository = PageRepository();
  final objectifCoursRepository = ObjectifCoursRepository();

  // --- Test Objectif ---
  if (kDebugMode) {
    print('--- Test Objectif ---');
  }

// Récupérer tous les objectifs
  final allObjectifs = await objectifCoursRepository.getAll();
  if (kDebugMode) {
    print('Objectifs disponibles : ${allObjectifs.map((e) => e.description).toList()}');
  }

// Récupérer un objectif par ID
  final objectif = allObjectifs.first;
  final fetchedObjectif = await objectifCoursRepository.getById(objectif.id!);
  if (kDebugMode) {
    print('Objectif récupéré par ID : ${fetchedObjectif?.description}');
  }

// Supprimer un objectif
  await objectifCoursRepository.delete(objectif.id!);
  if (kDebugMode) {
    print('Objectif supprimé.');
  }


    // --- Test Mot ---
  if (kDebugMode) {
    print('--- Test Mot ---');
  }

  // Récupérer tous les mots
  final allMots = await motRepository.getAll();
  if (kDebugMode) {
    print('Mots disponibles : ${allMots.map((e) => e.mot).toList()}');
  }

  // Récupérer un mot par ID
  final mot = allMots.first;
  final fetchedMot = await motRepository.getById(mot.id!);
  if (kDebugMode) {
    print('Mot récupéré par ID : ${fetchedMot?.mot}');
  }

  // Supprimer un mot
  await motRepository.delete(mot.id!);
  if (kDebugMode) {
    print('Mot supprimé.');
  }

  // --- Test MotsCroises ---
  if (kDebugMode) {
    print('--- Test MotsCroises ---');
  }

  // Récupérer tous les mots croisés
  final allMotsCroises = await motsCroisesRepository.getAll();
  if (kDebugMode) {
    print(
      'Mots croisés disponibles : ${allMotsCroises.map((e) => e.tailleGrille).toList()}');
  }

  // Récupérer un mots croisés par ID
  final motsCroises = allMotsCroises.first;
  final fetchedMotsCroises =
      await motsCroisesRepository.getById(motsCroises.id!);
  if (kDebugMode) {
    print('Mots croisés récupérés par ID : ${fetchedMotsCroises?.tailleGrille}');
  }

  // Supprimer un mots croisés
  await motsCroisesRepository.delete(motsCroises.id!);
  if (kDebugMode) {
    print('Mots croisés supprimé.');
  }

  // --- Test MiniJeu ---
  if (kDebugMode) {
    print('--- Test MiniJeu ---');
  }

  // Récupérer tous les mini-jeux
  final allMiniJeux = await miniJeuRepository.getAll();
  if (kDebugMode) {
    print('Mini-jeux disponibles : ${allMiniJeux.map((e) => e.nom).toList()}');
  }

  // Récupérer un mini-jeu par ID
  final miniJeu = allMiniJeux.first;
  final fetchedMiniJeu = await miniJeuRepository.getById(miniJeu.id!);
  if (kDebugMode) {
    print('Mini-jeu récupéré par ID : ${fetchedMiniJeu?.nom}');
  }

  // Supprimer un mini-jeu
  await miniJeuRepository.delete(miniJeu.id!);
  if (kDebugMode) {
    print('Mini-jeu supprimé.');
  }

  // --- Test MediaCours ---
  if (kDebugMode) {
    print('--- Test MediaCours ---');
  }

  // Récupérer tous les médias
  final allMedias = await mediaCoursRepository.getAll();
  if (kDebugMode) {
    print('Médias disponibles : ${allMedias.map((e) => e.url).toList()}');
  }

  // Récupérer un média par ID
  final media = allMedias.first;
  final fetchedMedia = await mediaCoursRepository.getById(media.id!);
  if (kDebugMode) {
    print('Média récupéré par ID : ${fetchedMedia?.url}');
  }

  // Supprimer un média
  //await mediaCoursRepository.delete(media.id!);
  //print('Média supprimé.');

  // --- Test Page ---
  if (kDebugMode) {
    print('--- Test Page ---');
  }

// Récupérer toutes les pages
  final allPages = await pageRepository.getAll();
  if (kDebugMode) {
    print('Pages disponibles : ${allPages.map((e) => e.id).toList()}');
  }

// Récupérer une page par ID
  if (allPages.isNotEmpty) {
    final page = allPages.first;
    final fetchedPage = await pageRepository.getById(page.id!);
    if (kDebugMode) {
      print('Page récupérée par ID : ${fetchedPage?.id} liée au cours : ${fetchedPage?.idCours}');
    }

    // Supprimer une page
    //await pageRepository.delete(page.id!);
    //print('Page supprimée.');
  } else {
    if (kDebugMode) {
      print('Aucune page disponible pour le test.');
    }
  }

  // --- Test Cours ---
  if (kDebugMode) {
    print('--- Test Cours ---');
  }

  // Récupérer toutes les courss
  final allCours = await coursRepository.getAll();
  if (kDebugMode) {
    print('Cours disponibles : ${allCours.map((e) => e.titre).toList()}');
  }

  // Récupérer une cours par ID
  final cours = allCours.first;
  final fetchedCours = await coursRepository.getById(cours.id!);
  if (kDebugMode) {
    print('Cours récupérée par ID : ${fetchedCours?.titre}');
  }

  // méthode loadContenu(Cours cours)
  cours.pages = await pageRepository.getPagesByCourseId(cours.id!);
  if (kDebugMode) {
    print("Nombre de page récupéré : ${cours.pages?.length}");
  }

  for (int i=0; i<cours.pages!.length; i++) {
      cours.pages![i].medias = await mediaCoursRepository.getByPageId(cours.pages![i].id!);
      if (kDebugMode) {
        print(cours.pages![i].medias?.length);
      }
    }

  // Supprimer une cours
  await coursRepository.delete(cours.id!);
  if (kDebugMode) {
    print('Cours supprimée.');
  }
  // --- Test Module ---
  if (kDebugMode) {
    print('--- Test Module ---');
  }

  // Récupérer tous les module
  final allModulees = await moduleRepository.getAll();
  if (kDebugMode) {
    print('Module disponibles : ${allModulees.map((e) => e.titre).toList()}');
  }

  // Récupérer un module par ID
  final module = allModulees.first;
  final fetchedModule = await moduleRepository.getById(module.id!);
  if (kDebugMode) {
    print('Module récupéré par ID : ${fetchedModule?.titre}');
  }

  // Supprimer un module
  await moduleRepository.delete(module.id!);
  if (kDebugMode) {
    print('Module supprimé.');
  }
}
