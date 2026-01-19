import '../../DataBase/database_helper.dart';
import '../../models/Cloze/cloze_model.dart';

class ClozeRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<ClozeQuestion>> getByCoursId(int coursId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Cloze',
      where: 'idCours = ?',
      whereArgs: [coursId],
    );

    return List.generate(maps.length, (i) {
      return ClozeQuestion.fromMap(maps[i]);
    });
  }
  Future<int> insert(ClozeQuestion question) async {
    final db = await _dbHelper.database;
    return await db.insert('Cloze', {
      'phrase': question.phrase,
      'idCours': question.idCours,
    });
  }
}