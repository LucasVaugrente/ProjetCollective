import 'package:factoscope/models/module.dart';
import 'package:factoscope/DataBase/database_helper.dart';

class ModuleRepository{
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // --- CRUD Methods ---
   Future<int> create(Module Module) async {
    final db = await _dbHelper.database;
    return await db.insert('module', Module.toMap());
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

   Future<int> update(Module Module) async {
    final db = await _dbHelper.database;
    return await db.update(
      'module',
      Module.toMap(),
      where: 'id = ?',
      whereArgs: [Module.id],
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