import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class CategoryDatabaseHelper {
  static final CategoryDatabaseHelper _instance =
      CategoryDatabaseHelper._internal();
  factory CategoryDatabaseHelper() => _instance;
  CategoryDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'categories.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)',
        );
      },
    );
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('categories', columns: ['name']);
    return List.generate(maps.length, (i) {
      return maps[i]['name'] as String;
    });
  }

  Future<void> insertCategory(String category) async {
    final db = await database;
    await db.insert(
      'categories',
      {'name': category},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> deleteCategory(String category) async {
    final db = await database;
    await db.delete(
      'categories',
      where: 'name = ?',
      whereArgs: [category],
    );
  }

  Future<void> updateCategory(String oldCategory, String newCategory) async {
    final db = await database;
    await db.update(
      'categories',
      {'name': newCategory},
      where: 'name = ?',
      whereArgs: [oldCategory],
    );
  }

  Future<List<Map<String, dynamic>>> getCategoryExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT c.name AS category, SUM(e.amount) AS total
      FROM categories c
      LEFT JOIN expenses e ON c.name = e.item
      GROUP BY c.name
    ''');
    return result;
  }
}
