import 'package:flutter/material.dart';
import 'package:factoscope/models/module.dart';
import 'package:factoscope/ui/list_cours_view.dart';
import 'package:factoscope/ui/module_selectionne.dart';

import '../models/list_module_view_model.dart';

import 'package:go_router/go_router.dart';

// Widget de la page d'accueil/Liste des modules
class ListModulesView extends StatefulWidget {

  const ListModulesView({super.key});

  @override
  State<ListModulesView> createState() => _ListModulesViewState();
}

// State du widget d'affichage de la liste des modules( page d'accueil )
class _ListModulesViewState extends State<ListModulesView> {
  ListModuleViewModel listModuleViewModel = ListModuleViewModel();

  @override
  void initState() {
    super.initState();
    listModuleViewModel.recupererModule(); // Charge les modules dès l'initialisation
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: listModuleViewModel,
      builder: (context, child) {
        return Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: const Text(
                  "Tableau de bord",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            headerAvancement(), // Appel à headerAvancement
            // Affiche Modules en gras à gauche
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: const Text(
                  "Cours :",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            // Affichage de la liste des modules
            Expanded(
              child: ListView.builder(
                itemCount: listModuleViewModel.listModule.length,
                itemBuilder: (context, index) {
                  final item = listModuleViewModel.listModule[index];
                  return listModuleItem(item, context);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// Widget représentant l'header d'un module dans la liste des modules.
SizedBox listModuleItem(Module item, BuildContext context) {
  return SizedBox(
    child: InkWell(
      child: FutureBuilder(
        future: ListModuleViewModel().getProgressionModule(item),
        builder: (context, snapshot) {
          return moduleHeader(item, snapshot.data);
        },
      ),
      onTap: () {
        ModuleSelectionne.instance.moduleSelectionne = item;
        GoRouter.of(context).go('/module');
      },
    ),
  );
}


// Header affichant l'avancement dans le cours de l'utilisateur
SizedBox headerAvancement(){

  return SizedBox(
    child: Container(
      //Gestion de l'espace entre le contenu et la bordure interieure du widget
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      //Gestion de l'espace entre l'exterieur du widget et les widgets adjacents
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      //Décoration de la bordure
      decoration: BoxDecoration(
      //Gestion de l'angle de la bordure
      borderRadius:BorderRadius.circular(12),
      color: const Color.fromARGB(255, 219, 218, 215),),
      child: Row(
        children: [
          Container(
            //Gestion de l'espace entre le contenu et la bordure interieure du widget
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            //Gestion de l'espace entre l'exterieur du widget et les widgets adjacents
            margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            //Colonne contenant le texte du header
            child: const Column(
              children: [
                //Titre
                Text("Votre Avancement",
                style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),),
                // Message d'encouragement (faire detection en fonction du pourcentage)
                // Text("Vous êtes bientôt au bout, "),
                // Text("bientôt la certification")
              ],
            ),
          ),

          const Spacer(),

          // On utilise un stack pour mettre le pourcentage au dessus d'une icône
          Stack(
            alignment: Alignment.center,
            children: [
              
              // Icône : Attention ce n'est pas la bonne icône pour l'instant
              const Icon(
                Icons.bookmark,
                size: 140,
                color: Color.fromARGB(255, 3, 47, 122),),

              //Affichage du pourcentage d'avancement
              FutureBuilder( // Permet d'attendre le calcul de progression 
                                  future: ListModuleViewModel().getProgressionGlobale(), 
                                  builder: (context, snapshot) {
                                    String progress = "";
                                    if (snapshot.hasData) {
                                      progress = snapshot.data.toString();
                                    } 

                                    return Text("$progress%",
                                                style: const TextStyle(
                                                                fontSize: 30,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                              ),);
                                  } ),
              

            ],
          ),         
        ],
      )
      
      
      ),
  );

}