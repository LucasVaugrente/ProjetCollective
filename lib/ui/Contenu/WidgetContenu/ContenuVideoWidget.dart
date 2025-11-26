// ignore_for_file: must_be_immutable
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seriouse_game/models/mediaCours.dart';
import 'package:seriouse_game/ui/Contenu/ContenuCoursViewModel.dart';
import 'package:video_player/video_player.dart';

//Classe chargée de build un widget vidéo à partir des données contenues dans un MediaCours
class ContenuVideoWidget extends StatelessWidget {

  late MediaCours data;//Les données correspondant à la vidéo à charger
  late ContenuCoursViewModel fileLoader;// objet chargé d'initialiser le lecteur vidéo en utililisant les données de data
  late VideoPlayerController controller;//Lecteur vidéo
  bool error = false;// permet de gerer les erreurs remontés par le fileloader et gérer leur affichage

  //Constructeur permettant d'initialiser cette classe. Pour créer une instance de cette classe, on apelle ce constructeur de cette façon :
  //ContenuVideoWidget(data: data)
  ContenuVideoWidget({super.key, required this.data}){
    fileLoader = ContenuCoursViewModel();
  }

  //Méthode chargée d'initialisée le lecteur vidéo
  Future<bool> initController() async {

    //Création d'un lecteur vidéo vide pour éviter une erreur de variable non initialisée. 
    //Cette valeur ne sera cependant jamais utilisé.
    //Il n'existe aucune méthode permettant de créer un VideoPlayerController sans lui passer une ressource
    controller = VideoPlayerController.asset("");

    //Le code suivant va tenter de changer la valeur de notre lecteur vidéo avec les données contenues dans data.
    //Si aucun fichier ne correspond aux données transmises, on change la valeur de "error" à true
    try {
      //On apelle fileloader pour extraire la vidéo de notre système de fichier
      controller = await fileLoader.VideoLoader(data);
    } catch(_) {
      error = true;
    }
    //On retourne error à la fin pour forçer le widget à attendre la fin de l'initialisation.
    return error;

  }

  @override
  Widget build(BuildContext context) {
  
    //Ici FutureBuilder nous permet d'attendre la fin de notre initialisation pour build le widget.
    return FutureBuilder(
          future: initController(),//Indique que l'ont doit attendre le retour de la valeur de initController pour build le widget.
          builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                //Si aucune erreur n'as été reporté durant l'initialisation du lecteur, alors on build une instance de VideoPlayerScreen, widget permettant de jouer la vidéo
                if(!error){
                  return LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                   return VideoPlayerScreen(controller: controller);
                  });
                //En cas d'erreur, on indique qu'aucun fichier vidéo n'as été trouvé.
                }else {
                  return const Scaffold(
                    body: Center(
                      child: 
                      SizedBox(
                        child: Text("Video file not found"),
                      )
                    )
            
                  );
                }
              //Affiche un ecran de chargement tant que le lecteur vidéo n'est pas prêt.
              }else{
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
                
      }
      
    );
  }
}

//Widget affichant la vidéo à l'écran
class VideoPlayerScreen extends StatefulWidget {

  //Lecteur vidéo
  final VideoPlayerController controller;

  const VideoPlayerScreen({Key? key, required this.controller}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState(controller);
}

//State du widget d'affichage de la vidéo
class _VideoPlayerScreenState extends State<VideoPlayerScreen> {

  late VideoPlayerController _controller;//Lecteur vidéo
  late Future<void> _initializeVideoPlayerFuture;//Future lié à l'initialisation de la lecture de la vidéo. 
  //Sert par la suite à synchronizer le build du widget à la fin de l'initialisation

  Duration videoLength = const Duration();//Durée de la vidéo
  Duration videoPosition = const Duration();//Position actuelle dans la vidéo

  bool errorLoadingVideo = false;//Indique si une erreur à été s'est produite lors du lancement de la vidéo.
  double volume = 0.5;//Volume sonore de la vidéo

  bool isFullscreen = false;//Indique si la vidéo est en plein écran ou non.

  //Indique si les boutons du mode fullscreen doivent être visibles ou non
  //Lorsque la vidéo est jouée en plein écran aucun bouton n'est visible tant que l'utilisateur ne touche pas à l'écran.
  bool fullscreenWidgetButtons = false;
  bool HasVideoNotStarted = true;//Indique si la vidéo à déjà commencé à jouer au moins une fois.

  _VideoPlayerScreenState(VideoPlayerController controller){
    _controller = controller;
  }

