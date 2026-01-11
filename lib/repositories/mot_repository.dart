import '../models/mot.dart';
import '../database_helper.dart';

class MotRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Créer un Mot
  Future<int> create(Mot mot) async {
    final db = await _dbHelper.database;
    return await db.insert('Mot', mot.toMap());
  }

  // Lire tous les Mots
  Future<List<Mot>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('Mot');

    return List.generate(maps.length, (i) {
      return Mot.fromMap(maps[i]);
    });
  }

  // Lire un Mot par son ID
  Future<Mot?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Mot',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Mot.fromMap(maps.first);
    }
    return null;
  }

  // Mettre à jour un Mot
  Future<int> update(Mot mot) async {
    final db = await _dbHelper.database;
    return await db.update(
      'Mot',
      mot.toMap(),
      where: 'id = ?',
      whereArgs: [mot.id],
    );
  }

  // Supprimer un Mot
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'Mot',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<List<Mot>> getMotsByMotsCroisesId(int motsCroisesId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'Mot',
      where: 'id_motscroises = ?',
      whereArgs: [motsCroisesId],
    );

    return result.map((map) => Mot.fromMap(map)).toList();
  }

}
