import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:seriouse_game/models/mediaCours.dart';
import 'package:video_player/video_player.dart';
import 'package:seriouse_game/repositories/mediaCoursRepository.dart';
import 'package:seriouse_game/repositories/pageRepository.dart';
import 'package:seriouse_game/models/cours.dart';

class ContenuCoursViewModel {
  ContenuCoursViewModel();

  //Méthode permettant d'initialiser un lecteur vidéo avec l'url d'un fichier contenue dans mediaModel (MediaCours)
  Future<VideoPlayerController> VideoLoader(MediaCours mediaModel) async {

      //On initialise le controller à renvoyer
      late VideoPlayerController controller;

      //On teste si le type de média est bien celui voulu
      if(mediaModel.type!="video"){
        throw Exception("Wrong type of ressources");
      }

      //On vérifie si le fichier vidéo correspondant à l'url de mediaModel existe
      try {
        
        await rootBundle.load(mediaModel.url);
                  
      } on Exception {
        rethrow;
      }

      //On initialise et retourne le controller vidéo
      controller = VideoPlayerController.asset(mediaModel.url);

      return controller ;

  }

  //Méthode permettant d'initialiser un lecteur audio avec l'url d'un fichier contenue dans un modèle.
  Future<AudioPlayer> AudioLoader(String urlAudio) async {

    /*
    //Teste si le modèle envoyée est bien un modèle prévu pour un fichier Audio. Sinon on renvoie une erreur.
    if(mediaModel.type!="audio"){
      throw Exception("Wrong type of ressources");
    }
    */

    //Création du lecteur audio
    final player = AudioPlayer();
    //Par défaut AudioPlayer cherche les fichiers audios dans le dossier assets.
    //N'utilisant pas de dossier de ce non dans notre arborescence, nous supprimons le prefix assets de la recherche 
    player.audioCache = AudioCache(prefix: '');

    try {
      //On tente de récupérer le fichier dans nos fichiers. Si une erreur est levée, c'est que le fichier n'existe pas (url incorrecte)
      //Nous ne pouvons pas chercher directement si le fichier existe : les méthodes de Dart le permettant ne fonctionnent pas bien sous Android
       await rootBundle.load(urlAudio);
    } catch(_) {
      rethrow;
    }

    //On attend que le lecteur initialise notre fichier comme sa source.
    await player.setSource(AssetSource(urlAudio));
  
    //On retourne le lecteur audio
    return player;

  }

  String? imageLoader(MediaCours data) {
    if (data.type == "image") {
      return data.url; // Retourne le chemin du fichier image
    }
    return null; // Retourne null si ce n'est pas une image
  }
}


