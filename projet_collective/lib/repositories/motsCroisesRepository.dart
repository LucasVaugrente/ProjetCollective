import '../DataBase/database_helper.dart';
import '../models/motsCroises.dart';

class MotsCroisesRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Créer un MotsCroises
  Future<int> create(MotsCroises motsCroises) async {
    final db = await _dbHelper.database;
    return await db.insert('MotsCroises', motsCroises.toMap());
  }

  // Lire tous les MotsCroises
  Future<List<MotsCroises>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('MotsCroises');

    return List.generate(maps.length, (i) {
      return MotsCroises.fromMap(maps[i]);
    });
  }

  // Lire un MotsCroises par son ID
  Future<MotsCroises?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'MotsCroises',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MotsCroises.fromMap(maps.first);
    }
    return null;
  }

  // Mettre à jour un MotsCroises
  Future<int> update(MotsCroises motsCroises) async {
    final db = await _dbHelper.database;
    return await db.update(
      'MotsCroises',
      motsCroises.toMap(),
      where: 'id = ?',
      whereArgs: [motsCroises.id],
    );
  }

  // Supprimer un MotsCroises
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'MotsCroises',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
