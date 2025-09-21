import 'package:flutter/material.dart';
import 'package:seriouse_game/DataBase/database_helper.dart';
import 'package:seriouse_game/models/cours.dart';
import 'package:seriouse_game/service_locator.dart';
import 'package:seriouse_game/services/coursService.dart';
import 'data_initializer.dart';

import 'ui/App.dart';

void main() {
  setupLocator();
  runApp(const MainApp());
  //runApp(MyApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) { 
    // FutureBuilder permet d'attendre que les données d'exemple soient insérés avant le lancement de l'UI
    return FutureBuilder<void>(
              future: insertSampleData(), // Insertion des données dans la bdd
              builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                        case ConnectionState.done: // L'insertion est fini : 
                          return MaterialApp.router( // Voir App.dart pour avoir le routeur et le 1er widget de l'app
                                //debugShowCheckedModeBanner: false,
                                routerConfig: router,
                              );

                        default: // L'insertion n'a pas fini : Page d'attente #TODO 
                          return CircularProgressIndicator();
                    }
                    
              }
    );
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


