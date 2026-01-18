// ignore_for_file: must_be_immutable

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:factoscope/ui/Contenu/contenu_cours_view_model.dart';
import 'contenu_video_widget.dart';

class ContenuAudioWidget extends StatelessWidget {
  late String urlAudio;
  late ContenuCoursViewModel fileLoader;
  late AudioPlayer player;
  late bool error = false;

  ContenuAudioWidget({super.key, required this.urlAudio}) {
    fileLoader = ContenuCoursViewModel();
    player = AudioPlayer();
  }

  Future<AudioPlayer> initAudioPlayer() async {
    try {
      player = await fileLoader.audioLoader(urlAudio);
      await player.setReleaseMode(ReleaseMode.loop);
    } catch (_) {
      error = true;
    }
    return player;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return FutureBuilder(
              future: initAudioPlayer(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (!error) {
                    return AudioPlayerScreen(player: player);
                  } else {
                    return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 5.0),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(color: Colors.black, spreadRadius: 0.5),
                          ],
                        ),
                        child: const Text("Audio file not found"));
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              });
        });
  }
}

class AudioPlayerScreen extends StatefulWidget {
  final AudioPlayer player;

  const AudioPlayerScreen({super.key, required this.player});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioPlayer player;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  Future<void> getDurationFromPlayer() async {
    duration = (await player.getDuration())!;
  }

  @override
  void initState() {
    super.initState();
    player = widget.player;

    getDurationFromPlayer();

    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    player.onDurationChanged.listen((state) {
      setState(() {
        duration = state;
      });
    });

    player.onPositionChanged.listen((state) {
      setState(() {
        position = state;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (player.source == null) {
          return Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
              margin:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(color: Colors.black, spreadRadius: 0.5),
                ],
              ),
              child: const Text(
                  "An unexpected error has happened : audio player is null"));
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(color: Colors.black, spreadRadius: 0.5),
              ],
            ),
            child: Row(children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    player.seek(Duration.zero);
                  });
                },
                icon: const Icon(
                  Icons.restart_alt_rounded,
                  color: Color.fromARGB(255, 232, 165, 99),
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                  '${convertToMinutesSeconds(position)} / ${convertToMinutesSeconds(duration)}'),
              const Spacer(),
              IconButton(
                  icon: const Icon(
                    Icons.replay_10,
                    color: Color.fromARGB(255, 232, 165, 99),
                  ),
                  onPressed: () {
                    player.seek(position - const Duration(seconds: 10));
                  }),
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color.fromARGB(255, 232, 165, 99),
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      isPlaying ? {player.pause()} : {player.resume()};
                    });
                  },
                ),
              ),
              IconButton(
                  icon: const Icon(
                    Icons.forward_10,
                    color: Color.fromARGB(255, 232, 165, 99),
                  ),
                  onPressed: () {
                    player.seek(position + const Duration(seconds: 10));
                  }),
            ]),
          );
        }
      },
    );
  }
}