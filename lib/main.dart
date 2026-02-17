import 'package:flutter/material.dart';
import 'package:factoscope/service_locator.dart';
import 'data_initializer.dart';

import 'ui/app.dart';

void main() {
  setupLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: insertSampleData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return MaterialApp.router(
              routerConfig: router,
              debugShowCheckedModeBanner: false,
            );
          } else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                backgroundColor: Colors.white,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.school,
                        size: 80,
                        color: Color.fromARGB(255, 236, 187, 139),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Factoscope',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 40),
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
                      const Text(
                        'Chargement...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      // Message d'erreur si problème
                      if (snapshot.hasError)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Erreur: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Insérer des données d'exemple après le lancement de l'UI
    Future.delayed(Duration.zero, () async {
      await insertSampleData();

      //await testRepositories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Courses List"),
        ),
        body: const Center(
          child: Text("Hello"),
        ),
      ),
    );
  }
}
