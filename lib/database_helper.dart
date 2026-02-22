import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        await _createDB(db, 1);
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Table Module
    await db.execute('''
      CREATE TABLE IF NOT EXISTS module (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        description TEXT NOT NULL,
        urlImg TEXT
      );
    ''');

    // Table Cours
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cours (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        description TEXT NOT NULL,
        contenu TEXT NOT NULL,
        id_module INTEGER,
        last_updated TEXT,
        is_downloaded INTEGER DEFAULT 0,
        FOREIGN KEY (id_module) REFERENCES module (id) ON DELETE CASCADE
      );
    ''');

    // Table Page avec medias en JSON
    await db.execute('''
      CREATE TABLE IF NOT EXISTS page (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        medias TEXT,
        est_vue INTEGER DEFAULT 0,
        id_cours INTEGER NOT NULL,
        FOREIGN KEY (id_cours) REFERENCES cours (id) ON DELETE CASCADE
      );
    ''');

    // Table QCM
    await db.execute('''
      CREATE TABLE IF NOT EXISTS qcm (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        rep1 TEXT NOT NULL,
        rep2 TEXT NOT NULL,
        rep3 TEXT NOT NULL,
        rep4 TEXT NOT NULL,
        soluce INTEGER NOT NULL,
        id_cours INTEGER NOT NULL,
        FOREIGN KEY (id_cours) REFERENCES cours (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS Cloze (
     idCloze INTEGER PRIMARY KEY AUTOINCREMENT,
     phrase TEXT NOT NULL,      
     idCours INTEGER NOT NULL,
     rep1 TEXT NOT NULL,
     rep2 TEXT NOT NULL,
     rep3 TEXT NOT NULL,
     rep4 TEXT NOT NULL,
     soluce INTEGER NOT NULL,
     FOREIGN KEY(idCours) REFERENCES cours(id)
  );
''');

  }

  Future<void> resetDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');
    await deleteDatabase(path);
    _database = await _initDB('app.db');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}