import '../database_helper.dart';
import '../models/cours.dart';
import '../models/page.dart';

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
    print("Récupération de tous les cours depuis la base de données");
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('cours');
    print("Nombre de cours récupérés depuis la base de données : ${maps.length}");
    return List.generate(maps.length, (i) {
      return Cours.fromMap(maps[i]);
    });
  }

  Future<Cours?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cours',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      final cours = Cours.fromMap(maps.first);
      return cours;
    }
    return null;
  }

  Future<List<Page>> _getPagesByCoursId(int coursId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'page',
      where: 'id_cours = ?',
      whereArgs: [coursId],
    );
    return List.generate(maps.length, (i) {
      return Page.fromMap(maps[i]);
    });
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
}