import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wishlist.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color_value INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE wishes (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category_id TEXT NOT NULL,
        priority INTEGER NOT NULL,
        status INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        deadline TEXT,
        image_path TEXT,
        notes TEXT,
        tags TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE wish_history (
        id TEXT PRIMARY KEY,
        wish_id TEXT NOT NULL,
        change_description TEXT NOT NULL,
        changed_at TEXT NOT NULL,
        FOREIGN KEY (wish_id) REFERENCES wishes(id)
      )
    ''');

    await _seedDefaultCategories(db);
  }

  Future<void> _seedDefaultCategories(Database db) async {
    final defaults = [
      {
        'id': 'cat_travel',
        'name': 'Travel',
        'icon': 'travel',
        'color_value': 0xFF2CBF6E,
      },
      {
        'id': 'cat_tech',
        'name': 'Technology',
        'icon': 'tech',
        'color_value': 0xFF1E88E5,
      },
      {
        'id': 'cat_health',
        'name': 'Health',
        'icon': 'health',
        'color_value': 0xFFE23D3D,
      },
      {
        'id': 'cat_education',
        'name': 'Education',
        'icon': 'education',
        'color_value': 0xFFFFA726,
      },
      {
        'id': 'cat_other',
        'name': 'Other',
        'icon': 'other',
        'color_value': 0xFF9E9E9E,
      },
    ];
    for (final cat in defaults) {
      await db.insert('categories', cat);
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table, {
    required String where,
    required List<dynamic> whereArgs,
  }) async {
    final db = await database;
    return db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    return db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('wish_history');
    await db.delete('wishes');
    await db.delete('categories');
    await _seedDefaultCategories(db);
  }
}
