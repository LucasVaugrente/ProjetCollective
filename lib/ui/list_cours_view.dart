// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:factoscope/models/list_cours_view_model.dart';
import 'package:factoscope/models/media_cours.dart';
import 'package:factoscope/ui/Contenu/WidgetContenu/contenu_image_widget.dart';
import 'package:factoscope/ui/Cours/cours_view.dart';
import 'package:factoscope/ui/cours_selectionne.dart';

import '../models/cours.dart';
import '../models/module.dart';
import 'module_selectionne.dart';

import 'package:go_router/go_router.dart';

class ListCoursView extends StatefulWidget {
  ListCoursViewModel listCours = ListCoursViewModel();
  ModuleSelectionne moduleSelectionne = ModuleSelectionne();

  ListCoursView({super.key});

  @override
  State<ListCoursView> createState() =>
      ListCoursViewState(listCours, moduleSelectionne);
}

class ListCoursViewState extends State<ListCoursView> {
  late ListCoursViewModel listCours;
  late ModuleSelectionne moduleSelectionne;

  ListCoursViewState(this.listCours, this.moduleSelectionne);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(

        //On écoute moduleSelectionne pour changer l'interface si le module change.
        listenable: moduleSelectionne,
        builder: (context, child) {
          int size = 0;

          // Récupération du module sélectionné
          Module module = moduleSelectionne.moduleSelectionne;

          // Chargement des cours associés dans le module
          listCours.getCours(module.id);

          //récupération de la taille de la liste du module
          size = moduleSelectionne.coursDuModule.length;

          //Widget
          return ListenableBuilder(

              //On écoute l'état de listCours pour changer l'affichage si cette liste change
              listenable: listCours,
              builder: (context, child) {
                return Column(
                  children: [
                    //Appel du widget affichant le titre
                    FutureBuilder(
                        // Permet d'attendre le calcul de progression
                        future:
                            ListCoursViewModel().getProgressionModule(module),
                        builder: (context, snapshot) {
                          return Container(
                              //On veut ajouter une marge ici car on ne peut pas en ajouter directement dans moduleHeader sans l'augmenter dans la liste des modules
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 20.0),
                              child: moduleHeader(module, snapshot.data));
                        }),

                    //Affichage des informations sur le module (description, cours, ...) dans une liste

                    Expanded(
                      child: ListView.builder(
                        //On initialise le nombre de widgets à affiché par celui de la liste de cours
                        itemCount: size + 1,

                        itemBuilder: (context, index) {
                          //Si l'index est à 0 : on affiche la description du module, sinon on affiche le cours index-1
                          if (index == 0) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                    child: const Text(
                                      "Description et Objectif du Module",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 10.0, vertical: 8.0),
                                      child:
                                          //Texte de la description
                                          Text(
                                        module.description,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.left,
                                      )),
                                ],
                              ),
                            );

                            //Affichage de la liste des cours du module
                          } else {
                            //On extraie pour chaque élément de la liste le cours dans item
                            final item =
                                moduleSelectionne.coursDuModule[index - 1];

                            //On build le widget à partir du titre d'item
                            return listItem(item, context);
                          }
                        },
                      ),
                    ),
                  ],
                ); // Widgets de liste avec données
              });
        });
  }
}

//Widget correspondant au titre du module
SizedBox moduleHeader(Module module, double? progress) {
  //progress : Valeur de la progression entre 0 et 1
  //module : module dont on veut afficher le header

  //Model utilisé pour récupérer l'image du module à afficher dans le header.
  MediaCours media =
      MediaCours(idPage: 1, ordre: 1, url: module.urlImg, type: "image");

  return SizedBox(
      child: Container(
    //Gestion de l'espace entre le contenu et la bordure interieure du widget
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
    //Gestion de l'espace entre l'exterieur du widget et les widgets adjacents
    margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
    //Décoration de la bordure
    decoration: BoxDecoration(
      //Gestion de l'angle de la bordure
      borderRadius: BorderRadius.circular(12),
      //Couleur interne et externe de la boite
      color: const Color.fromARGB(255, 236, 187, 139),
    ),
    child: Row(
      children: [
        //Image à load. Utilise le model media contenant l'url de l'image du model.
        ContenuImageWidget(
          media: media,
          width: 80,
          height: 80,
        ),

        const Spacer(),

        Column(
          //Titre du module
          children: [
            Container(
              //Gestion de l'espace entre le contenu et la bordure interieure du widget
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              //Gestion de l'espace entre l'exterieur du widget et les widgets adjacents
              margin:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              child: Text(
                module.titre,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.clip,
              ),
            ),

            //Affichage de la barre de progression du module
            //SizedBox est nécessaire car LinearProgressIndicator doit être contenue dans un objet de largeur définie
            //Column n'ayant pas de largeur max, on ne peut pas mettre le wwidget directement dedans
            SizedBox(
              //Longueur max du widget
              width: 200,
              child:
                  //Container pour des bords plus arrondis
                  ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      //Barre de progression du module
                      child: LinearProgressIndicator(
                        value: progress,
                        //On utilise progress pour définir le remplissage
                        minHeight: 6,
                        color: const Color.fromARGB(255, 90, 230, 220),
                        backgroundColor:
                            const Color.fromARGB(255, 175, 240, 235),
                      )),
            )
          ],
        ),

        const Spacer()
      ],
    ),
  ));
}

//Widget permettant d'afficher et de sélectionner un cours de la liste
SizedBox listItem(Cours cours, BuildContext context) {
  return SizedBox(
    child:
        //On utilise Inkwell pour transformer notre container en bouton
        InkWell(
            child: Container(
              //Gestion de l'espace entre le contenu et la bordure interieure du widget
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              //Gestion de l'espace entre l'exterieur du widget et les widgets adjacents
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              //On utilise le header de CoursView
              child: FutureBuilder(
                  // Permet d'attendre le calcul de progression
                  future: ListCoursViewModel().getProgressionCours(cours),
                  builder: (context, snapshot) {
                    return Container(
                        //Gestion de l'espace entre le contenu et la bordure interieure du widget
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 20.0),
                        //Décoration de la bordure
                        decoration: BoxDecoration(
                          //Gestion de l'angle de la bordure
                          borderRadius: BorderRadius.circular(12),
                          //Couleur interne et externe de la boite
                          color: const Color.fromARGB(255, 235, 235, 235),
                        ),
                        child: HeaderWidget(
                            cours: cours, progression: snapshot.data));
                  }),
            ),
            //Méthode pour se aller au cours
            onTap: () {
              CoursSelectionne.instance.cours = cours;
              GoRouter.of(context).go('/cours');
            }),
  );
}
