import 'package:seriouse_game/models/QCM/qcm.dart';
import 'package:seriouse_game/DataBase/database_helper.dart';

/// Repository pour gérer les opérations CRUD des QCM.
class QCMRepository {
  /// Insère un nouveau QCM dans la base de données.
  Future<int> insert(QCM qcm) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('qcm', qcm.toMap());
  }

  /// Récupère tous les QCM.
  Future<List<QCM>> getAll() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('qcm');
    return maps.map((map) => QCM.fromMap(map)).toList();
  }

  /// Récupère un QCM par son identifiant.
  Future<QCM?> getById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final maps = await db.query(
      'qcm',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return QCM.fromMap(maps.first);
    }
    return null;
  }

  /// Récupère tous les IDs des QCM d’un cours donné.
  Future<List<int>> getAllIdByCoursId(int idCours) async {
    final db = await DatabaseHelper.instance.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'qcm',
      where: "id_cours = ?",
      whereArgs: [idCours],
    );

    return maps.map((map) => map["id"] as int).toList();
  }
}
