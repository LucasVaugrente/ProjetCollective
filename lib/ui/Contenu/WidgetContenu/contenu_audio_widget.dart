// ignore_for_file: must_be_immutable

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:factoscope/ui/Contenu/contenu_cours_view_model.dart';

import 'contenu_video_widget.dart'; // Cet import sert à récupérer les fonctions de conversion de minutes en secondes déja créer dans ce fichier pour le lecteur vidéo

// ContenuAudioWidget sert à créer le widget responsable du lecteur audio de nos cours.

class ContenuAudioWidget extends StatelessWidget {
  late String urlAudio; // Url permettant de localiser le fichier audio à jouer
  late ContenuCoursViewModel
      fileLoader; // objet chargé d'initialiser le lecteur audio en utililisant les urlAudio
  late AudioPlayer player; //lecteur audio
  late bool error =
      false; // permet de gerer les erreurs remontés par le fileloader et gérer leur affichage

  //Constructeur permettant d'initialiser cette classe. Pour créer une instance de cette classe, on apelle ce constructeur de cette façon :
  //ContenuAudioWidget(data: data)
  ContenuAudioWidget({super.key, required this.urlAudio}) {
    fileLoader = ContenuCoursViewModel();
    player = AudioPlayer();
  }

  //Fonction chargée d'initialisée le lecteur audio
  Future<AudioPlayer> initAudioPlayer() async {
    try {
      //initialisation du lecteur audio par le fileloader
      player = await fileLoader.audioLoader(urlAudio);
      //Permet de faire jouer le lecteur en boucle. Attention désactiver cette option entraîne une suppression du lecteur à la fin de la lecture !
      await player.setReleaseMode(ReleaseMode.loop);
    } catch (_) {
      //Si une erreur est attrapée, c'est que le fichier audio n'as pas pu être trouvé : on indique qu'une erreur est survenue en passant error à true
      error = true;
    }
    // On retourne le lecteur pour forçer le widget à attendre la fin de l'initialisation pour être build
    return player;
  }

  //Construction du widget Audio
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return FutureBuilder(
          // On utilise FutureBuilder pour attendre la fin de l'initialisation du lecteur audio
          future: initAudioPlayer(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              //Si aucune erreur n'a été retournée à la fin de l'initialisation du lecteur audio, on construit le widget audio.
              //Voir plus bas pour le détail de cette classe
              if (!error) {
                return AudioPlayerScreen(player: player);
              } else {
                return Container(
                    //Gestion de l'espace entre le contenu et la bordure interieure du widget
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5.0),
                    //Gestion de l'espace entre l'exterieur du widget et les widgets adjacents
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    //Décoration de la bordure
                    decoration: BoxDecoration(
                      //Gestion de l'angle de la bordure
                      borderRadius: BorderRadius.circular(15),
                      //Couleur interne et externe de la boite
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(color: Colors.black, spreadRadius: 0.5),
                      ],
                    ),
                    child: const Text("Audio file not found"));
              }
              //Si jamais le lecteur n'est toujours pas chargée on affiche une progress bar
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          });
    });
  }
}

//Widget gérant le fonctionnement du lecteur audio
class AudioPlayerScreen extends StatefulWidget {
  final AudioPlayer player;

  const AudioPlayerScreen({super.key, required this.player});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState(player);
}

