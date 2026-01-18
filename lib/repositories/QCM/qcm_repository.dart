import 'package:factoscope/database_helper.dart';
import 'package:factoscope/models/QCM/qcm.dart';

class QCMRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> insert(QCM qcm) async {
    final db = await _dbHelper.database;
    return await db.insert('qcm', qcm.toMap());
  }

  Future<QCM?> getById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'qcm',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return QCM.fromMap(maps.first);
    }
    return null;
  }

  Future<List<QCM>> getAllByCoursId(int coursId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'qcm',
      where: 'id_cours = ?',
      whereArgs: [coursId],
    );

    return List.generate(maps.length, (i) {
      return QCM.fromMap(maps[i]);
    });
  }

  Future<List<int>> getAllIdByCoursId(int coursId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'qcm',
      columns: ['id'],
      where: 'id_cours = ?',
      whereArgs: [coursId],
    );

    return maps.map((map) => map['id'] as int).toList();
  }

  Future<int> update(QCM qcm) async {
    final db = await _dbHelper.database;
    return await db.update(
      'qcm',
      qcm.toMap(),
      where: 'id = ?',
      whereArgs: [qcm.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'qcm',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
