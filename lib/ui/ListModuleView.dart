import 'package:flutter/material.dart';
import 'package:seriouse_game/models/ListCoursViewModel.dart';
import 'package:seriouse_game/models/module.dart';
import 'package:seriouse_game/ui/ListCoursView.dart';
import 'package:seriouse_game/ui/ModuleSelectionne.dart';

import '../models/ListModuleViewModel.dart';

import 'package:go_router/go_router.dart';

//Widget de la page d'accueil/Liste des modules
class ListModulesView extends StatefulWidget {

  const ListModulesView({super.key});

  @override
  State<ListModulesView> createState() => _ListModulesViewState();
}

//State du widget d'affichage de la liste des modules( page d'accueil )
class _ListModulesViewState extends State<ListModulesView> {

  //Objet ayant accès à la liste des modules de l'application
  ListModuleViewModel listModuleViewModel = ListModuleViewModel();

  @override
  Widget build(BuildContext context) {

    //On apelle la méthode permettant de récupérer la liste des modules
    listModuleViewModel.recupererModule();

    return ListenableBuilder(

      //On écoute les changements dans la liste des modules
      listenable: listModuleViewModel,

      builder: (context,child) {

        return Column(
        
        
          children: [
        
            //Affiche Overview en gras à gauche
            Align(
              alignment: Alignment.centerLeft,
              child :
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: 
                    const Text(
                      "Accueil",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.left,
                                  
                    ),
                ),
            ), 
        
            headerAvancement(), 

            //Affiche Modules en gras à gauche
            Align(
              alignment: Alignment.centerLeft,
              child :
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  child: 
                    const Text(
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
        
            //Affichage de la liste des modules
                      
            Expanded(
              child:
              ListView.builder(
        
                //On initialise le nombre de widgets à affiché par celui de la liste des modules
                itemCount: listModuleViewModel.listModule.length,
        
                itemBuilder: (context, index) {
                  //On extraie pour chaque élément de la liste le module dans item
                  final item = listModuleViewModel.listModule[index];
        
                  //On build le widget à partir d'item
                  return listModuleItem(item, context);
                },
              ),
            ),   
        
          ],  
        );
      }
    );

  }
}

//Widget représentant l'header d'un module dans la liste des modules.
SizedBox listModuleItem(Module item, BuildContext context) {

  return SizedBox(
      child :   
      //On créer un stack pour avoir un bouton de teléchargement sur le header du module
      Stack(
        alignment: Alignment.center,
        children: [
       
        //On utilise Inkwell pour transformer notre container en bouton
        InkWell(
          child: FutureBuilder( // Permet d'attendre le calcul de progression 
                                  future: ListCoursViewModel().getProgressionModule(item), 
                                  builder: (context, snapshot) {
                                    return moduleHeader(item, snapshot.data);
                                  } ),
          //Méthode pour aller au module
          onTap: (){

            ModuleSelectionne.instance.moduleSelectionne = item;
            GoRouter.of(context).go('/module');
          }
        ),

        //Bouton de téléchargement
        Align(
          alignment: Alignment.topRight, //On aligne le bouton à doite
          child: 
            IconButton(
              //Méthode permettant de télécharger le module
              onPressed: (){

                //Ajouter méthode asset delivery

              }, 
              //Icone de telechargement
              icon: const Icon(
                Icons.download,
                color: Colors.white,
                size: 20,
                )
            ),
          ),
      ],
      ) 
    );
}

//Header affichant l'avancement dans le cours de l'utilisateur
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
                //Message d'encouragement        
                Text("Tout est possible à qui "),
                Text("rêve, ose, travaille "),
                Text("et n'abandonne jamais.")
              ],
            ),
          ),

          const Spacer(),

          //On utilise un stack pour mettre le pourcentage au dessus d'une icône
          Stack(
            alignment: Alignment.center,
            children: [
              
              //Icône : Attention ce n'est pas la bonne icône pour l'instant
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

                                    return Text("${progress}%",
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