import 'package:seriouse_game/models/QCM/qcm.dart';

import 'package:seriouse_game/repositories/QCM/QuestionRepository.dart';
import 'package:seriouse_game/repositories/QCM/ReponseRepository.dart';
import 'package:seriouse_game/DataBase/database_helper.dart';

/// Repository pour gérer les opérations CRUD des QCM.
class QCMRepository {
  /// Insère un nouveau QCM dans la base de données.
  Future<int> insert(QCM qcm) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('QCM', qcm.toMap());
  }

  /// Récupère tous les QCM.
  Future<List<QCM>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('QCM');
    return maps.map((map) => QCM.fromMap(map)).toList();
  }

  /// Récupère un QCM par son identifiant et complète ses listes de questions et réponses.
  Future<QCM?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query('QCM', where: 'idQCM = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      QCM qcm = QCM.fromMap(maps.first);

      final questionRepo = QuestionRepository();
      qcm.question = await questionRepo.getById(qcm.idQuestion);

      final reponseRepo = ReponseRepository();
      qcm.reponses = await reponseRepo.getByQCMId(qcm.id);
      
      return qcm;
    }
    return null;
  }
}