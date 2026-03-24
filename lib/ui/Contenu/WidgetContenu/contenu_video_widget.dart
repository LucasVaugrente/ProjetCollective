import 'dart:async';
import 'package:factoscope/ui/Contenu/contenu_cours_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:factoscope/models/page.dart';
import 'package:video_player/video_player.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Widget principal — charge la vidéo et l'affiche
// ─────────────────────────────────────────────────────────────────────────────

class ContenuVideoWidget extends StatefulWidget {
  final MediaItem data;
  const ContenuVideoWidget({super.key, required this.data});

  @override
  State<ContenuVideoWidget> createState() => _ContenuVideoWidgetState();
}

class _ContenuVideoWidgetState extends State<ContenuVideoWidget> {
  late VideoPlayerController _controller;
  bool _error = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    try {
      _controller = await ContenuCoursViewModel().videoLoader(widget.data);
      await _controller.initialize();
      _controller.setLooping(true);
    } catch (_) {
      if (mounted) setState(() => _error = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    if (!_error && !_loading) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error) return const Center(child: Text("Vidéo introuvable"));

    return _VideoPlayer(controller: _controller);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lecteur portrait — vit dans le scroll normal, pas de Scaffold ici
// ─────────────────────────────────────────────────────────────────────────────

class _VideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  const _VideoPlayer({required this.controller});

  @override
  State<_VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<_VideoPlayer> {
  VideoPlayerController get _controller => widget.controller;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _duration = _controller.value.duration;
    _controller.setVolume(_volume);
    _controller.addListener(_onUpdate);
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {
      _position = _controller.value.position;
      _duration = _controller.value.duration;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onUpdate);
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  void _openFullscreen() {
    // On pousse une nouvelle route plein écran — pas de Scaffold imbriqué
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullscreenVideoPage(
          controller: _controller,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final maxMs = _duration.inMilliseconds.toDouble();
    final curMs =
        _position.inMilliseconds.toDouble().clamp(0.0, maxMs > 0 ? maxMs : 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Vidéo
        GestureDetector(
          onTap: _togglePlay,
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
        ),

        // Barre de progression
        Slider(
          value: curMs,
          min: 0,
          max: maxMs > 0 ? maxMs : 1.0,
          activeColor: Colors.red,
          thumbColor: Colors.red,
          onChanged: (v) =>
              _controller.seekTo(Duration(milliseconds: v.toInt())),
        ),

        // Contrôles
        Row(
          children: [
            IconButton(
              icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: _togglePlay,
            ),
            Icon(_volume == 0
                ? Icons.volume_mute
                : _volume < 0.5
                    ? Icons.volume_down
                    : Icons.volume_up),
            SizedBox(
              width: 80,
              child: Slider(
                value: _volume,
                min: 0,
                max: 1,
                onChanged: (v) {
                  setState(() => _volume = v);
                  _controller.setVolume(v);
                },
              ),
            ),
            const Spacer(),
            Text(_fmt(_position), style: const TextStyle(fontSize: 13)),
            Text(' / ${_fmt(_duration)}',
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.fullscreen),
              onPressed: _openFullscreen,
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Page fullscreen — vrai Scaffold autonome, poussé via Navigator
// Gère sa propre orientation, se ferme quand on repivote en portrait
// ─────────────────────────────────────────────────────────────────────────────

class _FullscreenVideoPage extends StatefulWidget {
  final VideoPlayerController controller;
  const _FullscreenVideoPage({required this.controller});

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  VideoPlayerController get _controller => widget.controller;

  bool _showControls = true;
  Timer? _hideTimer;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _duration = _controller.value.duration;
    _volume = _controller.value.volume;
    _controller.addListener(_onUpdate);

    // Passer en paysage
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _startHideTimer();
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {
      _position = _controller.value.position;
      _duration = _controller.value.duration;
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller.removeListener(_onUpdate);
    // Restaurer portrait à la fermeture
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _onTap() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
    _startHideTimer();
  }

  void _exitFullscreen() => Navigator.of(context).pop();

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final maxMs = _duration.inMilliseconds.toDouble();
    final curMs =
        _position.inMilliseconds.toDouble().clamp(0.0, maxMs > 0 ? maxMs : 1.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: Stack(
          children: [
            // Vidéo centrée
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),

            // Contrôles superposés
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                color: Colors.black38,
                child: Column(
                  children: [
                    const Spacer(),

                    // Bouton play central
                    Center(
                      child: IconButton(
                        iconSize: 64,
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          color: Colors.white,
                        ),
                        onPressed: _togglePlay,
                      ),
                    ),

                    const Spacer(),

                    // Barre du bas
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Slider(
                            value: curMs,
                            min: 0,
                            max: maxMs > 0 ? maxMs : 1.0,
                            activeColor: Colors.red,
                            thumbColor: Colors.red,
                            onChanged: (v) => _controller
                                .seekTo(Duration(milliseconds: v.toInt())),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: _togglePlay,
                              ),
                              Icon(
                                _volume == 0
                                    ? Icons.volume_mute
                                    : _volume < 0.5
                                        ? Icons.volume_down
                                        : Icons.volume_up,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 80,
                                child: Slider(
                                  value: _volume,
                                  min: 0,
                                  max: 1,
                                  onChanged: (v) {
                                    setState(() => _volume = v);
                                    _controller.setVolume(v);
                                  },
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_fmt(_position)} / ${_fmt(_duration)}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.fullscreen_exit,
                                    color: Colors.white),
                                onPressed: _exitFullscreen,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
