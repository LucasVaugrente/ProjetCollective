import '../database_helper.dart';
import '../models/cours.dart';
import '../models/media_cours.dart';

class CoursRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> create(Cours cours) async {
    final db = await _dbHelper.database;
    return await db.insert('cours', cours.toMap());
  }

  Future<int> createOrUpdate(Cours cours) async {
    final existingCours = await getById(cours.id!);
    if (existingCours != null) {
      return await update(cours);
    } else {
      return await create(cours);
    }
  }

  Future<List<Cours>> getAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('cours');
    return List.generate(maps.length, (i) => Cours.fromMap(maps[i]));
  }

  Future<Cours?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cours',
      where: 'id = ?',
      whereArgs: [id],
    );
    return maps.isNotEmpty ? Cours.fromMap(maps.first) : null;
  }

  Future<int> update(Cours cours) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cours',
      cours.toMap(),
      where: 'id = ?',
      whereArgs: [cours.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'cours',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Cours>> getCoursesByModuleId(int moduleId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'cours',
      where: 'id_module = ?',
      whereArgs: [moduleId],
    );
    return result.map((map) => Cours.fromMap(map)).toList();
  }

  Future<int> markAsDownloaded(int coursId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cours',
      {'is_downloaded': 1},
      where: 'id = ?',
      whereArgs: [coursId],
    );
  }

  Future<int> saveMediaForCourse(int coursId, String url, String localPath,
      String type, int pageId) async {
    final db = await _dbHelper.database;
    return await db.insert('media', {
      'url': url,
      'local_path': localPath,
      'type': type,
      'id_page': pageId,
      'is_downloaded': 1,
    });
  }

  Future<List<MediaCours>> getMediasForCourse(int coursId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'media',
      where: 'id_page IN (SELECT id FROM page WHERE id_cours = ?)',
      whereArgs: [coursId],
    );
    return result.map((map) => MediaCours.fromMap(map)).toList();
  }
}
