import 'dart:async';
import 'package:factoscope/ui/Contenu/contenu_cours_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:factoscope/models/page.dart';
import 'package:video_player/video_player.dart';

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
      final ContenuCoursViewModel fileLoader = ContenuCoursViewModel();
      _controller = await fileLoader.videoLoader(widget.data);
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
    if (_error) {
      return const Center(child: Text("Vidéo introuvable"));
    }
    return VideoPlayerScreen(controller: _controller);
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final VideoPlayerController controller;

  const VideoPlayerScreen({super.key, required this.controller});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController get _controller => widget.controller;

  Duration _videoLength = Duration.zero;
  Duration _videoPosition = Duration.zero;
  double _volume = 0.5;
  bool _isFullscreen = false;
  bool _showControls =
      true; // toujours visible en portrait mais bon... temporaire en fullscreen
  bool _hasStarted = false;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();

    _videoLength = _controller.value.duration;
    _controller.setVolume(_volume);

    _controller.addListener(_onControllerUpdate);
  }

  void _onControllerUpdate() {
    if (!mounted) return;
    setState(() {
      _videoPosition = _controller.value.position;
      _videoLength = _controller.value.duration;
    });
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _enterFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    _isFullscreen ? _enterFullscreen() : _exitFullscreen();
    if (_isFullscreen) _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _onTapFullscreen() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideControlsTimer();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
        _hasStarted = true;
      }
    });
    if (_isFullscreen) _startHideControlsTimer();
  }

  Widget _videoDisplay() {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    );
  }

  Slider _progressBar() {
    final maxVal = _videoLength.inMilliseconds.toDouble();
    final currentVal = _videoPosition.inMilliseconds
        .toDouble()
        .clamp(0.0, maxVal > 0 ? maxVal : 1.0);

    return Slider(
      value: currentVal,
      min: 0,
      max: maxVal > 0 ? maxVal : 1.0,
      thumbColor: const Color.fromARGB(255, 246, 1, 1),
      activeColor: const Color.fromARGB(255, 246, 1, 1),
      onChanged: (value) {
        _controller.seekTo(Duration(milliseconds: value.toInt()));
      },
    );
  }

  Widget _volumeControl(Color iconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_volumeIcon(_volume), color: iconColor),
        SizedBox(
          width: 90,
          child: Slider(
            value: _volume,
            min: 0,
            max: 1,
            onChanged: (val) {
              setState(() => _volume = val);
              _controller.setVolume(val);
            },
          ),
        ),
      ],
    );
  }

  IconData _volumeIcon(double vol) {
    if (vol == 0) return Icons.volume_mute;
    if (vol < 0.5) return Icons.volume_down;
    return Icons.volume_up;
  }

  IconButton _playButton(Color color) {
    return IconButton(
      icon: Icon(
        _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        size: 20,
        color: color,
      ),
      onPressed: _togglePlay,
    );
  }

  IconButton _restartButton(Color color) {
    return IconButton(
      onPressed: () => _controller.seekTo(Duration.zero),
      icon: Icon(Icons.restart_alt_rounded, color: color, size: 20),
    );
  }

  IconButton _fullscreenButton(Color color) {
    return IconButton(
      onPressed: _toggleFullscreen,
      icon: Icon(
        _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _timeDisplay(Color color) {
    return Text(
      '${_format(_videoPosition)} / ${_format(_videoLength)}',
      style: TextStyle(color: color, fontSize: 13),
    );
  }

  String _format(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    if (isPortrait && _isFullscreen) {
      setState(() => _isFullscreen = false);
      _exitFullscreen();
    }

    return isPortrait ? _buildPortrait() : _buildFullscreen();
  }

  Widget _buildPortrait() {
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _togglePlay,
          child: _videoDisplay(),
        ),
        _progressBar(),
        Row(
          children: [
            _playButton(Colors.black),
            _volumeControl(Colors.black),
            const Spacer(),
            _timeDisplay(Colors.black),
            const Spacer(),
            _restartButton(Colors.black),
            _fullscreenButton(Colors.black),
          ],
        ),
      ],
    );
  }

  Widget _buildFullscreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTapFullscreen,
        child: Stack(
          children: [
            Center(child: _videoDisplay()),
            AnimatedOpacity(
              opacity: (_showControls || !_hasStarted) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black26,
                child: Column(
                  children: [
                    const Spacer(),
                    // Bouton play central
                    Center(
                      child: IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                          size: 60,
                        ),
                        onPressed: _togglePlay,
                      ),
                    ),
                    const Spacer(),
                    // Barre du bas
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          _progressBar(),
                          Row(
                            children: [
                              _playButton(Colors.white),
                              _volumeControl(Colors.white),
                              const Spacer(),
                              _timeDisplay(Colors.white),
                              const Spacer(),
                              _restartButton(Colors.white),
                              _fullscreenButton(Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
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
