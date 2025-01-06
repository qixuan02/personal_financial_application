import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:personal_financial_app/models/expense_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expenses.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item TEXT,
        amount INTEGER,
        date TEXT,
        isIncome INTEGER
      )
    ''');
  }

  Future<int> insertExpense(ExpenseModel expense) async {
    Database db = await database;
    return await db.insert('expenses', expense.toMap());
  }

  Future<List<ExpenseModel>> getExpenses() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) {
      return ExpenseModel.fromMap(maps[i]);
    });
  }

  Future<int> updateExpense(ExpenseModel expense) async {
    Database db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> deleteExpense(int id) async {
    Database db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<int, double>> getMonthlyExpensesForYear(int year) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT strftime('%m', date) as month, SUM(amount) as total
      FROM expenses
      WHERE strftime('%Y', date) = ?
      GROUP BY strftime('%m', date)
    ''', [year.toString()]);

    Map<int, double> monthlyTotals = {};
    for (var row in result) {
      int month = int.parse(row['month']);
      double total = (row['total'] as num).toDouble();
      monthlyTotals[month] = total;
    }
    return monthlyTotals;
  }

  Future<Map<int, double>> getDailyExpensesForMonth(int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT strftime('%d', date) as day, SUM(amount) as total
      FROM expenses
      WHERE strftime('%Y', date) = ? 
      AND strftime('%m', date) = ?
      GROUP BY strftime('%d', date)
    ''', [year.toString(), month.toString().padLeft(2, '0')]);

    Map<int, double> dailyTotals = {};
    for (var row in result) {
      int day = int.parse(row['day']);
      double total = (row['total'] as num).toDouble();
      dailyTotals[day] = total;
    }
    return dailyTotals;
  }

  Future<Map<String, double>> getCategoryExpensesForMonth(
      int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM expenses
      WHERE strftime('%Y', date) = ? 
      AND strftime('%m', date) = ?
      GROUP BY category
    ''', [year.toString(), month.toString().padLeft(2, '0')]);

    Map<String, double> categoryTotals = {};
    for (var row in result) {
      String category = row['category'];
      double total = (row['total'] as num).toDouble();
      categoryTotals[category] = total;
    }
    return categoryTotals;
  }

  Future<List<ExpenseModel>> getAllExpenses() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('expenses');
    return List.generate(maps.length, (i) {
      return ExpenseModel.fromMap(maps[i]);
    });
  }

  Future<double> calculateAverageAnnualExpenses() async {
    List<ExpenseModel> allExpenses = await getAllExpenses();
    if (allExpenses.isEmpty) return 0;

    // Calculate total expenses
    double totalExpenses =
        allExpenses.fold(0, (sum, item) => sum + item.amount);

    // Get unique months from the expenses
    Set<String> uniqueMonths = {};
    for (var expense in allExpenses) {
      uniqueMonths.add(expense.date.year.toString() +
          '-' +
          expense.date.month.toString().padLeft(2, '0'));
    }

    // Calculate average based on the number of unique months
    return totalExpenses / uniqueMonths.length;
  }

  Future<List<Map<String, dynamic>>> getCategoryExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT item AS category, SUM(amount) AS total
      FROM expenses
      GROUP BY item
    ''');
    return result;
  }
}
