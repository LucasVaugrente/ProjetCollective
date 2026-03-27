import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:factoscope/ui/Cours/cours_view_model.dart';
import 'description_view.dart';
import 'package:factoscope/ui/Contenu/contenu_cours_view.dart';
import 'package:factoscope/ui/QCM/jeu_qcm_view.dart';
import 'package:factoscope/ui/cours_selectionne.dart';

import '../../models/cours.dart';
import 'fin_cours_view.dart';
import 'transition_jeu_view.dart';
import '../../repositories/cours_repository.dart';
import '../Cloze/cloze_page.dart';

class CoursView extends StatefulWidget {
  final int coursId;
  const CoursView({super.key, required this.coursId});

  @override
  State<CoursView> createState() => _CoursViewState();
}

class _CoursViewState extends State<CoursView> {
  final coursViewModel = CoursViewModel();
  bool isLoading = true;

  // Score du jeu — null tant que le jeu n'est pas terminé
  int? _scoreJeu;
  int? _totalJeu;

  @override
  void initState() {
    super.initState();
    _loadCours();
  }

  Future<void> _loadCours() async {
    try {
      final coursRepository = CoursRepository();
      final loadedCours = await coursRepository.getById(widget.coursId);
      if (loadedCours != null) {
        CoursSelectionne.instance.setCours(loadedCours);
        await coursViewModel.loadContenu(loadedCours);
        await coursViewModel.setIndexPageVisite(loadedCours);
      }
      setState(() => isLoading = false);
    } catch (e) {
      if (kDebugMode) print("Erreur lors du chargement du cours: $e");
      setState(() => isLoading = false);
    }
  }

  // Appelé par JeuQCMView ou ClozePage quand le jeu est terminé
  void _onJeuTermine(int score, int total) {
    setState(() {
      _scoreJeu = score;
      _totalJeu = total;
    });
    coursViewModel.changementPageSuivante(CoursSelectionne.instance.cours);
  }

  // Appelé par les jeux quand l'utilisateur veut revenir à la transition
  void _onRetourTransition() {
    setState(() {
      _scoreJeu = null;
      _totalJeu = null;
    });
    final nbPages = CoursSelectionne.instance.cours.pages?.length ?? 0;
    coursViewModel.allerAPage(nbPages + 1); // transitionPage
  }

  // Appelé par FinCoursView quand l'utilisateur veut recommencer le jeu
  void _onRecommencer() => _onRetourTransition();

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ListenableBuilder(
      listenable: coursViewModel,
      builder: (context, _) => _buildCoursView(context),
    );
  }

  Widget _buildCoursView(BuildContext context) {
    final coursSelectionne = CoursSelectionne.instance;
    final int nbPageCours = coursSelectionne.cours.pages?.length ?? 0;
    final int currentPage = coursViewModel.page;

    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        coursViewModel.getNombrePageQCM(coursSelectionne.cours),
        coursViewModel.getNombrePageCloze(coursSelectionne.cours),
        coursViewModel.getTypeJeu(coursSelectionne.cours.id!),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final int nbQCM = snapshot.data![0] as int;
        final int nbCloze = snapshot.data![1] as int;
        final String typeJeu = snapshot.data![2] as String;
        final bool aucunJeu = nbQCM + nbCloze == 0;

        final int transitionPage = nbPageCours + 1;
        final int jeuPage = transitionPage + 1; // une seule "page" jeu
        final int finPage = aucunJeu ? nbPageCours + 1 : jeuPage + 1;

        Widget nouvellePage;
        bool afficherFooter = true;

        if (currentPage == 0) {
          nouvellePage = DescriptionView(
            cours: coursSelectionne.cours,
            coursViewModel: coursViewModel,
          );
          afficherFooter = false;
        } else if (currentPage <= nbPageCours) {
          nouvellePage = ContenuCoursView(
            cours: coursSelectionne.cours,
            selectedPageIndex: currentPage - 1,
          );
        } else if (!aucunJeu && currentPage == transitionPage) {
          nouvellePage = TransitionQCMView(
            cours: coursSelectionne.cours,
            coursViewModel: coursViewModel,
          );
          afficherFooter = false;
        } else if (!aucunJeu && currentPage == jeuPage) {
          // Footer masqué — les jeux ont leurs propres boutons
          afficherFooter = false;
          if (typeJeu == 'qcm') {
            nouvellePage = JeuQCMView(
              cours: coursSelectionne.cours,
              onTermine: _onJeuTermine,
              onPrecedent: _onRetourTransition,
            );
          } else if (typeJeu == 'cloze') {
            nouvellePage = ClozePage(
              coursId: coursSelectionne.cours.id!,
              onTermine: _onJeuTermine,
              onPrecedent: _onRetourTransition,
              key: const ValueKey('cloze_jeu'),
            );
          } else {
            nouvellePage = const Center(child: Text("Aucun jeu disponible"));
          }
        } else if (currentPage == finPage) {
          nouvellePage = FinCoursView(
            cours: coursSelectionne.cours,
            score: _scoreJeu,
            totalQuestions: _totalJeu,
            onRecommencer:
                (!aucunJeu && _scoreJeu != null && _scoreJeu! < _totalJeu!)
                    ? _onRecommencer
                    : null,
          );
          afficherFooter = false;
        } else {
          nouvellePage = const Center(child: Text("Page introuvable"));
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 1,
            title: FutureBuilder(
              future:
                  coursViewModel.getProgressionActuelle(coursSelectionne.cours),
              builder: (context, snapshot) => HeaderWidget(
                cours: coursSelectionne.cours,
                progression: snapshot.data,
              ),
            ),
            centerTitle: false,
          ),
          body: nouvellePage,
          bottomNavigationBar: afficherFooter
              ? FooterWidget(
                  courseTitle: coursSelectionne.cours.titre,
                  pageNumber: currentPage,
                  coursViewModel: coursViewModel,
                  cours: coursSelectionne.cours,
                )
              : null,
        );
      },
    );
  }
}

class HeaderWidget extends StatelessWidget {
  final Cours cours;
  final double? progression;

  const HeaderWidget({super.key, required this.cours, this.progression});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          cours.titre,
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (progression != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progression,
              minHeight: 4,
              color: const Color.fromRGBO(252, 179, 48, 1),
              backgroundColor: const Color.fromRGBO(252, 179, 48, 0.2),
            ),
          ),
      ],
    );
  }
}

class FooterWidget extends StatelessWidget {
  final String courseTitle;
  final int pageNumber;
  final CoursViewModel coursViewModel;
  final Cours cours;

  const FooterWidget({
    super.key,
    required this.courseTitle,
    required this.pageNumber,
    required this.coursViewModel,
    required this.cours,
  });

  static const _orange = Color.fromRGBO(252, 179, 48, 1);
  static const _textDark = Color(0xFF292466);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        children: [
          // Précédent
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => coursViewModel.changementPagePrecedente(),
              icon: const Icon(Icons.arrow_back, size: 18, color: _textDark),
              label: const Text('Précédent',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textDark)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Suivant
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => coursViewModel.changementPageSuivante(cours),
              icon: const Icon(Icons.arrow_forward, size: 18, color: _textDark),
              label: const Text('Suivant',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textDark)),
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
