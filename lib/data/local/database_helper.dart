import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';

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
        userId TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        category TEXT NOT NULL,
        userId TEXT NOT NULL,
        limitAmount REAL NOT NULL,
        PRIMARY KEY (category, userId)
      )
    ''');
  }

  // --- EXPENSES CRUD ---

  Future<void> insertOrUpdateExpense(String userId, Expense expense) async {
    final db = await instance.database;
    await db.insert(
      'expenses',
      {
        'id': expense.id,
        'userId': userId,
        'amount': expense.amount,
        'category': expense.category.name,
        'note': expense.note ?? '',
        'date': expense.date.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteExpense(String id) async {
    final db = await instance.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Expense>> getExpenses(String userId) async {
    final db = await instance.database;
    final rows = await db.query(
      'expenses',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );

    return rows.map((row) {
      return Expense(
        id: row['id'] as String,
        amount: (row['amount'] as num).toDouble(),
        category: ExpenseCategory.values.byName(row['category'] as String),
        note: row['note'] as String?,
        date: DateTime.parse(row['date'] as String),
      );
    }).toList();
  }

  Future<void> syncExpensesFromCloud(String userId, List<Expense> cloudExpenses) async {
    final db = await instance.database;
    final batch = db.batch();

    // Clear old cached rows for this user and insert fresh cloud data
    batch.delete('expenses', where: 'userId = ?', whereArgs: [userId]);
    for (final exp in cloudExpenses) {
      batch.insert(
        'expenses',
        {
          'id': exp.id,
          'userId': userId,
          'amount': exp.amount,
          'category': exp.category.name,
          'note': exp.note ?? '',
          'date': exp.date.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  // --- BUDGETS CRUD ---

  Future<void> setBudgetLimit(String userId, ExpenseCategory category, double limit) async {
    final db = await instance.database;
    await db.insert(
      'budgets',
      {
        'category': category.name,
        'userId': userId,
        'limitAmount': limit,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBudgetLimit(String userId, ExpenseCategory category) async {
    final db = await instance.database;
    await db.delete(
      'budgets',
      where: 'category = ? AND userId = ?',
      whereArgs: [category.name, userId],
    );
  }

  Future<Map<ExpenseCategory, double>> getBudgetLimits(String userId) async {
    final db = await instance.database;
    final rows = await db.query(
      'budgets',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    final Map<ExpenseCategory, double> limits = {};
    for (var row in rows) {
      try {
        final category = ExpenseCategory.values.byName(row['category'] as String);
        limits[category] = (row['limitAmount'] as num).toDouble();
      } catch (_) {}
    }
    return limits;
  }
}