  //Méthode gérant le timer permettant de maintenir l'affichage des boutons en plein écran 3 secondes après que l'utilisateur ait touché l'écran.
  void startTimerWidgetFullscreen() {
    fullscreenWidgetButtons = true;
    Timer(const Duration(seconds: 3), handleTimeoutWidgetFullscreen);
  }

  //Passe fullscreenWidgetButtons à 'false' pour permettre de désactiver l'affichage des boutons une fois le timer de startTimerWidgetFullscreen terminé
  void handleTimeoutWidgetFullscreen() { 
    fullscreenWidgetButtons = false;
  }

  @override
  //Initialisation de notre State. 
  //Va permettre d'initialiser toutes les variables liées au lecteur vidéo
  void initState() {

    super.initState();

    //On tente de charger la vidéo contenue dans le fichier passer au lecteur.
    try {
      _initializeVideoPlayerFuture = _controller.initialize().then((_) => setState(() {
          
            try {
              //On initialise la valeur de la durée de la vidéo
              videoLength = _controller.value.duration;
            }catch (_) {
              errorLoadingVideo = true;
            }
          }));

      //Si la vidéo a pu être chargée, on active la lecture en boucle
      _controller.setLooping(true);

      //Ajout de deux listener : 
      //L'un permet de synchroniser notre variable videoPosition à la position dans la vidéo.
      //Le deuxième permet de détecter si une erreur survient lors de la lecture de la vidéo.
      _controller.addListener(() => setState(() {
            videoPosition = _controller.value.position;
            errorLoadingVideo = _controller.value.hasError;
          }));

    }catch (_) {
      errorLoadingVideo = true;
    }
  }

