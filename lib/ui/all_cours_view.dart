import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/models/module.dart';
import 'package:factoscope/repositories/cours_repository.dart';
import 'package:factoscope/repositories/page_repository.dart';
import 'package:factoscope/models/page.dart';
import 'package:factoscope/ui/module_selectionne.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../config.dart';
import 'api_service.dart';
import '../models/QCM/qcm.dart';
import '../models/Cloze/cloze_page.dart';
import '../repositories/QCM/qcm_repository.dart';
import '../repositories/Cloze/cloze_repository.dart';

class AllCoursView extends StatefulWidget {
  const AllCoursView({super.key});

  @override
  State<AllCoursView> createState() => _AllCoursViewState();
}

class _AllCoursViewState extends State<AllCoursView> {
  final CoursRepository _coursRepository = CoursRepository();
  final ApiService _apiService = ApiService();

  // Modules récupérés depuis l'API distante
  List<ModuleDistant> _modulesDistants = [];

  // Titres des modules dont au moins un cours est téléchargé localement
  List<String> _titresModulesTelecharges = [];

  bool _isLoading = true;
  bool _apiConnectee = false;

  // IDs des modules en cours de téléchargement
  final Set<int> _modulesEnCoursDeTelechargement = {};

  @override
  void initState() {
    super.initState();
    _initialiserPage();
  }

