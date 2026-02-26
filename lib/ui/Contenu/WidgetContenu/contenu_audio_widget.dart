import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:factoscope/ui/Contenu/contenu_cours_view_model.dart';

class ContenuAudioWidget extends StatefulWidget {
  final String urlAudio;

  const ContenuAudioWidget({super.key, required this.urlAudio});

  @override
  State<ContenuAudioWidget> createState() => _ContenuAudioWidgetState();
}

class _ContenuAudioWidgetState extends State<ContenuAudioWidget> {
  late ContenuCoursViewModel fileLoader;
  late AudioPlayer player;
  bool error = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fileLoader = ContenuCoursViewModel();
    player = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      player = await fileLoader.audioLoader(widget.urlAudio);
      await player.setReleaseMode(ReleaseMode.loop);
    } catch (_) {
      if (mounted) setState(() => error = true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
    borderRadius: BorderRadius.circular(15),
    color: Colors.white,
    border: Border.all(
      color: const Color.fromARGB(255, 3, 47, 122),
      width: 3,
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: _cardDecoration,
        child: const Text("Audio file not found"),
      );
    }

    return AudioPlayerScreen(player: player, cardDecoration: _cardDecoration);
  }
}

class AudioPlayerScreen extends StatefulWidget {
  final AudioPlayer player;
  final BoxDecoration cardDecoration;

  const AudioPlayerScreen({
    super.key,
    required this.player,
    required this.cardDecoration,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  AudioPlayer get player => widget.player;

  @override
  void initState() {
    super.initState();

    player.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => isPlaying = state == PlayerState.playing);
    });

    player.onDurationChanged.listen((d) {
      if (mounted) setState(() => duration = d);
    });

    player.onPositionChanged.listen((p) {
      if (mounted) setState(() => position = p);
    });

    // Récupère la durée initiale si déjà dispo
    player.getDuration().then((d) {
      if (d != null && mounted) setState(() => duration = d);
    });
  }

  void _seekBy(Duration offset) {
    final newPos = position + offset;
    final clamped = newPos < Duration.zero
        ? Duration.zero
        : (newPos > duration ? duration : newPos);
    player.seek(clamped);
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: widget.cardDecoration,
      child: Column(
        children: [
          // Barre de progression
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color.fromRGBO(252, 179, 48, 1),
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: const Color.fromRGBO(252, 179, 48, 1),
              overlayColor:
              const Color.fromRGBO(252, 179, 48, 1).withValues(alpha: 0.2),
              trackHeight: 3.0,
              thumbShape:
              const RoundSliderThumbShape(enabledThumbRadius: 6.0),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (value) {
                final newPos =
                Duration(milliseconds: (value * duration.inMilliseconds).round());
                player.seek(newPos);
              },
            ),
          ),
          // Contrôles
          Row(
            children: [
              // Restart
              IconButton(
                onPressed: () => player.seek(Duration.zero),
                icon: const Icon(
                  Icons.restart_alt_rounded,
                  color: Color.fromRGBO(252, 179, 48, 1),
                  size: 20,
                ),
              ),
              const Spacer(),
              // Timer
              Text(
                '${_format(position)} / ${_format(duration)}',
                style: const TextStyle(fontSize: 12),
              ),
              const Spacer(),
              // -10s
              IconButton(
                icon: const Icon(
                  Icons.replay_10,
                  color: Color.fromRGBO(252, 179, 48, 1),
                ),
                onPressed: () => _seekBy(const Duration(seconds: -10)),
              ),
              // Play/Pause
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color.fromRGBO(252, 179, 48, 1),
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: () =>
                  isPlaying ? player.pause() : player.resume(),
                ),
              ),
              // +10s
              IconButton(
                icon: const Icon(
                  Icons.forward_10,
                  color: Color.fromRGBO(252, 179, 48, 1),
                ),
                onPressed: () => _seekBy(const Duration(seconds: 10)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}