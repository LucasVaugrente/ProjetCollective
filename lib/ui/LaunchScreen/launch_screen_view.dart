import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class LaunchScreenView extends StatefulWidget {
  const LaunchScreenView({super.key});

  @override
  _LaunchScreenViewState createState() => _LaunchScreenViewState();
}

class _LaunchScreenViewState extends State<LaunchScreenView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _offsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.5),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    Future.delayed(const Duration(seconds: 2), () {
      _controller.forward();
    });
    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          color: const Color.fromRGBO(252, 179, 48, 1),
          child: Center(
            child: SlideTransition(
              position: _offsetAnimation,
              child: SizedBox(
                width: 250,
                height: 250,
                child: Image.asset(
                  'lib/data/AppData/CharteFactoscope/logo-factoscope.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    } catch (e) {
      if (kDebugMode) {
        print("Erreur lors du chargement du QCM : $e");
      }
      return const Text("aa");
    }
    
  }
}
