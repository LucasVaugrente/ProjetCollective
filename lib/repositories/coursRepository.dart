import '../DataBase/database_helper.dart';
import '../models/cours.dart';

class CoursRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Créer une Cours
  Future<int> create(Cours cours) async {
    final db = await _dbHelper.database;
    return await db.insert('Cours', cours.toMap());
  }

  // Lire toutes les Courss
  Future<List<Cours>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Cours');

    return List.generate(maps.length, (i) {
      return Cours.fromMap(maps[i]);
    });
  }

  // Lire une Cours par son ID
  Future<Cours?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Cours',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Cours.fromMap(maps.first);
    }
    return null;
  }

  // Mettre à jour une Cours
  Future<int> update(Cours cours) async {
    final db = await _dbHelper.database;
    return await db.update(
      'Cours',
      cours.toMap(),
      where: 'id = ?',
      whereArgs: [cours.id],
    );
  }

  // Supprimer une Cours
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'Cours',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Cours>> getCoursesByModuleId(int moduleId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'Cours',
      where: 'id_Module = ?',
      whereArgs: [moduleId],
    );
    return result.map((map) => Cours.fromMap(map)).toList();
  }

}
