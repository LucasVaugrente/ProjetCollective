import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContenuTextWidget extends StatelessWidget {
  final String filePath; // Chemin vers le fichier asset

  const ContenuTextWidget({Key? key, required this.filePath}) : super(key: key);

  // Fonction pour charger le texte depuis un asset
  Future<String> _loadTextFromFile(String filePath) async {
    return await rootBundle.loadString(filePath);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _loadTextFromFile(filePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Erreur : Impossible de lire le fichier.',
              style: TextStyle(color: Color.fromRGBO(252, 179, 48, 1)),
            ),
          );
        } else {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              snapshot.data ?? '',
              style: const TextStyle(fontSize: 16.0, height: 1.5),
            ),
          );
        }
      },
    );
  }
}
