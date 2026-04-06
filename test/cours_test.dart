import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:factoscope/services/api_service.dart';
import 'package:factoscope/repositories/cours_repository.dart';
import 'package:factoscope/models/cours.dart';

// Génère MockApiService et MockCoursRepository dans cours_test.mocks.dart
@GenerateMocks([ApiService, CoursRepository])
import 'cours_test.mocks.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers — constructeurs de fixtures
// ─────────────────────────────────────────────────────────────────────────────

ModuleDistant _module({int id = 1, String titre = 'Module test'}) =>
    ModuleDistant(id: id, titre: titre, description: 'Description test');

CoursDistant _coursDistant({
  int id = 10,
  int idModule = 1,
  String titre = 'Chapitre 1',
}) =>
    CoursDistant(
      id: id,
      titre: titre,
      description: '',
      contenu: '',
      idModule: idModule,
    );

Cours _coursLocal({
  int? id,
  int idModule = 1,
  String titre = 'Chapitre 1',
}) =>
    Cours(
      id: id,
      idModule: idModule,
      titre: titre,
      contenu: '',
      description: '',
    );

// ─────────────────────────────────────────────────────────────────────────────
// Classe utilitaire qui expose la logique pure de AllCoursView
// (sans Flutter/Widget) pour pouvoir la tester en isolation.
// ─────────────────────────────────────────────────────────────────────────────

/// Reproduit uniquement la logique métier extraite de _AllCoursViewState.
/// Injecter les dépendances permet de les mocker dans les tests.
class ModuleLogic {
  final ApiService apiService;
  final CoursRepository coursRepository;

  List<String> titresModulesTelecharges = [];
  List<ModuleDistant> modulesDistants = [];
  final Set<int> modulesAvecMiseAJour = {};

  ModuleLogic({required this.apiService, required this.coursRepository});

  // ── Initialisation ────────────────────────────────────────────────────────

  Future<void> chargerModulesTelecharges() async {
    final coursLocaux = await coursRepository.getAll();
    titresModulesTelecharges =
        coursLocaux.map((c) => c.idModule.toString()).toSet().toList();
  }

  Future<void> chargerModulesDistants() async {
    modulesDistants = await apiService.getModulesDisponibles();
  }

  // ── Logique pure ──────────────────────────────────────────────────────────

  bool estModuleTelecharge(int moduleId) =>
      titresModulesTelecharges.contains(moduleId.toString());

  /// Retourne les modules triés : téléchargés en premier, puis disponibles.
  List<_ModuleItem> get listeUnifiee {
    final telecharges = <_ModuleItem>[];
    final nonTelecharges = <_ModuleItem>[];

    for (final module in modulesDistants) {
      if (estModuleTelecharge(module.id)) {
        telecharges.add(_ModuleItem(
          module: module,
          estTelecharge: true,
          aMiseAJourDisponible: modulesAvecMiseAJour.contains(module.id),
        ));
      } else {
        nonTelecharges.add(_ModuleItem(module: module, estTelecharge: false));
      }
    }

    return [...telecharges, ...nonTelecharges];
  }

  /// Détecte les modules dont des chapitres distants sont absents localement.
  Future<void> detecterMisesAJour() async {
    modulesAvecMiseAJour.clear();
    for (final module in modulesDistants) {
      if (!estModuleTelecharge(module.id)) continue;
      final distants = await apiService.getCoursDistantsDuModule(module.id);
      final locaux = await coursRepository.getCoursesByModuleId(module.id);
      final titresLocaux =
          locaux.map((c) => c.titre.trim().toLowerCase()).toSet();
      final nbNouveaux = distants
          .where((d) => !titresLocaux.contains(d.titre.trim().toLowerCase()))
          .length;
      if (nbNouveaux > 0) modulesAvecMiseAJour.add(module.id);
    }
  }

  /// Renvoie uniquement les cours distants absents localement pour un module.
  Future<List<CoursDistant>> nouveauxCoursPourModule(
      ModuleDistant module) async {
    final distants = await apiService.getCoursDistantsDuModule(module.id);
    final locaux = await coursRepository.getCoursesByModuleId(module.id);
    final titresLocaux =
        locaux.map((c) => c.titre.trim().toLowerCase()).toSet();
    return distants
        .where((d) => !titresLocaux.contains(d.titre.trim().toLowerCase()))
        .toList();
  }
}

class _ModuleItem {
  final ModuleDistant module;
  final bool estTelecharge;
  final bool aMiseAJourDisponible;

