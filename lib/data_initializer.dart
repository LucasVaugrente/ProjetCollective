import 'package:flutter/foundation.dart';
import 'package:seriouse_game/models/module.dart';
import 'package:seriouse_game/repositories/coursRepository.dart';

import 'package:seriouse_game/repositories/moduleRepository.dart';
import 'package:seriouse_game/repositories/minijeuRepository.dart';
import 'package:seriouse_game/repositories/mediaCoursRepository.dart';
import 'package:seriouse_game/repositories/objectifCoursRepository.dart';
import 'package:seriouse_game/repositories/pageRepository.dart';

import 'package:seriouse_game/repositories/QCM/QCMRepository.dart';

import 'DataBase/database_helper.dart';
import 'models/cours.dart';
import 'models/mediaCours.dart';
import 'models/objectifCours.dart';
import 'models/page.dart';

import 'models/QCM/qcm.dart';

import 'package:seriouse_game/ui/CoursSelectionne.dart';
import 'package:seriouse_game/ui/ModuleSelectionne.dart';

final moduleRepository = ModuleRepository();
final coursRepository = CoursRepository();
final miniJeuRepository = MiniJeuRepository();
final mediaCoursRepository = MediaCoursRepository();
final pageRepository = PageRepository();
final objectifCoursRepository = ObjectifCoursRepository();

final qcmRepo = QCMRepository();

Future<void> insertModule1() async {
  // Création du Module
  final module = Module(
      titre: 'Thématique 1',
      urlImg: 'lib/data/AppData/facto-societe.png',
      description:
      'Chaque citoyen a un rôle à jouer en matière de lutte contre la désinformation…');
  final moduleId = await moduleRepository.create(module);

  // Création du Cours
  Cours cours = Cours(
      idModule: moduleId,
      titre: 'Les sources d’informations',
      contenu: 'Comprendre et évaluer les sources d’information.');
  final coursId = await coursRepository.create(cours);

  // Ajout des Objectifs du Cours
  await objectifCoursRepository.create(ObjectifCours(
      idCours: coursId,
      description: 'Comprendre les différents types de sources d’information'));
  await objectifCoursRepository.create(ObjectifCours(
      idCours: coursId,
      description: 'Savoir évaluer la crédibilité d’une source'));
  await objectifCoursRepository.create(ObjectifCours(
      idCours: coursId,
      description: 'Identifier les signes de désinformation'));

  // Page 1
  Page page1 = Page(
      idCours: coursId,
      ordre: 1,
      description: "Qu'est-ce qu'une source d'information ?");
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

  // Page 2
  Page page2 = Page(
      idCours: coursId,
      ordre: 2,
      description: "Types de sources d'information");
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

  // Page 3
  Page page3 = Page(
      idCours: coursId,
      ordre: 3,
      description: "Comment vérifier la fiabilité d'une source ?");
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

  // ---------------------------------------------------------------------------
  // --- EXEMPLE DE QCM POUR TEST (À SUPPRIMER OU REMPLACER PLUS TARD) ---------
  // ---------------------------------------------------------------------------

  List<QCM> testQCMs = [
    QCM(
      id: 0, // ignoré car AUTOINCREMENT
      question:
      "Quel est le principal indicateur de la fiabilité d’une source d’information ?",
      reponses: [
        "Sa popularité sur les réseaux sociaux",
        "La vérifiabilité des informations par d’autres sources fiables",
        "Le nombre de commentaires sous l’article",
        "Le design du site web",
      ],
      soluce: 1,
      idCours: coursId,
    ),
    QCM(
      id: 0,
      question:
      "Quelle est la meilleure manière de vérifier une information trouvée en ligne ?",
      reponses: [
        "La partager immédiatement avec ses amis",
        "Consulter plusieurs sources fiables et vérifier la cohérence de l’information",
        "Faire confiance à la première source trouvée",
        "Vérifier si l’information est amusante avant de la croire",
      ],
      soluce: 1,
      idCours: coursId,
    ),
    QCM(
      id: 0,
      question: "Quel est un signe révélateur d’une fausse information ?",
      reponses: [
        "Elle provient d’un média reconnu et sérieux",
        "Elle utilise un ton sensationnaliste et manque de sources vérifiables",
        "Elle cite plusieurs experts et références",
        "Elle est reprise par plusieurs médias de confiance",
      ],
      soluce: 1,
      idCours: coursId,
    ),
  ];

  for (var qcm in testQCMs) {
    await qcmRepo.insert(qcm);
  }

  // --- Autres cours du module ---
  cours = Cours(
      idModule: moduleId,
      titre: 'Genres journalistiques',
      contenu: 'Découvrir les genres journalistiques.');
  final coursId2 = await coursRepository.create(cours);

  await objectifCoursRepository.create(
      ObjectifCours(idCours: coursId2, description: 'Les genres d\'information'));
  await objectifCoursRepository.create(
      ObjectifCours(idCours: coursId2, description: 'Les genres d\'opinion'));

  Page page4 = Page(
      idCours: coursId2,
      ordre: 1,
      description: "Quels sont les genres d'information ?",
      urlAudio: 'lib/data/AppData/Module1/Cours1/genre_d_information.mp3');
  int pageId4 = await pageRepository.create(page4);

  await mediaCoursRepository.create(MediaCours(
      idPage: pageId4,
      ordre: 1,
      url: 'lib/data/AppData/Module1/Cours1/genre_d_information.txt',
      type: 'text'));

  await mediaCoursRepository.create(MediaCours(
      idPage: pageId4,
      ordre: 2,
      url: 'lib/data/AppData/Module1/Cours1/genre_d_information.jpg',
      type: 'image',
      caption: 'Les genres d\'information'));

  await mediaCoursRepository.create(MediaCours(
      idPage: pageId4,
      ordre: 3,
      url: 'lib/data/AppData/Module1/Cours1/genre_d_information2.txt',
      type: 'text'));

  // Page 5
  Page page5 = Page(
      idCours: coursId2, ordre: 2, description: "Les genres d'opinion");
  int pageId5 = await pageRepository.create(page5);

  await mediaCoursRepository.create(MediaCours(
      idPage: pageId5,
      ordre: 1,
      url: 'lib/data/AppData/Module1/Cours1/genre_opinion.mp4',
      type: 'video'));

  // Autres cours
  await coursRepository.create(
      Cours(idModule: moduleId, titre: 'Réseaux sociaux', contenu: ''));
  await coursRepository.create(
      Cours(idModule: moduleId, titre: 'Désinformation/Mésinformation', contenu: ''));
}

