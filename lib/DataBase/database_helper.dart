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
    //resetDatabase();
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) async {
        // Appeler _createDB pour recréer les tables si nécessaire
        await _createDB(db, 1);
      },
    );
  }

  // Crée les tables dans la base de données
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS module (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        urlImg TEXT NOT NULL,
        titre TEXT NOT NULL,
        description TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cours (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titre TEXT NOT NULL,
        contenu TEXT NOT NULL,
        id_module INTEGER,
        FOREIGN KEY (id_module) REFERENCES module (id)
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS page (
       id INTEGER PRIMARY KEY AUTOINCREMENT,
       description TEXT ,
       ordre INTEGER NOT NULL,
       urlAudio TEST DEFAULT "",
       est_vue INTEGER DEFAULT 0,
       id_cours INTEGER NOT NULL,
       FOREIGN KEY (id_cours) REFERENCES cours (id) ON DELETE CASCADE ON UPDATE CASCADE
      );
    ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS MiniJeu (
     id INTEGER PRIMARY KEY AUTOINCREMENT,
    id_cours INTEGER NOT NULL,
    nom TEXT NOT NULL,
    description TEXT,
    progression INTEGER NOT NULL,
    FOREIGN KEY (id_cours) REFERENCES cours (id)
  );
''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS MediaCours (
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
    CREATE TABLE IF NOT EXISTS ObjectifCours (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_cours INTEGER NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY (id_cours) REFERENCES cours (id) ON DELETE CASCADE
    );
''');

    await db.execute('''
CREATE TABLE Question(
   idQuestion INTEGER,
   PRIMARY KEY(idQuestion)
);''');

    await db.execute('''CREATE TABLE QuestionImg(
   idQuestion INTEGER,
   urlImage TEXT NOT NULL,
   caption TEXT NOT NULL,
   PRIMARY KEY(idQuestion),
   FOREIGN KEY(idQuestion) REFERENCES Question(idQuestion)
);''');

    await db.execute('''CREATE TABLE QuestionText(
   idQuestion INTEGER,
   txt TEXT NOT NULL,
   PRIMARY KEY(idQuestion),
   FOREIGN KEY(idQuestion) REFERENCES Question(idQuestion)
);''');

    await db.execute('''CREATE TABLE QCM(
   idQCM INTEGER,
   numSolution INTEGER NOT NULL,
   idCours INTEGER NOT NULL,
   idQuestion INTEGER NOT NULL,
   PRIMARY KEY(idQCM),
   UNIQUE(idQuestion),
   FOREIGN KEY(idCours) REFERENCES cours(id),
   FOREIGN KEY(idQuestion) REFERENCES Question(idQuestion)
);''');

    await db.execute('''CREATE TABLE Reponse(
   idReponse INTEGER,
   idQCM INTEGER NOT NULL,
   PRIMARY KEY(idReponse),
   FOREIGN KEY(idQCM) REFERENCES QCM(idQCM)
);''');

    await db.execute('''CREATE TABLE ReponseImg(
   idReponse INTEGER,
   urlImage TEXT NOT NULL,
   caption TEXT NOT NULL,
   PRIMARY KEY(idReponse),
   FOREIGN KEY(idReponse) REFERENCES Reponse(idReponse)
);''');

    await db.execute('''CREATE TABLE ReponseText(
   idReponse INTEGER,
   txt TEXT NOT NULL,
   PRIMARY KEY(idReponse),
   FOREIGN KEY(idReponse) REFERENCES Reponse(idReponse)
);''');

    await db.execute('''
  CREATE TABLE Cloze(
     idCloze INTEGER PRIMARY KEY AUTOINCREMENT,
     phrase TEXT NOT NULL,      
     idCours INTEGER NOT NULL,
     FOREIGN KEY(idCours) REFERENCES cours(id)
  );
''');

  }

  // Supprime la base de données et recrée les tables
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app.db');

    // Supprime la base de données existante
    await deleteDatabase(path);

    // Rouvre la base de données pour recréer les tables
    _database = await _initDB('app.db');
  }

  // Méthode pour fermer la base de données
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}