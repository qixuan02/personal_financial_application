import 'package:flutter/material.dart';
import '../database_helpers/category_database.dart'; // Ensure this is the correct path

class AddCategoryPage extends StatefulWidget {
  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final CategoryDatabaseHelper _dbHelper = CategoryDatabaseHelper();
  final TextEditingController _categoryController = TextEditingController();
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final loadedCategories = await _dbHelper.getCategories();
    setState(() {
      categories = loadedCategories;
    });
  }

  Future<void> _addCategory() async {
    final newCategory = _categoryController.text.trim();
    if (newCategory.isNotEmpty && !categories.contains(newCategory)) {
      await _dbHelper.insertCategory(newCategory);
      setState(() {
        categories.add(newCategory);
      });
      _categoryController.clear();
    }
  }

  Future<void> _deleteCategory(String category) async {
    await _dbHelper.deleteCategory(category);
    setState(() {
      categories.remove(category);
    });
  }

  Future<void> _editCategory(String oldCategory) async {
    final TextEditingController editController =
        TextEditingController(text: oldCategory);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(hintText: 'Enter new category name'),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                final newCategory = editController.text.trim();
                if (newCategory.isNotEmpty &&
                    !categories.contains(newCategory)) {
                  await _dbHelper.updateCategory(oldCategory, newCategory);
                  setState(() {
                    categories[categories.indexOf(oldCategory)] = newCategory;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Categories'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: 'New Category',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addCategory,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  title: Text(category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editCategory(category),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteCategory(category),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
