import 'package:flutter_note/models/note_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static const String _databaseName = "notes.db";
  static const String _tableName = "notes";
  static const int _databaseVersion = 1;

  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();

  Future<Database> _initialDatabase() async {
    // Implementation for initializing the database
    // This is a placeholder; actual implementation will vary
    return await openDatabase(
      join(await getDatabasesPath(), _databaseName),
      version: _databaseVersion,
      onCreate: (db, version) async {
        createTable(db);
      },
    );
  }

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initialDatabase();
    return _database!;
  }

  Future createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        note_id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        pinned INTEGER NOT NULL DEFAULT 0
      )
    '''); // for pinned column if 1 = true, 0 = false
  }

  Future<int> insertItem(NoteModel note) async {
    final db = await database;
    final data = note.toJson();

    final id = await db.insert(
      _tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<List<NoteModel>> fetchNotes() async {
    final db = await database;
    final maps = await db.query(
      _tableName,
      orderBy: "pinned DESC, created_at DESC",
    );

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return NoteModel.fromJson(maps[i]);
    });
  }
}
