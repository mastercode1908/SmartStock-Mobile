import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'smart_stock.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pending_syncs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT UNIQUE,
        timestamp TEXT,
        endpoint TEXT,
        payload TEXT,
        status INTEGER
      )
    ''');
  }

  Future<int> insertPendingSync(Map<String, dynamic> row) async {
    Database db = await database;
    return await db.insert('pending_syncs', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getPendingSyncs() async {
    Database db = await database;
    return await db.query('pending_syncs', where: 'status = ?', whereArgs: [0], orderBy: 'id ASC');
  }

  Future<int> updatePendingSyncStatus(int id, int status) async {
    Database db = await database;
    return await db.update('pending_syncs', {'status': status}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePendingSync(int id) async {
    Database db = await database;
    return await db.delete('pending_syncs', where: 'id = ?', whereArgs: [id]);
  }
}
