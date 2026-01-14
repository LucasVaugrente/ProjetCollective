import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:factoscope/models/page.dart';  // ✅ Import corrigé
import 'package:video_player/video_player.dart';

class ContenuCoursViewModel {
  ContenuCoursViewModel();

  // Méthode permettant d'initialiser un lecteur vidéo avec l'url d'un fichier
  Future<VideoPlayerController> videoLoader(MediaItem mediaModel) async {
    late VideoPlayerController controller;

    // On teste si le type de média est bien celui voulu
    if (mediaModel.type != "video") {
      throw Exception("Wrong type of ressources");
    }

    // On vérifie si le fichier vidéo existe
    try {
      await rootBundle.load(mediaModel.url);
    } on Exception {
      rethrow;
    }

    // On initialise et retourne le controller vidéo
    controller = VideoPlayerController.asset(mediaModel.url);
    return controller;
  }

  // Méthode permettant d'initialiser un lecteur audio
  Future<AudioPlayer> audioLoader(String urlAudio) async {
    // Création du lecteur audio
    final player = AudioPlayer();
    // Par défaut AudioPlayer cherche les fichiers audios dans le dossier assets
    player.audioCache = AudioCache(prefix: '');

    try {
      await rootBundle.load(urlAudio);
    } catch (_) {
      rethrow;
    }

    await player.setSource(AssetSource(urlAudio));
    return player;
  }

  String? imageLoader(MediaItem data) {
    if (data.type == "image") {
      return data.url;
    }
    return null;
  }
}