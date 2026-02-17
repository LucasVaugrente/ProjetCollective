import 'package:flutter/material.dart' hide Page;
import 'package:factoscope/repositories/cours_repository.dart';
import 'package:factoscope/repositories/page_repository.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/models/page.dart';
import 'api_service.dart';

class CoursDisponiblesDialog extends StatefulWidget {
  const CoursDisponiblesDialog({super.key});

  @override
  State<CoursDisponiblesDialog> createState() => _CoursDisponiblesDialogState();
}

class _CoursDisponiblesDialogState extends State<CoursDisponiblesDialog> {
  final ApiService _apiService = ApiService();
  final CoursRepository _coursRepository = CoursRepository();

  List<CoursDistant>? _coursDisponibles;
  List<String> _coursTitresTelecharges = []; // Titres des cours déjà téléchargés
  bool _isLoading = false;
  String? _errorMessage;
  Set<int> _coursEnCoursDeTelechargement = {};

  @override
  void initState() {
    super.initState();
    _chargerCoursDisponibles();
  }

  Future<void> _chargerCoursDisponibles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Charger les cours depuis l'API
      final cours = await _apiService.getCoursDisponibles();

      // Charger les cours déjà présents localement
      final coursLocaux = await _coursRepository.getAll();
      final titresLocaux = coursLocaux.map((c) => c.titre).toList();

      setState(() {
        _coursDisponibles = cours;
        _coursTitresTelecharges = titresLocaux;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _telechargerCours(CoursDistant cours) async {
    setState(() {
      _coursEnCoursDeTelechargement.add(cours.id);
    });

    try {
      // Récupérer le cours complet avec ses pages
      final coursComplet = await _apiService.getCoursComplet(cours.id);

      // Sauvegarder dans la base de données locale
      await _sauvegarderCoursLocalement(coursComplet);

      // Ajouter le titre aux cours téléchargés
      setState(() {
        _coursTitresTelecharges.add(cours.titre);
      });

      // Afficher une popup de succès
      if (mounted) {
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
      setState(() {
        _coursEnCoursDeTelechargement.remove(cours.id);
      });
    }
  }

  void _afficherPopupSucces(String titreCours) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icône de succès avec animation
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Téléchargement réussi !',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '"$titreCours"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Le cours a été ajouté à votre bibliothèque',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sauvegarderCoursLocalement(CoursComplet coursComplet) async {
    final pageRepository = PageRepository();

    final coursLocal = Cours(
      idModule: coursComplet.cours.idModule,
      titre: coursComplet.cours.titre,
      contenu: coursComplet.cours.contenu,
      description: coursComplet.cours.description,
    );

    final coursIdLocal = await _coursRepository.create(coursLocal);

    for (final pageDistante in coursComplet.pages) {
      final List<MediaItem> mediasList = [];
      if (pageDistante.medias.isNotEmpty) {
        final urls = pageDistante.medias.split('@');
        for (int i = 0; i < urls.length; i++) {
          final url = urls[i].trim();
          if (url.isNotEmpty) {
            String typeMedia = 'text';
            if (url.endsWith('.jpg') || url.endsWith('.jpeg') ||
                url.endsWith('.png') || url.endsWith('.gif') ||
                url.endsWith('.webp')) {
              typeMedia = 'image';
            } else if (url.endsWith('.mp4') || url.endsWith('.webm') ||
                url.endsWith('.avi')) {
              typeMedia = 'video';
            } else if (url.endsWith('.mp3') || url.endsWith('.wav') ||
                url.endsWith('.ogg')) {
              typeMedia = 'audio';
            }

            mediasList.add(MediaItem(
              ordre: i + 1,
              url: url,
              type: typeMedia,
              caption: '',
            ));
          }
        }
      }

      final pageLocale = Page(
        idCours: coursIdLocal,
        description: pageDistante.description,
        medias: mediasList,
      );

      await pageRepository.create(pageLocale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Cours disponibles',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _chargerCoursDisponibles,
                  tooltip: 'Rafraîchir',
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Fermer',
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement des cours...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de connexion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _chargerCoursDisponibles,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_coursDisponibles == null || _coursDisponibles!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun cours disponible',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Filtrer les cours déjà téléchargés
    final coursNonTelecharges = _coursDisponibles!
        .where((cours) => !_coursTitresTelecharges.contains(cours.titre))
        .toList();

    if (coursNonTelecharges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tous les cours sont téléchargés !',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_coursDisponibles!.length} cours dans votre bibliothèque',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Compteur de cours
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(
                '${coursNonTelecharges.length} cours disponible${coursNonTelecharges.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (_coursTitresTelecharges.isNotEmpty)
                Text(
                  '${_coursTitresTelecharges.length} déjà téléchargé${_coursTitresTelecharges.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        ),
        // Liste des cours
        Expanded(
          child: ListView.builder(
            itemCount: coursNonTelecharges.length,
            itemBuilder: (context, index) {
              final cours = coursNonTelecharges[index];
              final estEnCoursDeTelechargement =
              _coursEnCoursDeTelechargement.contains(cours.id);

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 236, 187, 139),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    cours.titre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: cours.description.isNotEmpty
                      ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      cours.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  )
                      : null,
                  trailing: estEnCoursDeTelechargement
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : IconButton(
                    icon: const Icon(Icons.download),
                    color: Colors.green,
                    onPressed: () => _telechargerCours(cours),
                    tooltip: 'Télécharger',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}