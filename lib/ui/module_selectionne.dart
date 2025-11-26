import 'package:flutter/material.dart';
import 'package:factoscope/models/cours.dart';
import 'package:factoscope/models/module.dart';

//Singleton représentant le module sélectionné par l'utilisateur et les données qu'il contient.
class ModuleSelectionne with ChangeNotifier {

  Module moduleSelectionne = Module(titre: "titre",urlImg: "", description: "description",id: 1);

  static final ModuleSelectionne instance = ModuleSelectionne._internal() ;

  //Liste contenant les cours d'un module
  List<Cours> coursDuModule = List.empty() ;
  
  static ModuleSelectionne getInstance(){

    return instance;

  }

  factory ModuleSelectionne() {
    return instance;
  }


  ModuleSelectionne._internal();

  //Permet de modifier le module selectionné tout en avertissant les listeners
  void changeModule(Module module){

    moduleSelectionne = module;
    notifyListeners();

  }

  //Permet de mettre à jour la liste des cours du module
  void updateListModule(List<Cours> listCours){
    coursDuModule = listCours;
    notifyListeners();
  }

}