  Future<void> _initialiserPage() async {
    setState(() => _isLoading = true);
    await _verifierConnexionApi();
    await _chargerModulesTelecharges();
    if (_apiConnectee) await _chargerModulesDistants();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _verifierConnexionApi() async {
    final connectee = await _apiService.testConnection();
    if (mounted) setState(() => _apiConnectee = connectee);
  }

  /// Un module est considéré "téléchargé" si au moins un cours avec cet id_module existe localement
  Future<void> _chargerModulesTelecharges() async {
    try {
      final coursLocaux = await _coursRepository.getAll();
      // On récupère les titres de modules distants déjà en local via id_module
      // Pour affichage, on garde une liste des idModule présents localement
      if (mounted) {
        setState(() {
          _titresModulesTelecharges =
              coursLocaux.map((c) => c.idModule.toString()).toSet().toList();
        });
      }
    } catch (e) {
      if (kDebugMode) print('Erreur chargement cours locaux: $e');
    }
  }

  Future<void> _chargerModulesDistants() async {
    try {
      final modules = await _apiService.getModulesDisponibles();
      if (mounted) setState(() => _modulesDistants = modules);
    } catch (e) {
      if (kDebugMode) print('Erreur chargement modules distants: $e');
    }
  }

  Future<void> _rafraichir() async {
    setState(() => _isLoading = true);
    await _verifierConnexionApi();
    await _chargerModulesTelecharges();
    if (_apiConnectee) await _chargerModulesDistants();
    if (mounted) setState(() => _isLoading = false);
  }

  bool _estModuleTelecharge(int moduleId) =>
      _titresModulesTelecharges.contains(moduleId.toString());

  /// Télécharge tous les cours d'un module et les sauvegarde localement
  Future<void> _telechargerModule(ModuleDistant module) async {
    if (_modulesEnCoursDeTelechargement.contains(module.id)) return;
    if (_estModuleTelecharge(module.id)) return;

    setState(() => _modulesEnCoursDeTelechargement.add(module.id));

    try {
      // Récupère tous les cours distants liés à ce module
      final coursDistants =
          await _apiService.getCoursDistantsDuModule(module.id);

      if (coursDistants.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ce module ne contient aucun cours.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Télécharge chaque cours du module
      for (final coursDistant in coursDistants) {
        final coursComplet = await _apiService.getCoursComplet(coursDistant.id);
        await _sauvegarderCoursLocalement(coursComplet,
            titreModule: module.titre);
      }

      await _chargerModulesTelecharges();

      if (mounted) {
        setState(() => _titresModulesTelecharges.add(module.id.toString()));
        _afficherPopupSucces(module.titre);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement : $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _modulesEnCoursDeTelechargement.remove(module.id));
      }
    }
  }

  /// Télécharge tous les modules disponibles non encore téléchargés
  Future<void> _toutTelecharger() async {
    final aTelechargement =
        _modulesDistants.where((m) => !_estModuleTelecharge(m.id)).toList();

    if (aTelechargement.isEmpty) return;

    setState(() {
      for (final m in aTelechargement) {
        _modulesEnCoursDeTelechargement.add(m.id);
      }
    });

    int succes = 0;
    final List<String> erreurs = [];

    for (final module in aTelechargement) {
      try {
        final coursDistants =
            await _apiService.getCoursDistantsDuModule(module.id);
        for (final coursDistant in coursDistants) {
          final coursComplet =
              await _apiService.getCoursComplet(coursDistant.id);
          await _sauvegarderCoursLocalement(coursComplet,
              titreModule: module.titre);
        }
        if (mounted) {
          setState(() => _titresModulesTelecharges.add(module.id.toString()));
        }
        succes++;
      } catch (e) {
        erreurs.add(module.titre);
      } finally {
        if (mounted) {
          setState(() => _modulesEnCoursDeTelechargement.remove(module.id));
        }
      }
    }

    await _chargerModulesTelecharges();

    if (!mounted) return;

    if (erreurs.isEmpty) {
      _afficherPopupToutTelecharge(succes);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$succes module(s) téléchargé(s). Échec : ${erreurs.join(', ')}',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ─── Sauvegarde locale (inchangée par rapport à l'ancien all_cours_view) ─────

  Future<void> _sauvegarderCoursLocalement(
    CoursComplet coursComplet, {
    required String titreModule,
  }) async {
    if (kDebugMode) {
      print(
          '📚 Début sauvegarde cours: "${coursComplet.cours.titre}" (module ${coursComplet.cours.idModule})');
    }
    final pageRepository = PageRepository();

    final coursLocal = Cours(
      idModule: coursComplet.cours.idModule,
      titre: coursComplet.cours.titre,
      contenu: coursComplet.cours.contenu,
      description: coursComplet.cours.description,
    );

    final coursIdLocal = await _coursRepository.create(coursLocal);
    if (kDebugMode) print('✅ Cours créé en BDD locale avec id: $coursIdLocal');

    final dossierCours = await _creerDossierCours(
      titreModule: titreModule,
      titreCours: coursComplet.cours.titre,
    );

    // Médias
    final List<String> tousLesMedias = [];
    for (final page in coursComplet.pages) {
      if (page.medias.isNotEmpty) {
        final noms = page.medias
            .split('@')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        tousLesMedias.addAll(noms);
      }
    }

    await _telechargerTousLesMediasDuCours(
      titreModule: titreModule,
      titreCours: coursComplet.cours.titre,
      nomsMedias: tousLesMedias,
      dossierCours: dossierCours,
    );

    for (final pageDistante in coursComplet.pages) {
      final List<MediaItem> mediasList = [];

      if (pageDistante.medias.isNotEmpty) {
        final noms = pageDistante.medias
            .split('@')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        for (int i = 0; i < noms.length; i++) {
          final nomFichier = noms[i];
          String typeMedia = 'text';
          final ext = nomFichier.split('.').last.toLowerCase();
          if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext)) {
            typeMedia = 'image';
          } else if (['mp4', 'webm', 'avi'].contains(ext)) {
            typeMedia = 'video';
          } else if (['mp3', 'wav', 'ogg'].contains(ext)) {
            typeMedia = 'audio';
          }

          final cheminLocal = path.join(dossierCours.path, nomFichier);
          mediasList.add(MediaItem(
            ordre: i + 1,
            url: cheminLocal,
            type: typeMedia,
            caption: '',
          ));
        }
      }

      final pageLocale = Page(
        idCours: coursIdLocal,
        description: pageDistante.description,
        contenu: pageDistante.contenu,
        medias: mediasList,
      );

      await pageRepository.create(pageLocale);
    }

    await _sauvegarderQcm(
      coursIdDistant: coursComplet.cours.id,
      coursIdLocal: coursIdLocal,
    );
    await _sauvegarderCloze(
      coursIdDistant: coursComplet.cours.id,
      coursIdLocal: coursIdLocal,
    );
  }