//State de AudioPlayerScreen
class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer player; //Lecteur audio
  bool isPlaying =
      false; // booleun indiquant si le lecteur audio est actuellement en train de jouer un son
  Duration duration =
      Duration.zero; // Variable affichant la durée de l'audio dans le widget
  Duration position = Duration
      .zero; // Variable affichant la position actuelle dans l'audio dans le widget

  _AudioPlayerScreenState(this.player);

  //Fonction permettant de récupérer la durée de l'audio auprès du lecteur
  Future<void> getDurationFromPlayer() async {
    duration = (await player.getDuration())!;
  }

  //Fonction permettant d'initialiser notre state
  @override
  void initState() {
    super.initState();

    //Initialisation de la variable duration auprès du lecteur
    getDurationFromPlayer();

    //Initialisation d'un listener pour changer la valeur de isPlaying lorsque la vidéo est mise en pause ou relancée
    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    //Initialisation d'un listener pour écouter les changement de la durée d'audio.
    //A l'heure actuelle ce widget correspond à un seul et unique fichier Audio, la valeur de duration n'est donc pas censé changée !
    player.onDurationChanged.listen((state) {
      setState(() {
        duration = state;
      });
    });

    //Initialisation d'un listener pour mettre à jour position à chaque changement de la position dans le fichier audio
    player.onPositionChanged.listen((state) {
      setState(() {
        position = state;
      });
    });
  }

  //Build du widget
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (player.source == null) {
          //Permet d'afficher un message d'erreur si la source de l'audio (contenu du fichier audio initialisé) n'existe pas
          return Container(
              //Gestion de l'espace entre le contenu et la bordure interieure du widget
              padding:
                  const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              //Gestion de l'espace entre l'exterieur du widget et les widgets adjacents
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              //Décoration de la bordure
              decoration: BoxDecoration(
                //Gestion de l'angle de la bordure
                borderRadius: BorderRadius.circular(15),
                //Couleur interne et externe de la boite
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(color: Colors.black, spreadRadius: 0.5),
                ],
              ),
              child: const Text(
                  "An unexpected error has happened : audio player is null"));
        } else {
          //Container pour afficher le widget sous la forme d'une boite arrondie
          return Container(
            //Gestion de l'espace entre le contenu et la bordure interieure du widget
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            //Gestion de l'espace entre l'exterieur du widget et les widgets adjacents
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            //Décoration de la bordure
            decoration: BoxDecoration(
              //Gestion de l'angle de la bordure
              borderRadius: BorderRadius.circular(15),
              //Couleur interne et externe de la boite
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Colors.black, spreadRadius: 0.5),
              ],
            ),

            child: Row(children: <Widget>[
              //Bouton permettant de retourner au début de la vidéo
              IconButton(
                onPressed: () {
                  setState(() {
                    player
                        .seek(Duration.zero); //remet la position du lecteur à 0
                  });
                },
                //Apparence du bouton
                icon: const Icon(
                  Icons.restart_alt_rounded,
                  color: Color.fromARGB(255, 232, 165, 99),
                  size: 20,
                ),
              ),

              //Espace entre les éléments du widget
              const Spacer(),

              //Affichage de la position de la vidéo et de sa durée
              Text(
                  '${convertToMinutesSeconds(position)} / ${convertToMinutesSeconds(duration)}'),

              //Espace entre les éléments du widget
              const Spacer(),

              //Bouton permettant de retourner 10 secondes en arrière.
              IconButton(
                  //Affichage du bouton
                  icon: const Icon(
                    Icons.replay_10,
                    color: Color.fromARGB(255, 232, 165, 99),
                  ),
                  onPressed: () {
                    //Position remise à la position actuelle du lecteur - 10
                    player.seek(position - const Duration(seconds: 10));
                  }),

              //Bouton pause

              //Apparence du cercle derrière l'icone du bouton
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color.fromARGB(255, 232, 165, 99),
                //Bouton
                child: IconButton(
                  //Choix de l'icone à afficher en fonction de si le lecteur joue l'audio ou non
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),

                  onPressed: () {
                    setState(() {
                      //Met le lecteur en pause ou relance l'audio en fonction si le lecteur était déjé en pause ou non.
                      isPlaying ? {player.pause()} : {player.resume()};
                    });
                  },
                ),
              ),

              //Bouton permettant d'avancer de 10 secondes
              IconButton(
                  //Affichage du bouton
                  icon: const Icon(
                    Icons.forward_10,
                    color: Color.fromARGB(255, 232, 165, 99),
                  ),
                  onPressed: () {
                    //Position avancée à la position actuelle du lecteur + 10
                    player.seek(position + const Duration(seconds: 10));
                  }),
            ]),
          );
        }
      },
    );
  }
}
