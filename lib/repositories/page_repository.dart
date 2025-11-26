import 'package:factoscope/DataBase/database_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../models/page.dart';

class PageRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<int> create(Page page) async {
    final db = await _dbHelper.database;
    return await db.insert('page', page.toMap());
  }

  Future<Page?> getById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'page',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? Page.fromMap(result.first) : null;
  }

  Future<List<Page>> getAll() async {
    final db = await _dbHelper.database;
    final result = await db.query('page');
    return result.map((map) => Page.fromMap(map)).toList();
  }

  Future<int> update(Page page) async {
    final db = await _dbHelper.database;
    return await db.update(
      'page',
      page.toMap(),
      where: 'id = ?',
      whereArgs: [page.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'page',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Page>> getPagesByCourseId(int courseId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'page',
      where: 'id_cours = ?',
      whereArgs: [courseId],
    );
    return result.map((map) => Page.fromMap(map)).toList();
  }

Future<int> getNbPageByCourseId(int courseId) async {
  final db = await _dbHelper.database;
  final result = await db.rawQuery(
    'SELECT COUNT(*) as count FROM page WHERE id_cours = ?',
    [courseId],
  );
  return Sqflite.firstIntValue(result) ?? 0;
}

 Future<int> getNbPageVisite(int courseId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM page WHERE id_cours = ? AND est_vue = ?',
      [courseId, 1], // On compte les pages vues (est_vue = 1)
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> setPageVisite(int pageId) async {
    final db = await _dbHelper.database;
    if (kDebugMode) {
      print("Page $pageId visité");
    }
    return await db.update(
      'page',
      {'est_vue' : true},
      where: 'id = ?',
      whereArgs: [pageId],
    );
  }

}