  Future<void> _sauvegarderQcm(
      {required int coursIdDistant, required int coursIdLocal}) async {
    try {
      final qcmDistants = await _apiService.getQcmDuCours(coursIdDistant);
      if (qcmDistants.isEmpty) return;
      final qcmRepository = QCMRepository();
      for (final q in qcmDistants) {
        await qcmRepository.insert(QCM(
          question: q.question,
          rep1: q.rep1,
          rep2: q.rep2,
          rep3: q.rep3,
          rep4: q.rep4,
          soluce: q.soluce,
          idCours: coursIdLocal,
        ));
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Erreur sauvegarde QCM: $e');
    }
  }

  Future<void> _sauvegarderCloze(
      {required int coursIdDistant, required int coursIdLocal}) async {
    try {
      final clozeDistants = await _apiService.getClozesDuCours(coursIdDistant);
      if (clozeDistants.isEmpty) return;
      final clozeRepository = ClozeRepository();
      for (final c in clozeDistants) {
        await clozeRepository.insert(ClozeQuestion(
          phrase: c.texte,
          rep1: c.reponse1,
          rep2: c.reponse2,
          rep3: c.reponse3,
          rep4: c.reponse4,
          soluce: c.numeroReponseCorrecte,
          idCours: coursIdLocal,
        ));
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Erreur sauvegarde Cloze: $e');
    }
  }

  Future<Directory> _creerDossierCours({
    required String titreModule, // ← titre au lieu de idModule
    required String titreCours,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dossier = Directory(
      path.join(appDir.path, 'AppData', titreModule, titreCours),
    );
    if (!await dossier.exists()) await dossier.create(recursive: true);
    return dossier;
  }

  Future<void> _telechargerTousLesMediasDuCours({
    required String titreModule,
    required String titreCours,
    required List<String> nomsMedias,
    required Directory dossierCours,
  }) async {
    if (nomsMedias.isEmpty) return;

    final futures = nomsMedias.map((nomFichier) async {
      final fichier = File(path.join(dossierCours.path, nomFichier));
      if (await fichier.exists()) return;
      try {
        // Construire l'URI segment par segment pour éviter le double encodage
        final uri = Uri(
          scheme: Uri.parse(AppConfig.urlMedias).scheme,
          host: Uri.parse(AppConfig.urlMedias).host,
          pathSegments: [
            ...Uri.parse(AppConfig.urlMedias)
                .pathSegments
                .where((s) => s.isNotEmpty),
            'AppData',
            titreModule,
            titreCours,
            nomFichier,
          ],
        );
        if (kDebugMode) print('⬇️ Téléchargement: $uri');
        final response = await http.get(uri);
        if (kDebugMode) print('📡 Status $nomFichier: ${response.statusCode}');
        if (response.statusCode == 200) {
          await fichier.writeAsBytes(response.bodyBytes);
          if (kDebugMode) print('✅ Sauvegardé: $nomFichier');
        }
      } catch (e) {
        if (kDebugMode) print('❌ Erreur média $nomFichier: $e');
      }
    });

    await Future.wait(futures);
  }

  // ─── Popups ──────────────────────────────────────────────────────────────────

  void _afficherPopupSucces(String titreModule) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 20),
              const Text(
                'Module téléchargé !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '"$titreModule"',
                style:
                    const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tous les chapitres ont été ajoutés à votre bibliothèque',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('OK', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _afficherPopupToutTelecharge(int nb) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
                child:
                    const Icon(Icons.cloud_done, color: Colors.white, size: 46),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tout est téléchargé !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '$nb module${nb > 1 ? 's' : ''} ajouté${nb > 1 ? 's' : ''} à votre bibliothèque',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('OK', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Liste unifiée modules ────────────────────────────────────────────────────

  List<_ModuleItem> get _listeUnifiee {
    final List<_ModuleItem> telecharges = [];
    final List<_ModuleItem> nonTelecharges = [];

    for (final module in _modulesDistants) {
      if (_estModuleTelecharge(module.id)) {
        telecharges.add(_ModuleItem(module: module, estTelecharge: true));
      } else {
        nonTelecharges.add(_ModuleItem(module: module, estTelecharge: false));
      }
    }

    return [...telecharges, ...nonTelecharges];
  }

  // ─── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final liste = _listeUnifiee;
    final nbTelecharges = liste.where((i) => i.estTelecharge).length;
    final nbDisponibles = liste.where((i) => !i.estTelecharge).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Modules'),
        centerTitle: true,
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.cloud,
                color: _apiConnectee ? Colors.green : Colors.grey),
            onPressed: _rafraichir,
            tooltip: _apiConnectee
                ? 'Connecté — Rafraîchir'
                : 'Non connecté — Réessayer',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _rafraichir,
              child: liste.isEmpty
                  ? _buildEtatVide()
                  : CustomScrollView(
                      slivers: [
                        if (nbTelecharges > 0)
                          _buildSectionHeader(
                            'Téléchargés',
                            '$nbTelecharges module${nbTelecharges > 1 ? 's' : ''}',
                            Colors.black87,
                          ),
                        if (!_apiConnectee && nbTelecharges > 0)
                          _buildBanniereHorsLigne(),
                        SliverPadding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = liste[index];
                                final estPremierNonTelecharge =
                                    !item.estTelecharge &&
                                        (index == 0 ||
                                            liste[index - 1].estTelecharge);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (estPremierNonTelecharge) ...[
                                      if (nbTelecharges > 0)
                                        const SizedBox(height: 8),
                                      _buildSectionLabel(
                                        'Disponibles en ligne',
                                        '$nbDisponibles module${nbDisponibles > 1 ? 's' : ''}',
                                      ),
                                    ],
                                    _buildModuleCard(item),
                                  ],
                                );
                              },
                              childCount: liste.length,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  Widget _buildSectionHeader(String titre, String sousTitre, Color couleur) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
        child: Row(
          children: [
            Text(titre,
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, color: couleur)),
            const SizedBox(width: 8),
            Text(sousTitre,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String titre, String sousTitre) {
    final bool toutEnCours = _modulesEnCoursDeTelechargement.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
      child: Row(
        children: [
          Text(titre,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(width: 8),
          Text(sousTitre,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const Spacer(),
          toutEnCours
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TextButton.icon(
                  onPressed: _toutTelecharger,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Tout télécharger',
                      style: TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(_ModuleItem item) {
    final enTelechargement =
        _modulesEnCoursDeTelechargement.contains(item.module.id);
    const couleurAccent = Color.fromRGBO(252, 179, 48, 1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: item.estTelecharge ? 2 : 1,
      color: item.estTelecharge ? Colors.white : Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (item.estTelecharge) {
            // Naviguer vers la liste des cours du module
            ModuleSelectionne.instance.changeModule(
              Module(
                id: item.module.id,
                titre: item.module.titre,
                description: item.module.description,
                urlImg: '',
              ),
            );
            GoRouter.of(context).push('/list_cours');
          } else if (!enTelechargement) {
            _telechargerModule(item.module);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icône module
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item.estTelecharge ? couleurAccent : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.folder_open,
                  color: item.estTelecharge ? Colors.white : Colors.grey[500],
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              // Titre + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.module.titre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: item.estTelecharge
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                    ),
                    if (item.module.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.module.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: item.estTelecharge
                              ? Colors.black54
                              : Colors.grey[400],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Action droite
              if (item.estTelecharge)
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey)
              else if (enTelechargement)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(Icons.download_outlined,
                    color: Colors.grey[500], size: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEtatVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _apiConnectee
                ? 'Aucun module disponible'
                : 'Aucun module téléchargé\net non connecté à internet',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _rafraichir,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildBanniereHorsLigne() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.grey[500], size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Connectez-vous à internet pour télécharger d\'autres modules.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Data classes ─────────────────────────────────────────────────────────────

class _ModuleItem {
  final ModuleDistant module;
  final bool estTelecharge;

  _ModuleItem({required this.module, required this.estTelecharge});
}
