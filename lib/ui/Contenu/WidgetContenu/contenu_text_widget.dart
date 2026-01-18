import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class ContenuTextWidget extends StatelessWidget {
  final String filePath;

  const ContenuTextWidget({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: rootBundle.loadString(filePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text("Erreur de chargement du texte");
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              snapshot.data ?? '',
              style: const TextStyle(fontSize: 16),
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
