import '../database_helper.dart';
import '../models/mini_jeu.dart';

class MiniJeuRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Créer un MiniJeu
  Future<int> create(MiniJeu miniJeu) async {
    final db = await _dbHelper.database;
    return await db.insert('MiniJeu', miniJeu.toMap());
  }

  // Lire tous les MiniJeux
  Future<List<MiniJeu>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('MiniJeu');

    return List.generate(maps.length, (i) {
      return MiniJeu.fromMap(maps[i]);
    });
  }

  // Lire un MiniJeu par son ID
  Future<MiniJeu?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'MiniJeu',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return MiniJeu.fromMap(maps.first);
    }
    return null;
  }

  // Mettre à jour un MiniJeu
  Future<int> update(MiniJeu miniJeu) async {
    final db = await _dbHelper.database;
    return await db.update(
      'MiniJeu',
      miniJeu.toMap(),
      where: 'id = ?',
      whereArgs: [miniJeu.id],
    );
  }

  // Supprimer un MiniJeu
  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'MiniJeu',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<MiniJeu?> getMiniJeuByCoursId(int coursId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'MiniJeu',
      where: 'id_cours = ?',
      whereArgs: [coursId],
    );

    return result.isNotEmpty ? MiniJeu.fromMap(result.first) : null;
  }
}
