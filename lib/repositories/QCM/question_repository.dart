import 'package:factoscope/models/QCM/question.dart';

import 'package:factoscope/database_helper.dart';

/// Repository pour gérer les opérations CRUD des Questions.
class QuestionRepository {
  /// Insère une nouvelle question dans la base de données.
  Future<int> insert(Question question) async {
    final db = await DatabaseHelper.instance.database;
    int id = await db.insert('Question', {'idQuestion': question.id});

    // Vérifie si la question est de type texte et insère les données correspondantes.
    if (question.type == 'text' && question.text != null) {
      await db.insert(
          'QuestionText', {'idQuestion': question.id, 'txt': question.text});
    }
    // Vérifie si la question est de type image et insère les données correspondantes.
    else if (question.type == 'image' &&
        question.imageUrl != null &&
        question.caption != null) {
      await db.insert('QuestionImg', {
        'idQuestion': question.id,
        'urlImage': question.imageUrl,
        'caption': question.caption
      });
    }
    return id;
  }

  /// Récupère toutes les questions.
  Future<List<Question>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('Question');
    return maps.map((map) => Question.fromMap(map)).toList();
  }

  /// Récupère une question par son identifiant et détermine son type.
  Future<Question?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    List<Map<String, dynamic>> textResult = await db
        .query('QuestionText', where: 'idQuestion = ?', whereArgs: [id]);

    // Si une entrée existe dans QuestionText, la question est de type texte.
    if (textResult.isNotEmpty) {
      Question a = Question.fromMap(textResult.first);
      a.type = "text";
      return a;
    }

    final imgResult =
        await db.query('QuestionImg', where: 'idQuestion = ?', whereArgs: [id]);

    // Si une entrée existe dans QuestionImg, la question est de type image.
    if (imgResult.isNotEmpty) {
      return Question.fromMap(imgResult.first..['type'] = 'image');
    }

    return null;
  }
}
