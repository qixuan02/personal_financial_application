import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:personal_financial_app/models/financial_model.dart';

class FinancialDatabaseHelper {
  static final FinancialDatabaseHelper _instance =
      FinancialDatabaseHelper._internal();
  factory FinancialDatabaseHelper() => _instance;
  FinancialDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'financial.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE financial_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        amount REAL,
        type TEXT
      )
    ''');
  }

  Future<List<FinancialModel>> getFinancialData(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'financial_data',
      where: 'type = ?',
      whereArgs: [type],
    );

    return List.generate(maps.length, (i) {
      return FinancialModel.fromMap(maps[i]);
    });
  }

  Future<void> insertFinancialData(FinancialModel model) async {
    final db = await database;
    await db.insert(
      'financial_data',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateFinancialData(FinancialModel model) async {
    final db = await database;
    await db.update(
      'financial_data',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );
  }

  Future<void> deleteFinancialData(int id) async {
    final db = await database;
    await db.delete(
      'financial_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getAverageIncome() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT AVG(amount) as average_income FROM financial_data WHERE type = ?',
        ['income']);
    return result.isNotEmpty ? result.first['average_income'] ?? 0 : 0;
  }

  Future<double> getTotalSavings() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT SUM(amount) as total_savings FROM financial_data WHERE type = ?',
        ['savings']);
    return result.isNotEmpty ? result.first['total_savings'] ?? 0 : 0;
  }

  Future<double> getTotalDebts() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT SUM(amount) as total_debts FROM financial_data WHERE type = ?',
        ['loan']);
    return result.isNotEmpty ? result.first['total_debts'] ?? 0 : 0;
  }
}

