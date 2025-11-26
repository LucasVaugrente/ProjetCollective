import '../DataBase/database_helper.dart';
import '../models/media_cours.dart';

class MediaCoursRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> create(MediaCours mediaCours) async {
    final db = await _dbHelper.database;
    return await db.insert('MediaCours', mediaCours.toMap());
  }

  Future<MediaCours?> getById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'MediaCours',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? MediaCours.fromMap(result.first) : null;
  }

  Future<List<MediaCours>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('MediaCours');
    return result.map((map) => MediaCours.fromMap(map)).toList();
  }

  Future<int> update(MediaCours mediaCours) async {
    final db = await _dbHelper.database;
    return await db.update(
      'MediaCours',
      mediaCours.toMap(),
      where: 'id = ?',
      whereArgs: [mediaCours.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'MediaCours',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<MediaCours>> getByPageId(int pageId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'MediaCours',
      where: 'id_page = ?',
      whereArgs: [pageId],
    );
    return result.map((map) => MediaCours.fromMap(map)).toList();
  }
}
