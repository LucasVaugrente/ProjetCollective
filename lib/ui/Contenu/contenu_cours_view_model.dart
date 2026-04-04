import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:factoscope/models/page.dart';
import 'package:video_player/video_player.dart';

class ContenuCoursViewModel {
  ContenuCoursViewModel();

  // Méthode permettant d'initialiser un lecteur vidéo avec l'url d'un fichier
  Future<VideoPlayerController> videoLoader(MediaItem mediaModel) async {
    if (mediaModel.type != "video") {
      throw Exception("Wrong type of ressources");
    }
    final file = File(mediaModel.url);
    if (!await file.exists()) {
      throw Exception("Fichier vidéo introuvable : ${mediaModel.url}");
    }
    return VideoPlayerController.file(file);
  }

  // Méthode permettant d'initialiser un lecteur audio
  Future<AudioPlayer> audioLoader(String urlAudio) async {
    final player = AudioPlayer();
    final file = File(urlAudio);

    if (!await file.exists()) {
      throw Exception("Fichier audio introuvable : $urlAudio");
    }

    await player.setSource(DeviceFileSource(urlAudio));
    return player;
  }

  String? imageLoader(MediaItem data) {
    if (data.type == "image") {
      return data.url;
    }
    return null;
  }
}
