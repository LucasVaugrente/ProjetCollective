// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

import 'package:seriouse_game/ui/Cours/CoursViewModel.dart';
import 'package:seriouse_game/ui/Description/DescriptionView.dart';
import 'package:seriouse_game/ui/Contenu/ContenuCoursView.dart';
import 'package:seriouse_game/ui/QCM/JeuQCMView.dart';


import 'package:seriouse_game/ui/CoursSelectionne.dart';
import 'package:seriouse_game/models/cours.dart';

import 'package:go_router/go_router.dart';

class CoursView extends StatelessWidget {
  CoursView({super.key}) {
    // MAJ du ViewModel avec le nouveau cours séléctionné
    CoursSelectionne coursSelectionne = CoursSelectionne.instance;
    coursViewModel.loadContenu(coursSelectionne.cours);  // #TODO : A mettre dans ListCours.dart
    coursViewModel.setIndexPageVisite(coursSelectionne.cours);
  }

  Widget? child;
  
  final coursViewModel = CoursViewModel();

  Future<void> changePage(BuildContext context) async {
    CoursSelectionne coursSelectionne = CoursSelectionne.instance;

    int nbPageCours = await coursViewModel.getNombrePageDeContenu(coursSelectionne.cours);
    int nbPageJeu = await coursViewModel.getNombrePageDeJeu(coursSelectionne.cours);
    int page = coursViewModel.page;

    Widget nouvellePage = const Text("PB lors du chargement de la page de cours");
    if (page==0) {
      nouvellePage = DescriptionView(cours: coursSelectionne.cours, coursViewModel: coursViewModel);
      //print("Chargement de description");
    } else if (page<=nbPageCours) {

      nouvellePage = ContenuCoursView(cours: coursSelectionne.cours, selectedPageIndex: page - 1);
      //print("Chargement de contenu");
    } else if (page<=nbPageCours + nbPageJeu) {
      // Page jeu 
      nouvellePage = JeuQCMView(cours: coursSelectionne.cours, selectedPageIndex: page - nbPageCours - 1);
    } else {
      // Redirection vers la page de module
      GoRouter.of(context).go('/module');
    }

    child = nouvellePage;
  }

  @override
  Widget build(BuildContext context) {

    return ListenableBuilder(
          listenable: coursViewModel, // On écoute le changement de page du ViewModel
          builder: (context, _) {
            // Le futur Builder sert à attendre l'exécution de la méthode changePage() avant de build :
            // Sans, la page à afficher (ie this.child) est récupéré après le build : 
            //            Il n'est donc pas affiché
            return FutureBuilder<void>(
              future: changePage(context), // Récupération de la bonne View à charger selon la page visitée du cours sélectionné
              builder: (context, snapshot) {

                    return Scaffold(
                      appBar: AppBar(
                        backgroundColor: Colors.white,
                        elevation: 2,
                        title: FutureBuilder( // Permet d'attendre le calcul de progression 
                                  future: coursViewModel.getProgressionActuelle(CoursSelectionne.instance.cours), 
                                  builder: (context, snapshot) {  
                                      return HeaderWidget(cours: CoursSelectionne.instance.cours, progression: snapshot.data);
                                  }),
                        centerTitle: false,
                      ),
                      body: child,
                                            // La page de description n'a pas besoin du footer : Il change la page vu grâce à un bouton
                      bottomNavigationBar: child.runtimeType == DescriptionView ? null : 
                                            FooterWidget(
                                              courseTitle: "Cours 1",
                                              pageNumber: coursViewModel.page,
                                              coursViewModel: coursViewModel,
                                            ), 
                    );
              }
            );
          }
    );

  }
}

class HeaderWidget extends StatelessWidget {
  final Cours cours;
  final double? progression;

  const HeaderWidget({
    Key? key,
    required this.cours,
    this.progression,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            const SizedBox(width: 8),
            // Titre
            Text(
              cours.titre,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            // Barre de progression
            ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progression, // Progression à 50%
                  minHeight: 6,
                  color: Colors.teal,
                  backgroundColor: Colors.teal.withAlpha((255 * 0.2).round()),
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

  const FooterWidget({
    Key? key,
    required this.courseTitle,
    required this.pageNumber,
    required this.coursViewModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton flèche gauche
          IconButton(
            icon: const Icon(Icons.arrow_left, size: 28),
            onPressed: () {
              // Action pour aller à la page précédente
              coursViewModel.changementPagePrecedente();
            },
          ),
          // Texte de pagination
          Text(
            '$courseTitle : Page $pageNumber',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Bouton flèche droite
          IconButton(
            icon: const Icon(Icons.arrow_right, size: 28),
            onPressed: () {
              // Action pour aller à la page suivante
              coursViewModel.changementPageSuivante();
            },
          ),
        ],
      ),
    );
  }
}