  //Méthode permettant de détruire le lecteur vidéo à la destruction du widget.
  @override
  void dispose() {
    
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    //En cas d'erreur lors du chargement de la vidéo, on affiche un message d'erreur à l'écran.
    if(errorLoadingVideo){
      return (
          const Scaffold(
            body: Center(
              child: 
              SizedBox(
                child: Text("Video can't be loaded"),
              )
            )
            
          )
        );
    }else {

      //On detecte si l'ecran est au format portrait ou paysage
      //L'apparence et les interactions avec le widget sont différentes en fonction de l'orientation(mode normal/plein écran)
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        exitFullScreen();//Méthode permettant de quitter le plein ecran et changer l'orientation en portrait
        isFullscreen = false;//On indique que l'on est plus en plein écran.
        return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
                return Column(
                  
                  children: <Widget>[

                      //On utilise un gesture detector pour detecter si l'utilisateur appuie sur l'écran, et mettre la vidéo en pause ou la relancer.
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        //Si la vidéo est en train d'être jouer, on met en pause, sinon on relance la vidéo.
                        onTap: () =>
                          _controller.value.isPlaying ? _controller.pause() : _controller.play(),
                        child:
                          //Widget d'affichage de la vidéo
                          videoScreen()
                      ),        
                        
                        //Barre de progression indiquant la position dans la vidéo (cf barre rouge de youtube)
                        progressBarVideo(),
                  Row(               
                    children : <Widget>[
                            //Bouton Lecture/Pause : 
                            playButton(Colors.black),

                            //Affichage icône pour le volume sonore.
                            //animatedVolumeIcon est une fonction renvoyant une icône differente en fonction du niveau sonore.
                            Icon(animatedVolumeIcon(volume)),

                            //Barre gérant le volume sonore
                            volumeSlider(),
        
                            //Créer un espace entre les boutons de l'interface
                            const Spacer(),
                            
                            //Affiche la position de la vidéo sur le temps restant en minute & secondes.
                            Text(
                              '${convertToMinutesSeconds(videoPosition)} / ${convertToMinutesSeconds(videoLength)}'),
                              const SizedBox(width: 10),

                            //Créer un espace entre les boutons de l'interface
                            const Spacer(),

                            //Bouton permettant de revenir au début de la lecture de la vidéo
                            returnToStart(Colors.black),
        
                            
                            //Bouton permettant de passer en mode plein écran
                            fullscreenButton(Colors.black)
                          ],
                      ),
                ],
              
              
              );
            }
            
            );
      }else{
        //On apelle la méthode pour entrer en fullscreen si l'orientation paysage est détectée
        enterFullScreen();
        //On indique que l'on est en plein écran
        isFullscreen = true;
        return (
          Scaffold(
            body: Center(
              child: 
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) { 
                    //Stack va nous permettre d'avoir une interface flottante par dessus la vidéo (pour nos boutons)
                    //Cette interface ne sera affichée que temporairement après un appui de l'utilisateur
                    return Stack(
                            children: <Widget>[
                              SizedBox(
                                //Force la vidéo à prendre la taille maximul allouée par le widget parent si cette taille n'est pas inférieure à la taille miniumum du controleur
                                height: constraints.maxHeight,
                                width: constraints.maxWidth,
                                child : 
                                  //Permet de detecter que l'utilisateur appuie sur l'écran
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    //Si l'interface est déja affichée , on la cache, sinon on lance le timer et leur affichage
                                    onTap: () => {
                                      fullscreenWidgetButtons ? fullscreenWidgetButtons = false : startTimerWidgetFullscreen(),
                                    },
                                    child:
                                      //On affiche la vidéo
                                      videoScreen() 
                                  ), 
                                                
                             
                              ),
                              //Widget visible seulement sous certaines conditions.
                              //Il représente l'interface sur la vidéo (similaire à ytb : boutons, bar de progression, ect...)
                              Visibility(
                                maintainSize: true, 
                                maintainAnimation: true,
                                maintainState: true,
                                //Le widget n'est visible que si les boutons sont activés (fullscreenWidgetButton) par un appui utilisateur
                                //On a cependant ajouté une condition supplémentaire : si la vidéo n'est pas encore lancée l'interface est visible
                                //Cette condition est nécessaire car tant qu'elle ne sera pas lancé, le GestureDetector contenant le lecteur ne fonctionne pas
                                //Cela est du au contrôleur de la vidéo controller.
                                //Il s'agit de la seule utilité de la variable HasVideoNotStarted
                                visible: fullscreenWidgetButtons || HasVideoNotStarted,
                                child:

                                  Column(
                                    children: [

                                      const Spacer(),

                                      //Bouton Play/Pause au centre de l'écran. 
                                      Align(
                                        alignment: Alignment.center,
                                        child: SizedBox(
                                          width: 70,
                                          height: 70,
                                          child: IconButton(
                                                          icon: Icon(_controller.value.isPlaying
                                                              ? Icons.pause
                                                              : Icons.play_arrow),
                                                              color: Colors.white,
                                                              iconSize: 70,

                                                          onPressed: () {
                                                            setState(() {
                                                              _controller.value.isPlaying
                                                                  ? _controller.pause()
                                                                  : {_controller.play(), HasVideoNotStarted = false};
                                                            }
                                                            
                                                            );
                                                            startTimerWidgetFullscreen();
                                                          },
                                                        ),

                                        ),
                                      ),

                                      const Spacer(),
                                      
                                      //Interface en bas de l'écran. Elle est similaire à celle en mode portrait
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                          child : SizedBox(
                                            //Les ratios utilisés ici sont fait pour tenir dans l'écran avec le header et le footer de l'app
                                            width: constraints.maxWidth,
                                            height : 110,
                                            child: 
                                              Column(
                                                  children: [
                                                    //Bar de progression style ytb
                                                    progressBarVideo(),
                                                    Row(
                                                      
                                                      children : <Widget>[
                                                          //Bouton play/Pause
                                                          playButton(Colors.white),

                                                          //Volume              
                                                          Icon(animatedVolumeIcon(volume),
                                                                color: Colors.white),
                                                                        
                                                          volumeSlider(),
                                                                        
                                                          const Spacer(),
                                                          
                                                          //Affichage position de la vidéo/durée totale de la vidéo
                                                          Text(
                                                            '${convertToMinutesSeconds(videoPosition)} / ${convertToMinutesSeconds(videoLength)}',
                                                              style : const TextStyle(
                                                                  fontSize: 15.0,
                                                                  color: Colors.white,
                                                                ),
                                                              ),
                                        
                                                          const Spacer(),

                                                          //Bouton restart              
                                                          returnToStart(Colors.white),

                                                          //Bouton de gestion passage entre portrait et plein écran                               
                                                          fullscreenButton(Colors.white)
                                                        ],
                                                    ),
                                                  ],
                                              ),
                                          ),
                                        ),
                                    ],
                                  ), 
                              ), 
                        ]          
                    );        
                }
              )
            )
            
          )
        );
      }
  }}

  //Bouto permettant de changer entre plein ecran(paysage) et portrait
  IconButton fullscreenButton(Color color){
      return IconButton(
                              onPressed: () {
                                //On teste si on est en plein écran ou non
                                //Si oui, on passe isFullscreen à false, on change l'orientation de l'appli en portrait, et on rétablit ensuite toutes les rotations (les rotations sont bloquées en fullscreen)
                                //Si non, on passe isFullscreen à true et on passe en paysage. On active également le timer startTimerWidgetFullscreen pour que l'interface soit visible 3 secondes après le changement d'orientation.
                                  isFullscreen 
                                  ? {isFullscreen = false, exitFullScreen(), SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),enableRotation()}
                                  : {isFullscreen = true, enterFullScreen(), SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft,DeviceOrientation.landscapeRight]),startTimerWidgetFullscreen()};
                              }, 
                              icon: Icon(
                                Icons.fullscreen,
                                color: color,
                                size: 20,
                              ),
                            );
  }

  //Bouton permettant de revenir au début de la lecture de la vidéo
  IconButton returnToStart(Color color){
    return IconButton(
      //On change la position du lecteur vidéo à 0.
      onPressed: () {
        setState(() {
          _controller.seekTo(Duration.zero);
        });
      }, 
      icon: Icon(
        Icons.restart_alt_rounded,
        color: color,
        size: 20,
      ),
    );
  }
  //Barre gérant le volume sonore
  SizedBox volumeSlider(){
     
    return  SizedBox(
               width: 100,
               child: Slider(
                  value: volume,
                  min: 0,
                  max: 1,
                  //Code changeant le volume quand la barre est manipulée par l'utilisateur :
                  onChanged: (_volume) => setState(() {
                    volume = _volume;
                    _controller.setVolume(_volume);
                                  
                  }
                ),
              ),
          );
  }
  //Bouton Lecture/Pause : 
  IconButton playButton(Color color){
    return 
      IconButton(
      //Icone change en fonction de si la vidéo est en pause ou non :
        icon: Icon(_controller.value.isPlaying
        ? Icons.pause
        : Icons.play_arrow,
        size: 20,
        color: color,),
        
        //Si le lecteur joue la vidéo, on la met en pause, sinon on la joue.
        //On met également HasVideoNotStarted à false si on joue la vidéo
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
            ? _controller.pause()
            : {_controller.play(), HasVideoNotStarted = false};
          });
          if(isFullscreen){
            startTimerWidgetFullscreen();
          }
        },
      );
  }

  //Barre de progression indiquant la position dans la vidéo (cf barre rouge de youtube)
  Slider progressBarVideo(){
    return Slider(
      //Variable indiquant la valeur actuelle de la progression (position dans la vidéo)
      value: videoPosition.inSeconds.toDouble(),
      min: 0,
      //La valeur maximale de cette barre est la durée de la vidéo
      max: videoLength.inSeconds.toDouble(),

      thumbColor: const Color.fromARGB(255, 246, 1, 1),
      activeColor: const Color.fromARGB(255, 246, 1, 1),

      //Code appliqué lorsque l'utilisateur appuie et change la valeur de la barre :   
      onChanged: (_videoPosition) => setState(() {
        //Code permettant de déplacer la position de la vidéo à celle de la barre :
        videoPosition = Duration.zero + Duration(seconds: _videoPosition.toInt());
        _controller.seekTo(videoPosition);
                                              
        }
      ),
    );
  }
  //FutureBuilder permettant d'attendre la fin du chargement de la vidéo pour l'afficher
  FutureBuilder videoScreen(){
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          //Affichage de la vidéo :          
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
                                        
            child: VideoPlayer(_controller),
          );
        } else {
        //Affichage d'un écran de chargement si la vidéo n'est pas chargée.            
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

    
}

//Permet de convertir un objet Duration en une string représentant sa durée en minute,secondes.
String convertToMinutesSeconds(Duration duration) {
  final parsedMinutes = duration.inMinutes < 10
      ? '0${duration.inMinutes}'
      : duration.inMinutes.toString();

  final seconds = duration.inSeconds % 60;

  final parsedSeconds =
      seconds < 10 ? '0${seconds % 60}' : (seconds % 60).toString();
  return '$parsedMinutes:$parsedSeconds';
}

//Fonction permettant de renvoyer une icone de volume différente en fonction d'une valeur entre 0 et ArchiveBestPattern2QCM.
IconData animatedVolumeIcon(double volume) {
  if (volume == 0) {
    return Icons.volume_mute;
  } else if (volume < 0.5){
    return Icons.volume_down;
  }else{
    return Icons.volume_up;
  }
}

//Change l'orientation de l'application pour mettre en plein ecran
void enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
}

//Change l'orientation de l'application pour mettre en portrait
void exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
}

//Fixe l'orientation préférée de l'appareil à toutes les rotations possibles pour les rétablir.
void enableRotation() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}
