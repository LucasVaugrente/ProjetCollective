import 'package:factoscope/models/module.dart';
import 'package:factoscope/database_helper.dart';

class ModuleRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // --- CRUD Methods ---
  Future<int> create(Module module) async {
    final db = await _dbHelper.database;
    return await db.insert('module', module.toMap());
  }

  Future<Module?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'module',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Module.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Module>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('module');
    return result.map((map) => Module.fromMap(map)).toList();
  }

  Future<int> update(Module module) async {
    final db = await _dbHelper.database;
    return await db.update(
      'module',
      module.toMap(),
      where: 'id = ?',
      whereArgs: [module.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'module',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
