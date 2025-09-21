
import '../DataBase/database_helper.dart';
import '../models/objectifCours.dart';

class ObjectifCoursRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> create(ObjectifCours objectifCours) async {
    final db = await _dbHelper.database;
    return await db.insert('ObjectifCours', objectifCours.toMap());
  }

  Future<ObjectifCours?> getById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'ObjectifCours',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? ObjectifCours.fromMap(result.first) : null;
  }

  Future<List<ObjectifCours>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('ObjectifCours');
    return result.map((map) => ObjectifCours.fromMap(map)).toList();
  }

  Future<List<ObjectifCours>> getByCoursId(int coursId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'ObjectifCours',
      where: 'id_cours = ?',
      whereArgs: [coursId],
    );
    return result.map((map) => ObjectifCours.fromMap(map)).toList();
  }

  Future<int> update(ObjectifCours objectifCours) async {
    final db = await _dbHelper.database;
    return await db.update(
      'ObjectifCours',
      objectifCours.toMap(),
      where: 'id = ?',
      whereArgs: [objectifCours.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'ObjectifCours',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
