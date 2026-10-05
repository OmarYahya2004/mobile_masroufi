import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('masroufi.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0
      )
    ''');
  }

  // Insert or Update Expense locally
  Future<void> insertExpense(Map<String, dynamic> expenseMap) async {
    final db = await instance.database;
    await db.insert(
      'expenses',
      expenseMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all Expenses from SQLite
  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await instance.database;
    return await db.query('expenses', orderBy: 'date DESC');
  }

  // Delete an Expense locally
  Future<int> deleteExpense(String id) async {
    final db = await instance.database;
    return await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}