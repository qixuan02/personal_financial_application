import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CategoryLimitDatabaseHelper {
  static final CategoryLimitDatabaseHelper _instance =
      CategoryLimitDatabaseHelper._internal();
  factory CategoryLimitDatabaseHelper() => _instance;
  CategoryLimitDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'category_limits.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE category_limits(id INTEGER PRIMARY KEY AUTOINCREMENT, category_name TEXT UNIQUE, category_limit INTEGER)',
        );
      },
    );
  }

  Future<void> setCategoryLimit(String categoryName, int limit) async {
    final db = await database;
    await db.insert(
      'category_limits',
      {'category_name': categoryName, 'category_limit': limit},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int?> getCategoryLimit(String categoryName) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'category_limits',
      columns: ['category_limit'],
      where: 'category_name = ?',
      whereArgs: [categoryName],
    );
    if (result.isNotEmpty) {
      return result.first['category_limit'] as int;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllCategoryLimits() async {
    final db = await database;
    return await db.query('category_limits');
  }
}
