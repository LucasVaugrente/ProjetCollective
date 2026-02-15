import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Méthode pour obtenir la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  // Initialisation de la base de données
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Création des tables
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE module (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        urlImg TEXT NOT NULL,
        titre TEXT NOT NULL,
        description TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE cours (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        contenu TEXT NOT NULL,
        id_module INTEGER,
        FOREIGN KEY (id_module) REFERENCES module (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE page (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        ordre INTEGER NOT NULL,
        urlAudio TEXT DEFAULT "",
        est_vue INTEGER DEFAULT 0,
        id_cours INTEGER NOT NULL,
        FOREIGN KEY (id_cours) REFERENCES cours (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE MiniJeu (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_cours INTEGER NOT NULL,
        nom TEXT NOT NULL,
        description TEXT,
        progression INTEGER NOT NULL,
        FOREIGN KEY (id_cours) REFERENCES cours (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE MotsCroises (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_minijeu INTEGER NOT NULL,
        taille_grille TEXT NOT NULL,
        description TEXT,
        FOREIGN KEY (id_minijeu) REFERENCES MiniJeu (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE Mot (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_motscroises INTEGER NOT NULL,
        mot TEXT NOT NULL,
        indice TEXT NOT NULL,
        direction TEXT NOT NULL,
        position_depart_x INTEGER NOT NULL,
        position_depart_y INTEGER NOT NULL,
        FOREIGN KEY (id_motscroises) REFERENCES MotsCroises (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE MediaCours (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_page INTEGER NOT NULL,
        ordre INTEGER NOT NULL,
        url TEXT NOT NULL,
        type TEXT NOT NULL,
        caption TEXT,
        FOREIGN KEY (id_page) REFERENCES page (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE ObjectifCours (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_cours INTEGER NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY (id_cours) REFERENCES cours (id) ON DELETE CASCADE
      );
    ''');

    // -------------------------------------------------------------------------
    // NOUVELLE TABLE QCM — COMPATIBLE AVEC TON MODÈLE ET TON REPOSITORY
    // -------------------------------------------------------------------------
    await db.execute('''
      CREATE TABLE qcm (
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
  }

  // Supprime la base et recrée les tables
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    await deleteDatabase(path);
    _database = await _initDB('app.db');
  }

  // Fermer la base
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}
