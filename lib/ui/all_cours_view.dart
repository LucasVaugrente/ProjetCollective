import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/repositories/cours_repository.dart';
import 'package:factoscope/repositories/page_repository.dart';
import 'package:factoscope/models/page.dart';
import 'package:factoscope/ui/cours_selectionne.dart';
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

  List<Cours> _coursLocaux = [];
  List<CoursDistant> _coursDistants = [];
  bool _isLoading = true;
  bool _apiConnectee = false;
  final Set<int> _coursEnCoursDeTelechargement = {};
  List<String> _titresTelecharges = [];

  @override
  void initState() {
    super.initState();
    _initialiserPage();
  }

  Future<void> _initialiserPage() async {
    setState(() => _isLoading = true);

    await _verifierConnexionApi();
    await _chargerCoursLocaux();

    if (_apiConnectee) {
      await _chargerCoursDistants();
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _verifierConnexionApi() async {
    final connectee = await _apiService.testConnection();
    _apiConnectee = connectee;
    if (mounted) setState(() {});
  }

  Future<void> _chargerCoursLocaux() async {
    try {
      final cours = await _coursRepository.getAll();
      if (mounted) {
        setState(() {
          _coursLocaux = cours;
          _titresTelecharges = cours.map((c) => c.titre).toList();
        });
      }
    } catch (e) {
      if (kDebugMode) print('Erreur chargement cours locaux: $e');
    }
  }

  Future<void> _chargerCoursDistants() async {
    try {
      final distants = await _apiService.getCoursDisponibles();
      if (mounted) setState(() => _coursDistants = distants);
    } catch (e) {
      if (kDebugMode) print('Erreur chargement cours distants: $e');
    }
  }

  Future<void> _rafraichir() async {
    setState(() => _isLoading = true);
    await _verifierConnexionApi();
    await _chargerCoursLocaux();
    if (_apiConnectee) await _chargerCoursDistants();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _telechargerCours(CoursDistant cours) async {
    setState(() => _coursEnCoursDeTelechargement.add(cours.id));

    try {
      final coursComplet = await _apiService.getCoursComplet(cours.id);
      await _sauvegarderCoursLocalement(coursComplet);
      await _chargerCoursLocaux();

      if (mounted) {
        setState(() => _titresTelecharges.add(cours.titre));
        _afficherPopupSucces(cours.titre);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du téléchargement: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _coursEnCoursDeTelechargement.remove(cours.id));
      }
    }
  }

  Future<void> _toutTelecharger() async {
    final coursATelechargement = _coursDistants
        .where((c) => !_titresTelecharges.contains(c.titre))
        .toList();

    if (coursATelechargement.isEmpty) return;

    setState(() {
      for (final c in coursATelechargement) {
        _coursEnCoursDeTelechargement.add(c.id);
      }
    });

    int succes = 0;
    final List<String> erreurs = [];

    for (final cours in coursATelechargement) {
      try {
        final coursComplet = await _apiService.getCoursComplet(cours.id);
        await _sauvegarderCoursLocalement(coursComplet);
        if (mounted) {
          setState(() => _titresTelecharges.add(cours.titre));
        }
        succes++;
      } catch (e) {
        erreurs.add(cours.titre);
      } finally {
        if (mounted) {
          setState(() => _coursEnCoursDeTelechargement.remove(cours.id));
        }
      }
    }

    await _chargerCoursLocaux();

    if (!mounted) return;

    if (erreurs.isEmpty) {
      _afficherPopupToutTelecharge(succes);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$succes cours téléchargé(s). Échec : ${erreurs.join(', ')}',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _sauvegarderCoursLocalement(CoursComplet coursComplet) async {
    if (kDebugMode) {
      print('📚 Début sauvegarde cours: "${coursComplet.cours.titre}" (module ${coursComplet.cours.idModule})');
    }
    final pageRepository = PageRepository();

    final coursLocal = Cours(
      idModule: coursComplet.cours.idModule,
      titre: coursComplet.cours.titre,
      contenu: coursComplet.cours.contenu,
      description: coursComplet.cours.description,
    );

    final coursIdLocal = await _coursRepository.create(coursLocal);
    if (kDebugMode) {
      print('✅ Cours créé en BDD locale avec id: $coursIdLocal');
    }

    final dossierCours = await _creerDossierCours(
      idModule: coursComplet.cours.idModule,
      idCours: coursIdLocal,
    );

    // ── Pages ──────────────────────────────────────────────────────────────
    final List<String> tousLesMedias = [];
    for (final page in coursComplet.pages) {
      if (kDebugMode) {
        print('   📄 Page "${page.description}" — medias bruts: "${page.medias}"');
      }
      if (page.medias.isNotEmpty) {
        final noms = page.medias.split('@')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (kDebugMode) print('   └─ Médias extraits: $noms');
        tousLesMedias.addAll(noms);
      }
    }

    if (kDebugMode) {
      print('🎯 Total médias à télécharger: ${tousLesMedias.length} → $tousLesMedias');
    }

    await _telechargerTousLesMediasDuCours(
      idModule: coursComplet.cours.idModule,
      idCours: coursIdLocal,
      nomsMedias: tousLesMedias,
      dossierCours: dossierCours,
    );

    for (final pageDistante in coursComplet.pages) {
      final List<MediaItem> mediasList = [];

      if (pageDistante.medias.isNotEmpty) {
        final noms = pageDistante.medias.split('@')
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
          if (kDebugMode) {
            print('   💾 MediaItem: $nomFichier → type=$typeMedia → $cheminLocal');
          }

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
      if (kDebugMode) {
        print('   ✅ Page "${pageDistante.description}" sauvegardée');
      }
    }

    // ── QCM ───────────────────────────────────────────────────────────────
    await _sauvegarderQcm(
      coursIdDistant: coursComplet.cours.id,
      coursIdLocal: coursIdLocal,
    );

    // ── Cloze (texte à trou) ──────────────────────────────────────────────
    await _sauvegarderCloze(
      coursIdDistant: coursComplet.cours.id,
      coursIdLocal: coursIdLocal,
    );

    if (kDebugMode) {
      print('🏁 Sauvegarde terminée pour "${coursComplet.cours.titre}"');
    }
  }

  /// Télécharge les QCM distants et les insère en BDD locale
  Future<void> _sauvegarderQcm({
    required int coursIdDistant,
    required int coursIdLocal,
  }) async {
    try {
      final qcmDistants = await _apiService.getQcmDuCours(coursIdDistant);

      if (kDebugMode) {
        print('🎯 QCM à sauvegarder: ${qcmDistants.length}');
      }

      if (qcmDistants.isEmpty) return;

      final qcmRepository = QCMRepository();

      for (final q in qcmDistants) {
        final qcmLocal = QCM(
          question: q.question,
          rep1: q.rep1,
          rep2: q.rep2,
          rep3: q.rep3,
          rep4: q.rep4,
          soluce: q.soluce,
          idCours: coursIdLocal,
        );
        await qcmRepository.insert(qcmLocal);
        if (kDebugMode) {
          print('   ✅ QCM inséré: "${q.question}"');
        }
      }
    } catch (e) {
      // On ne bloque pas le téléchargement du cours si les QCM échouent
      if (kDebugMode) print('⚠️ Erreur sauvegarde QCM: $e');
    }
  }

  /// Télécharge les Cloze distants et les insère en BDD locale
  Future<void> _sauvegarderCloze({
    required int coursIdDistant,
    required int coursIdLocal,
  }) async {
    try {
      final clozeDistants = await _apiService.getClozesDuCours(coursIdDistant);

      if (kDebugMode) {
        print('🧩 Cloze à sauvegarder: ${clozeDistants.length}');
      }

      if (clozeDistants.isEmpty) return;

      final clozeRepository = ClozeRepository();

      for (final c in clozeDistants) {
        final clozeLocal = ClozeQuestion(
          phrase: c.texte,
          rep1: c.reponse1,
          rep2: c.reponse2,
          rep3: c.reponse3,
          rep4: c.reponse4,
          soluce: c.numeroReponseCorrecte,
          idCours: coursIdLocal,
        );
        await clozeRepository.insert(clozeLocal);
        if (kDebugMode) {
          print('   ✅ Cloze inséré: "${c.texte.substring(0, c.texte.length.clamp(0, 40))}..."');
        }
      }
    } catch (e) {
      // On ne bloque pas le téléchargement du cours si les Cloze échouent
      if (kDebugMode) print('⚠️ Erreur sauvegarde Cloze: $e');
    }
  }

  Future<Directory> _creerDossierCours({
    required int idModule,
    required int idCours,
  }) async {
    final appDir = await getApplicationDocumentsDirectory();
    final dossier = Directory(
      path.join(appDir.path, 'AppData', 'Module$idModule', 'Cours$idCours'),
    );
    if (!await dossier.exists()) {
      await dossier.create(recursive: true);
    }
    return dossier;
  }

  Future<void> _telechargerTousLesMediasDuCours({
    required int idModule,
    required int idCours,
    required List<String> nomsMedias,
    required Directory dossierCours,
  }) async {
    final String baseUrl =
        '${AppConfig.urlMedias}/AppData/Module$idModule/Cours$idCours';
    if (kDebugMode) print('🌐 Base URL médias: $baseUrl');

    if (nomsMedias.isEmpty) {
      if (kDebugMode) print('⚠️  Aucun média à télécharger');
      return;
    }

    final futures = nomsMedias.map((nomFichier) async {
      final urlComplete = '$baseUrl/$nomFichier';
      final fichier = File(path.join(dossierCours.path, nomFichier));

      if (await fichier.exists()) {
        if (kDebugMode) print('⏭️  $nomFichier déjà présent, skip');
        return;
      }

      if (kDebugMode) print('⬇️  Téléchargement: $urlComplete');
      try {
        final response = await http.get(Uri.parse(urlComplete));
        if (kDebugMode) {
          print('   └─ Status: ${response.statusCode} — ${response.bodyBytes.length} bytes');
        }
        if (response.statusCode == 200) {
          await fichier.writeAsBytes(response.bodyBytes);
          if (kDebugMode) print('   └─ ✅ Sauvegardé: ${fichier.path}');
        } else {
          if (kDebugMode) print('   └─ ❌ Introuvable (${response.statusCode}): $urlComplete');
        }
      } catch (e) {
        if (kDebugMode) print('   └─ ❌ Erreur pour $nomFichier: $e');
      }
    });

    await Future.wait(futures);
    if (kDebugMode) print('✅ Tous les médias téléchargés');
  }

  void _afficherPopupSucces(String titreCours) {
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
                'Téléchargement réussi !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '"$titreCours"',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Le cours et ses jeux ont été ajoutés à votre bibliothèque',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud_done, color: Colors.white, size: 46),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tout est téléchargé !',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                '$nb cours ajouté${nb > 1 ? 's' : ''} à votre bibliothèque',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 12),
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

  bool _estTelecharge(String titre) => _titresTelecharges.contains(titre);

  Cours? _coursLocalPourTitre(String titre) {
    try {
      return _coursLocaux.firstWhere((c) => c.titre == titre);
    } catch (_) {
      return null;
    }
  }

  List<_CoursItem> get _listeUnifiee {
    final List<_CoursItem> telecharges = [];
    final List<_CoursItem> nonTelecharges = [];

    for (final distant in _coursDistants) {
      if (_estTelecharge(distant.titre)) {
        final local = _coursLocalPourTitre(distant.titre);
        if (local != null) {
          telecharges.add(_CoursItem.local(local));
        }
      } else {
        nonTelecharges.add(_CoursItem.distant(distant));
      }
    }

    for (final local in _coursLocaux) {
      final dejaDans = telecharges.any((item) => item.titre == local.titre);
      if (!dejaDans) {
        telecharges.add(_CoursItem.local(local));
      }
    }

    return [...telecharges, ...nonTelecharges];
  }

  @override
  Widget build(BuildContext context) {
    final liste = _listeUnifiee;
    final nbTelecharges = liste.where((i) => i.estTelecharge).length;
    final nbDistants = liste.where((i) => !i.estTelecharge).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Cours'),
        centerTitle: true,
        backgroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.cloud,
              color: _apiConnectee ? Colors.green : Colors.grey,
            ),
            onPressed: _rafraichir,
            tooltip: _apiConnectee
                ? 'API connectée — Rafraîchir'
                : 'API non disponible — Réessayer',
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
                '$nbTelecharges cours',
                Colors.black87,
              ),
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
                            '$nbDistants cours',
                          ),
                        ],
                        _buildCoursCard(item),
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
            Text(
              titre,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: couleur,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              sousTitre,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String titre, String sousTitre) {
    final bool toutEnCours = _coursEnCoursDeTelechargement.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
      child: Row(
        children: [
          Text(
            titre,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            sousTitre,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursCard(_CoursItem item) {
    final enTelechargement = item.distantId != null &&
        _coursEnCoursDeTelechargement.contains(item.distantId);

    const couleurAccent = Color.fromRGBO(252, 179, 48, 1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: item.estTelecharge ? 2 : 1,
      color: item.estTelecharge ? Colors.white : Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          if (item.estTelecharge && item.coursLocal != null) {
            CoursSelectionne.instance.setCours(item.coursLocal!);
            GoRouter.of(context).go('/cours/${item.coursLocal!.id}');
          } else if (item.coursDistant != null && !enTelechargement) {
            _telechargerCours(item.coursDistant!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: item.estTelecharge
                      ? couleurAccent
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.school,
                  color: item.estTelecharge ? Colors.white : Colors.grey[500],
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: item.estTelecharge
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.description,
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
          Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            _apiConnectee
                ? 'Aucun cours disponible'
                : 'Aucun cours téléchargé\net API non disponible',
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
}

class _CoursItem {
  final String titre;
  final String description;
  final bool estTelecharge;
  final Cours? coursLocal;
  final CoursDistant? coursDistant;

  _CoursItem.local(Cours c)
      : titre = c.titre,
        description = c.contenu,
        estTelecharge = true,
        coursLocal = c,
        coursDistant = null;

  _CoursItem.distant(CoursDistant c)
      : titre = c.titre,
        description = c.description,
        estTelecharge = false,
        coursLocal = null,
        coursDistant = c;

  int? get distantId => coursDistant?.id;
}