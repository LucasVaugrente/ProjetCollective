import 'package:seriouse_game/models/QCM/reponse.dart';

import 'package:seriouse_game/DataBase/database_helper.dart';

/// Repository pour gérer les opérations CRUD des Réponses.
class ReponseRepository {
  Future<List<Reponse>> getByQCMId(int qcmId) async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> responseMaps; 
    responseMaps = await db.query('Reponse', 
                                  where: 'idQCM = ?', whereArgs: [qcmId],
                                  orderBy: "idReponse",); // Le order est nécessaire pour l'attribut numSolution du QCM

    List<Reponse> responses = [];

    // Récupération des types pour les réponses
    for (var responseMap in responseMaps) {
      int responseId = responseMap['idReponse'];

      // Vérification si la réponse est de type texte
      final List<Map<String, dynamic>> textResponse = await db.query(
        'ReponseText',
        where: 'idReponse = ?',
        whereArgs: [responseId],
      );

      if (textResponse.isNotEmpty) {
        responses.add(Reponse(
          id: responseId,
          idQCM: qcmId,
          text: textResponse.first['txt'],
          type: "text",
        ));
        continue;
      }

      // Vérification si la réponse est de type image
      final List<Map<String, dynamic>> imageResponse = await db.query(
        'ReponseImg',
        where: 'idReponse = ?',
        whereArgs: [responseId],
      );

      if (imageResponse.isNotEmpty) {
        responses.add(Reponse(
          id: responseId,
          idQCM: qcmId,
          text: imageResponse.first['urlImage'], // Stocke l'URL de l'image
          type: "image",
        ));
      }
    }

    return responses;
  }

  /// Insère une réponse dans la base de données.
  Future<int> insert(Reponse reponse) async {
    final db = await DatabaseHelper.instance.database;
    int id = await db.insert('Reponse', {'idReponse': reponse.id, 'idQCM': reponse.idQCM});
    
    // Vérifie si la réponse est de type texte et insère les données correspondantes.
    if (reponse.type == 'text' && reponse.text != null) {
      await db.insert('ReponseText', {'idReponse': reponse.id, 'txt': reponse.text});
    } 
    // Vérifie si la réponse est de type image et insère les données correspondantes.
    else if (reponse.type == 'image' && reponse.imageUrl != null && reponse.caption != null) {
      await db.insert('ReponseImg', {'idReponse': reponse.id, 'urlImage': reponse.imageUrl, 'caption': reponse.caption});
    }
    return id;
  }
}