  _ModuleItem({
    required this.module,
    required this.estTelecharge,
    this.aMiseAJourDisponible = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── 1. Parsing des modèles JSON (sans mock) ────────────────────────────────

  group('CoursDistant.fromJson', () {
    test('parse correctement un JSON valide', () {
      final json = {
        'id': 42,
        'titre': 'Introduction',
        'description': 'Desc',
        'contenu': 'Contenu',
        'id_module': 5,
      };
      final cours = CoursDistant.fromJson(json);

      expect(cours.id, 42);
      expect(cours.titre, 'Introduction');
      expect(cours.idModule, 5);
    });

    test('utilise des valeurs par défaut quand les champs sont null', () {
      final json = {'id': 1, 'id_module': 2};
      final cours = CoursDistant.fromJson(json);

      expect(cours.titre, '');
      expect(cours.description, '');
      expect(cours.contenu, '');
    });
  });

  group('ModuleDistant.fromJson', () {
    test('parse correctement un JSON valide', () {
      final json = {'id': 3, 'titre': 'Anatomie', 'description': 'Desc'};
      final module = ModuleDistant.fromJson(json);

      expect(module.id, 3);
      expect(module.titre, 'Anatomie');
    });

    test('gère les titres null', () {
      final json = {'id': 3};
      final module = ModuleDistant.fromJson(json);

      expect(module.titre, '');
      expect(module.description, '');
    });
  });

  group('QcmDistant.fromJson', () {
    test('parse correctement un QCM complet', () {
      final json = {
        'id': 1,
        'question': 'Quelle est la capitale ?',
        'rep1': 'Paris',
        'rep2': 'Lyon',
        'rep3': 'Marseille',
        'rep4': 'Bordeaux',
        'soluce': 1,
        'id_cours': 10,
      };
      final qcm = QcmDistant.fromJson(json);

      expect(qcm.question, 'Quelle est la capitale ?');
      expect(qcm.soluce, 1);
      expect(qcm.idCours, 10);
    });

    test('soluce vaut 1 par défaut si null', () {
      final json = {
        'id': 1,
        'question': 'Q ?',
        'rep1': 'A',
        'rep2': 'B',
        'rep3': 'C',
        'rep4': 'D',
        'id_cours': 1,
      };
      final qcm = QcmDistant.fromJson(json);
      expect(qcm.soluce, 1);
    });
  });

  group('ClozeDistant.fromJson', () {
    test('parse correctement une question Cloze', () {
      final json = {
        'id': 5,
        'texte': 'Le cœur a ___ cavités.',
        'reponse1': '2',
        'reponse2': '4',
        'reponse3': '6',
        'reponse4': '8',
        'numero_reponse_correcte': 2,
        'id_cours': 7,
      };
      final cloze = ClozeDistant.fromJson(json);

      expect(cloze.texte, 'Le cœur a ___ cavités.');
      expect(cloze.numeroReponseCorrecte, 2);
      expect(cloze.explication, isNull);
    });
  });

  // ── 2. Logique estModuleTelecharge ─────────────────────────────────────────

  group('estModuleTelecharge', () {
    late MockApiService mockApi;
    late MockCoursRepository mockRepo;
    late ModuleLogic logic;

    setUp(() {
      mockApi = MockApiService();
      mockRepo = MockCoursRepository();
      logic = ModuleLogic(apiService: mockApi, coursRepository: mockRepo);
    });

    test('retourne true quand le module est présent localement', () {
      logic.titresModulesTelecharges = ['1', '3'];
      expect(logic.estModuleTelecharge(1), isTrue);
      expect(logic.estModuleTelecharge(3), isTrue);
    });

    test('retourne false quand le module est absent', () {
      logic.titresModulesTelecharges = ['2'];
      expect(logic.estModuleTelecharge(1), isFalse);
    });

    test('retourne false quand la liste est vide', () {
      logic.titresModulesTelecharges = [];
      expect(logic.estModuleTelecharge(1), isFalse);
    });
  });

  // ── 3. chargerModulesTelecharges ───────────────────────────────────────────

  group('chargerModulesTelecharges', () {
    late MockApiService mockApi;
    late MockCoursRepository mockRepo;
    late ModuleLogic logic;

    setUp(() {
      mockApi = MockApiService();
      mockRepo = MockCoursRepository();
      logic = ModuleLogic(apiService: mockApi, coursRepository: mockRepo);
    });

    test('renseigne les IDs de modules à partir des cours locaux', () async {
      when(mockRepo.getAll()).thenAnswer((_) async => [
            _coursLocal(idModule: 1),
            _coursLocal(idModule: 2),
            _coursLocal(idModule: 2), // doublon intentionnel
          ]);

      await logic.chargerModulesTelecharges();

      // Le doublon est dédupliqué (toSet)
      expect(logic.titresModulesTelecharges, containsAll(['1', '2']));
      expect(logic.titresModulesTelecharges.length, 2);
    });

    test('liste vide si aucun cours local', () async {
      when(mockRepo.getAll()).thenAnswer((_) async => []);
      await logic.chargerModulesTelecharges();
      expect(logic.titresModulesTelecharges, isEmpty);
    });
  });

  // ── 4. listeUnifiee ────────────────────────────────────────────────────────

  group('listeUnifiee', () {
    late MockApiService mockApi;
    late MockCoursRepository mockRepo;
    late ModuleLogic logic;

    setUp(() {
      mockApi = MockApiService();
      mockRepo = MockCoursRepository();
      logic = ModuleLogic(apiService: mockApi, coursRepository: mockRepo);
    });

    test('les modules téléchargés apparaissent en premier', () {
      logic.modulesDistants = [
        _module(id: 1, titre: 'A'),
        _module(id: 2, titre: 'B'),
        _module(id: 3, titre: 'C'),
      ];
      // Seul le module 2 est téléchargé
      logic.titresModulesTelecharges = ['2'];

      final liste = logic.listeUnifiee;

      expect(liste.first.module.id, 2); // téléchargé en tête
      expect(liste.first.estTelecharge, isTrue);
      expect(liste[1].estTelecharge, isFalse);
      expect(liste[2].estTelecharge, isFalse);
    });

    test('liste vide si aucun module distant', () {
      logic.modulesDistants = [];
      expect(logic.listeUnifiee, isEmpty);
    });

    test('tous non téléchargés si titresModulesTelecharges est vide', () {
      logic.modulesDistants = [_module(id: 1), _module(id: 2)];
      logic.titresModulesTelecharges = [];

      final liste = logic.listeUnifiee;
      expect(liste.every((i) => !i.estTelecharge), isTrue);
    });

    test('badge miseAJour positionné correctement', () {
      logic.modulesDistants = [_module(id: 1), _module(id: 2)];
      logic.titresModulesTelecharges = ['1', '2'];
      logic.modulesAvecMiseAJour.add(2);

      final liste = logic.listeUnifiee;
      final item2 = liste.firstWhere((i) => i.module.id == 2);
      expect(item2.aMiseAJourDisponible, isTrue);

      final item1 = liste.firstWhere((i) => i.module.id == 1);
      expect(item1.aMiseAJourDisponible, isFalse);
    });
  });

  // ── 5. detecterMisesAJour ─────────────────────────────────────────────────

  group('detecterMisesAJour', () {
    late MockApiService mockApi;
    late MockCoursRepository mockRepo;
    late ModuleLogic logic;

    setUp(() {
      mockApi = MockApiService();
      mockRepo = MockCoursRepository();
      logic = ModuleLogic(apiService: mockApi, coursRepository: mockRepo);
    });

    test('détecte un nouveau chapitre absent localement', () async {
      final module = _module(id: 1);
      logic.modulesDistants = [module];
      logic.titresModulesTelecharges = ['1'];

      when(mockApi.getCoursDistantsDuModule(1)).thenAnswer((_) async => [
            _coursDistant(titre: 'Chapitre 1'),
            _coursDistant(titre: 'Chapitre 2'), // nouveau
          ]);
      when(mockRepo.getCoursesByModuleId(1))
          .thenAnswer((_) async => [_coursLocal(titre: 'Chapitre 1')]);

      await logic.detecterMisesAJour();

      expect(logic.modulesAvecMiseAJour, contains(1));
    });

    test('ne signale pas de mise à jour si tout est déjà local', () async {
      final module = _module(id: 1);
      logic.modulesDistants = [module];
      logic.titresModulesTelecharges = ['1'];

      when(mockApi.getCoursDistantsDuModule(1))
          .thenAnswer((_) async => [_coursDistant(titre: 'Chapitre 1')]);
      when(mockRepo.getCoursesByModuleId(1))
          .thenAnswer((_) async => [_coursLocal(titre: 'Chapitre 1')]);

      await logic.detecterMisesAJour();

      expect(logic.modulesAvecMiseAJour, isEmpty);
    });

    test('ignore les modules non téléchargés', () async {
      final module = _module(id: 1);
      logic.modulesDistants = [module];
      logic.titresModulesTelecharges = []; // pas téléchargé

      // getCoursDistantsDuModule ne doit pas être appelé
      await logic.detecterMisesAJour();

      verifyNever(mockApi.getCoursDistantsDuModule(any));
      expect(logic.modulesAvecMiseAJour, isEmpty);
    });

    test('comparaison insensible à la casse et aux espaces', () async {
      final module = _module(id: 1);
      logic.modulesDistants = [module];
      logic.titresModulesTelecharges = ['1'];

      when(mockApi.getCoursDistantsDuModule(1))
          .thenAnswer((_) async => [_coursDistant(titre: '  Chapitre 1  ')]);
      when(mockRepo.getCoursesByModuleId(1))
          .thenAnswer((_) async => [_coursLocal(titre: 'CHAPITRE 1')]);

      await logic.detecterMisesAJour();

      // Même titre après trim+toLowerCase → pas de mise à jour
      expect(logic.modulesAvecMiseAJour, isEmpty);
    });

    test('efface les anciennes mises à jour avant de recalculer', () async {
      logic.modulesAvecMiseAJour.add(99); // résidu d'un appel précédent
      logic.modulesDistants = [];
      logic.titresModulesTelecharges = [];

      await logic.detecterMisesAJour();

      expect(logic.modulesAvecMiseAJour, isEmpty);
    });
  });

  // ── 6. nouveauxCoursPourModule ────────────────────────────────────────────

  group('nouveauxCoursPourModule', () {
    late MockApiService mockApi;
    late MockCoursRepository mockRepo;
    late ModuleLogic logic;

    setUp(() {
      mockApi = MockApiService();
      mockRepo = MockCoursRepository();
      logic = ModuleLogic(apiService: mockApi, coursRepository: mockRepo);
    });

    test('retourne uniquement les cours distants manquants', () async {
      final module = _module(id: 1);

      when(mockApi.getCoursDistantsDuModule(1)).thenAnswer((_) async => [
            _coursDistant(id: 10, titre: 'Chapitre 1'),
            _coursDistant(id: 11, titre: 'Chapitre 2'),
            _coursDistant(id: 12, titre: 'Chapitre 3'),
          ]);
      when(mockRepo.getCoursesByModuleId(1)).thenAnswer((_) async => [
            _coursLocal(titre: 'Chapitre 1'),
            _coursLocal(titre: 'Chapitre 2'),
          ]);

      final nouveaux = await logic.nouveauxCoursPourModule(module);

      expect(nouveaux.length, 1);
      expect(nouveaux.first.titre, 'Chapitre 3');
    });

    test('retourne une liste vide si rien de nouveau', () async {
      final module = _module(id: 1);

      when(mockApi.getCoursDistantsDuModule(1))
          .thenAnswer((_) async => [_coursDistant(titre: 'Chapitre 1')]);
      when(mockRepo.getCoursesByModuleId(1))
          .thenAnswer((_) async => [_coursLocal(titre: 'Chapitre 1')]);

      final nouveaux = await logic.nouveauxCoursPourModule(module);
      expect(nouveaux, isEmpty);
    });

    test('retourne tous les cours si le module n\'a aucun cours local',
        () async {
      final module = _module(id: 1);

      when(mockApi.getCoursDistantsDuModule(1)).thenAnswer((_) async => [
            _coursDistant(id: 10, titre: 'Chapitre 1'),
            _coursDistant(id: 11, titre: 'Chapitre 2'),
          ]);
      when(mockRepo.getCoursesByModuleId(1)).thenAnswer((_) async => []);

      final nouveaux = await logic.nouveauxCoursPourModule(module);
      expect(nouveaux.length, 2);
    });
  });

  // ── 7. chargerModulesDistants ─────────────────────────────────────────────

  group('chargerModulesDistants', () {
    late MockApiService mockApi;
    late MockCoursRepository mockRepo;
    late ModuleLogic logic;

    setUp(() {
      mockApi = MockApiService();
      mockRepo = MockCoursRepository();
      logic = ModuleLogic(apiService: mockApi, coursRepository: mockRepo);
    });

    test('stocke les modules renvoyés par l\'API', () async {
      when(mockApi.getModulesDisponibles()).thenAnswer((_) async => [
            _module(id: 1, titre: 'Anatomie'),
            _module(id: 2, titre: 'Physiologie'),
          ]);

      await logic.chargerModulesDistants();

      expect(logic.modulesDistants.length, 2);
      expect(logic.modulesDistants.first.titre, 'Anatomie');
    });

    test('laisse la liste vide si l\'API retourne []', () async {
      when(mockApi.getModulesDisponibles()).thenAnswer((_) async => []);
      await logic.chargerModulesDistants();
      expect(logic.modulesDistants, isEmpty);
    });

    test('propage l\'exception si l\'API échoue', () async {
      when(mockApi.getModulesDisponibles())
          .thenThrow(Exception('Réseau indisponible'));

      expect(
        () async => await logic.chargerModulesDistants(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
