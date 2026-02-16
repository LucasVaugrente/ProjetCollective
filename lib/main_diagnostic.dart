import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:factoscope/service_locator.dart';
import 'data_initializer.dart';
import 'ui/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    print('🔵 main() appelé');
  }

  setupLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🔵 MainApp.build() appelé');
    }

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  String _statusMessage = 'Initialisation...';

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('🔵 SplashScreen.initState() appelé');
    }
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (kDebugMode) {
        print('🔵 Début de l\'initialisation');
      }

      setState(() {
        _statusMessage = 'Chargement des données...';
      });

      await insertSampleData();

      if (kDebugMode) {
        print('🔵 insertSampleData() terminé');
      }

      setState(() {
        _statusMessage = 'Préparation de l\'interface...';
      });

      // Petit délai pour s'assurer que tout est prêt
      await Future.delayed(const Duration(milliseconds: 300));

      if (kDebugMode) {
        print('🔵 Navigation vers l\'app principale');
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const ActualApp(),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('🔴 ERREUR lors de l\'initialisation: $e');
      }
      setState(() {
        _statusMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🔵 SplashScreen.build() appelé');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 236, 187, 139),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.school,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Titre
              const Text(
                'Factoscope',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Sous-titre
              const Text(
                'Éducation aux médias et à l\'information',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Indicateur de chargement
              if (_isLoading)
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.fromARGB(255, 236, 187, 139),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Message de statut
              Text(
                _statusMessage,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),

              // Bouton de retry en cas d'erreur
              if (!_isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _statusMessage = 'Nouvelle tentative...';
                      });
                      _initialize();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 236, 187, 139),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Réessayer'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActualApp extends StatelessWidget {
  const ActualApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🔵 ActualApp.build() appelé');
    }

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}