Future<void> insertModule2() async {
  final module = Module(
      titre: 'Thématique 2',
      urlImg: 'lib/data/AppData/facto-societe.png',
      description:
      'Grâce aux technologies modernes, tout le monde peut diffuser des informations…');
  final moduleId = await moduleRepository.create(module);

  await coursRepository.create(
      Cours(idModule: moduleId, titre: 'Ethique professionnelle et personnelle', contenu: ''));
  await coursRepository.create(
      Cours(idModule: moduleId, titre: 'Journalisme et production de contenus', contenu: ''));
  await coursRepository.create(
      Cours(idModule: moduleId, titre: 'Risques économiques et sociétaux', contenu: ''));
  await coursRepository.create(
      Cours(idModule: moduleId, titre: 'EMI - Education aux médias et à l’information', contenu: ''));
}

Future<void> insertModule3() async {
  final module = Module(
      titre: 'Thématique 3',
      urlImg: 'lib/data/AppData/facto-societe.png',
      description:
      'Les journalistes sont des professionnels de l’information…');
  final moduleId = await moduleRepository.create(module);

  await coursRepository.create(
      Cours(idModule: moduleId, titre: 'Déontologie', contenu: ''));
  await coursRepository.create(
      Cours(idModule: moduleId, titre: 'Osint et Investigation numérique', contenu: ''));
  await coursRepository.create(
      Cours(idModule: moduleId, titre: 'SR et fact-checking', contenu: ''));
  await coursRepository.create(
      Cours(idModule: moduleId, titre: 'EMI - Education aux médias et à l’information', contenu: ''));
}

Future<void> insertModule4() async {
  final module = Module(
      titre: 'Pour aller plus loin',
      urlImg: 'lib/data/AppData/facto-societe.png',
      description:
      'Toutes les références et ressources en relation avec l\'EMI sont ici.');
  final moduleId = await moduleRepository.create(module);

  await coursRepository.create(
      Cours(idModule: moduleId, titre: 'Références bibliographiques', contenu: ''));
  await coursRepository.create(
      Cours(idModule: moduleId, titre: 'Ressources en ligne', contenu: ''));
}

Future<void> insertSampleData() async {
  await DatabaseHelper.instance.resetDatabase();

  await insertModule1();
  await insertModule2();
  await insertModule3();
  await insertModule4();

  // Init du singleton CoursSelectionne
  CoursSelectionne coursSelectionne = CoursSelectionne.instance;
  List<Cours> lstCours = await coursRepository.getAll();
  coursSelectionne.setCours(lstCours[0]);

  // Init du singleton ModuleSelectionne
  ModuleSelectionne moduleSelectionne = ModuleSelectionne.instance;
  List<Module> lstModule = await moduleRepository.getAll();
  moduleSelectionne.moduleSelectionne = lstModule[0];

  if (kDebugMode) {
    print('Toutes les données d\'exemple ont été insérées avec succès.');
  }
}
