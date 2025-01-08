import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_financial_app/database_helpers/category_database.dart';
import 'package:personal_financial_app/database_helpers/category_limit_database.dart';
import 'package:personal_financial_app/navbar.dart';

class CategoryAlertSettings extends StatefulWidget {
  const CategoryAlertSettings({Key? key}) : super(key: key);

  @override
  _CategoryAlertSettingsState createState() => _CategoryAlertSettingsState();
}

class _CategoryAlertSettingsState extends State<CategoryAlertSettings> {
  final CategoryLimitDatabaseHelper _limitDbHelper =
      CategoryLimitDatabaseHelper();
  final CategoryDatabaseHelper _categoryDbHelper = CategoryDatabaseHelper();
  List<CategoryLimit> categories = [];
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => _isLoading = true);

      final List<String> categoryNames =
          await _categoryDbHelper.getCategories();

      final List<Map<String, dynamic>> limitsData =
          await _limitDbHelper.getAllCategoryLimits();

      final Map<String, double> limitMap = {
        for (var item in limitsData)
          item['category_name'] as String:
              (item['category_limit'] as num).toDouble()
      };

      setState(() {
        categories = categoryNames
            .map((name) => CategoryLimit(
                  categoryName: name,
                  limit: limitMap[name]?.toDouble() ?? 0.0,
                ))
            .toList();

        for (var category in categories) {
          _controllers[category.categoryName] = TextEditingController(
            text: category.limit.toStringAsFixed(2),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading categories: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAlertLimits() async {
    try {
      for (var category in categories) {
        final newLimit =
            double.tryParse(_controllers[category.categoryName]!.text) ?? 0;
        await _limitDbHelper.setCategoryLimit(
          category.categoryName,
          newLimit.round(),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alert limits saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving limits: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Alert Settings',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : categories.isEmpty
              ? Center(
                  child: Text(
                    'No categories found.\nAdd categories to set alerts.',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return Card(
                              color: Colors.grey[900],
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        category.categoryName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: TextField(
                                        controller:
                                            _controllers[category.categoryName],
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        style: const TextStyle(
                                            color: Colors.white),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d*\.?\d{0,2}')),
                                        ],
                                        decoration: InputDecoration(
                                          prefixText: '\RM ',
                                          prefixStyle: const TextStyle(
                                              color: Colors.white),
                                          hintText: 'Enter limit amount',
                                          hintStyle: TextStyle(
                                              color: Colors.grey[400]),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.white),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.white),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                                color: Colors.blue),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveAlertLimits,
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text(
                            'Save Alert Limits',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class CategoryLimit {
  final String categoryName;
  double limit;

  CategoryLimit({
    required this.categoryName,
    required this.limit,
  });
}
