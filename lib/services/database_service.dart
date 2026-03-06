import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:mindwealth_ai/models/transaction_model.dart';
import 'package:mindwealth_ai/models/goal_model.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'mindwealth.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions (
            id TEXT PRIMARY KEY,
            amount REAL NOT NULL,
            category TEXT NOT NULL,
            description TEXT,
            date TEXT NOT NULL,
            type TEXT NOT NULL,
            mood TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE goals (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            target REAL NOT NULL,
            saved REAL NOT NULL DEFAULT 0,
            deadline TEXT NOT NULL,
            icon TEXT DEFAULT '🎯'
          )
        ''');
      },
    );
  }

  // ─── Transactions ───

  static Future<List<TransactionModel>> getTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  static Future<void> insertTransaction(TransactionModel txn) async {
    final db = await database;
    await db.insert(
      'transactions',
      txn.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> updateTransaction(TransactionModel txn) async {
    final db = await database;
    await db.update(
      'transactions',
      txn.toMap(),
      where: 'id = ?',
      whereArgs: [txn.id],
    );
  }

  static Future<void> replaceAllTransactions(
    List<TransactionModel> txns,
  ) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('transactions');
    for (final txn in txns) {
      batch.insert('transactions', txn.toMap());
    }
    await batch.commit(noResult: true);
  }

  // ─── Goals ───

  static Future<List<GoalModel>> getGoals() async {
    final db = await database;
    final maps = await db.query('goals');
    return maps.map((m) => GoalModel.fromMap(m)).toList();
  }

  static Future<void> insertGoal(GoalModel goal) async {
    final db = await database;
    await db.insert(
      'goals',
      goal.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updateGoal(GoalModel goal) async {
    final db = await database;
    await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  static Future<void> deleteGoal(String id) async {
    final db = await database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> replaceAllGoals(List<GoalModel> goals) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('goals');
    for (final goal in goals) {
      batch.insert('goals', goal.toMap());
    }
    await batch.commit(noResult: true);
  }
}
