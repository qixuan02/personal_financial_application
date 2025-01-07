import 'package:flutter/material.dart';
import 'package:personal_financial_app/Screen/AddCategoryPage.dart';
import 'package:personal_financial_app/models/expense_model.dart';
//import 'package:personal_financial_app/item.dart';
import 'package:personal_financial_app/navbar.dart';
//import 'package:personal_financial_app/widgets/add_expenses.dart';
//import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
//import 'package:personal_financial_app/widgets/fund_condition_widget.dart';
import 'package:personal_financial_app/database_helpers/database_helper.dart';
import 'package:personal_financial_app/database_helpers/category_database.dart';
import 'package:personal_financial_app/database_helpers/category_limit_database.dart';
import 'package:personal_financial_app/widgets/expense_search.dart';

class Expenses extends StatefulWidget {
  final List<ExpenseModel> expenses;

  Expenses({required this.expenses});

  @override
  _ExpensesState createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final CategoryDatabaseHelper _categoryDbHelper = CategoryDatabaseHelper();
  final CategoryLimitDatabaseHelper _limitDbHelper =
      CategoryLimitDatabaseHelper();
  List<ExpenseModel> items = [];
  DateTime today = DateTime.now();
  //bool _isCalendarVisible = false;
  final itemController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  int totalMoney = 0;
  int spentMoney = 0;
  int income = 0;
  String currentOption = 'expenses';
  DateTime? pickedDate;
  String? selectedCategory;
  int totalIncome = 0;
  int totalExpenses = 0;
  int deposit = 0;
  List<String> categories = [];
  Map<String, double> categoryExpenses = {};
  String filterQuery = '';

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _loadCategories();
  }

  Future<void> _loadExpenses() async {
    items = await _dbHelper.getExpenses();
    items.sort((a, b) => b.date.compareTo(a.date));
    _calculateTotals();
    _calculateCategoryExpenses();
    await _checkLimits();
    setState(() {});
  }

  Future<void> _loadCategories() async {
    final loadedCategories = await _categoryDbHelper.getCategories();
    setState(() {
      categories = loadedCategories;
    });
  }

  void _calculateTotals() {
    totalMoney = 0;
    spentMoney = 0;
    income = 0;
    for (var item in items) {
      if (item.isIncome) {
        income += item.amount;
        totalMoney += item.amount;
      } else {
        spentMoney += item.amount;
        totalMoney -= item.amount;
      }
    }
    print(
        'Total Money: $totalMoney, Income: $income, Spent Money: $spentMoney');
  }

  Future<void> _addExpense() async {
    if (pickedDate == null) {
      pickedDate = DateTime.now();
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    try {
      int convertedAmount = int.parse(amountController.text);
      final expenseModel = ExpenseModel(
        item: itemController.text.isNotEmpty ? itemController.text : 'Unnamed',
        amount: convertedAmount,
        date: pickedDate!,
        isIncome: currentOption == 'income',
        category: selectedCategory!,
      );

      await _dbHelper.insertExpense(expenseModel);
      // Wait for the expenses to load

      // Clear the form
      itemController.clear();
      amountController.clear();
      dateController.clear();
      selectedCategory = null;
      pickedDate = null;

      Navigator.pop(context);

      await _loadExpenses();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Expense added successfully')),
      );
    } catch (e) {
      print('Error adding expense: $e');
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding expense: ${e.toString()}')),
      );
    }
  }

  void _showAddExpenseDialog() {
    // Reset the form state
    itemController.clear();
    amountController.clear();
    pickedDate = DateTime.now();
    dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate!);
    selectedCategory = null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Expense'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: itemController,
                    decoration: InputDecoration(labelText: 'Item'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: pickedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          pickedDate = picked;
                          dateController.text =
                              DateFormat('dd/MM/yyyy').format(picked);
                        });
                      }
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          hint: Text('Select Category'),
                          items: categories.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddCategoryPage(),
                            ),
                          );
                          await _loadCategories();
                          setState(
                              () {}); // Rebuild the dialog to show new categories
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _addExpense();
                  },
                  child: Text('ADD'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('CANCEL'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteExpense(ExpenseModel expenseToDelete) async {
    if (expenseToDelete.id == null) {
      print('Error: Expense ID is null');
      return;
    }

    bool? confirmDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Delete Expense'),
        content: Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        int result = await _dbHelper.deleteExpense(expenseToDelete.id!);
        if (result > 0) {
          await _loadExpenses(); // Reload all expenses
          if (mounted) {
            // Check if widget is still mounted
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Expense deleted successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete expense'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } catch (e) {
        print('Error deleting expense: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting expense: ${e.toString()}'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  void _showUpdateExpenseDialog(int index) {
    ExpenseModel expense = items[index];
    itemController.text = expense.item;
    amountController.text = expense.amount.toString();
    dateController.text = DateFormat('dd/MM/yyyy').format(expense.date);
    selectedCategory = expense.category;

    showDialog(
      context: context,
      builder: (context) {
        String? localSelectedCategory = selectedCategory;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Expense'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: itemController,
                    decoration: InputDecoration(labelText: 'Item'),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: expense.date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null) {
                        setState(() {
                          pickedDate = picked;
                          dateController.text =
                              DateFormat('dd/MM/yyyy').format(picked);
                        });
                      }
                    },
                  ),
                  DropdownButton<String>(
                    value: localSelectedCategory,
                    hint: Text('Select Category'),
                    items: categories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        localSelectedCategory = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    expense.item = itemController.text;
                    expense.amount = int.parse(amountController.text);
                    expense.date = pickedDate ?? expense.date;
                    expense.category =
                        localSelectedCategory ?? expense.category;
                    await _dbHelper.updateExpense(expense);
                    Navigator.pop(context);
                    await _loadExpenses();
                  },
                  child: Text('UPDATE'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('CANCEL'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Map<String, List<ExpenseModel>> _groupExpensesByMonth() {
    Map<String, List<ExpenseModel>> groupedExpenses = {};
    for (var expense in items) {
      String monthKey = DateFormat('yyyy-MM').format(expense.date);
      if (groupedExpenses[monthKey] == null) {
        groupedExpenses[monthKey] = [];
      }
      groupedExpenses[monthKey]!.add(expense);
    }
    return groupedExpenses;
  }

  Map<String, int> _calculateMonthlyTotals(List<ExpenseModel> expenses) {
    int totalIncome = 0;
    int totalExpenses = 0;
    for (var item in expenses) {
      if (item.isIncome) {
        totalIncome += item.amount;
      } else {
        totalExpenses += item.amount;
      }
    }
    int deposit = totalIncome - totalExpenses;
    return {
      'income': totalIncome,
      'expenses': totalExpenses,
      'deposit': deposit,
    };
  }

  void _calculateCategoryExpenses() {
    categoryExpenses.clear();
    // Get current month expenses only
    String currentMonthKey = DateFormat('yyyy-MM').format(DateTime.now());

    // Group current month's expenses by category
    for (var item in items) {
      String itemMonthKey = DateFormat('yyyy-MM').format(item.date);
      // Only include expenses from current month
      if (!item.isIncome && itemMonthKey == currentMonthKey) {
        // Sum up expenses for each category
        categoryExpenses[item.category] =
            (categoryExpenses[item.category] ?? 0) + item.amount.toDouble();
      }
    }

    // Print for debugging
    print('Current month category expenses: $categoryExpenses');
  }

  Future<void> _checkLimits() async {
    // Get all categories that have limits set
    for (var category in categories) {
      // Use your categories list
      final limit = await _limitDbHelper.getCategoryLimit(category) ?? 0;
      print('Checking limit for $category: Limit = $limit'); // Debug print

      if (limit > 0) {
        // Only check if a limit is set
        final currentExpense = categoryExpenses[category] ?? 0.0;
        print('Current expense for $category: $currentExpense'); // Debug print

        final percentageUsed = (currentExpense / limit) * 100;
        print('Percentage used: $percentageUsed%'); // Debug print

        if (currentExpense >= limit) {
          _notifyUser(category, percentageUsed,
              isOverLimit: true,
              currentMonthExpense: currentExpense,
              limit: limit.toDouble());
        } else if (percentageUsed >= 90) {
          _notifyUser(category, percentageUsed,
              isOverLimit: false,
              currentMonthExpense: currentExpense,
              limit: limit.toDouble());
        }
      }
    }
  }

  void _notifyUser(String category, double percentageUsed,
      {bool isOverLimit = false,
      required double currentMonthExpense,
      required double limit}) {
    String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());
    String message = isOverLimit
        ? 'You have exceeded the limit for $category in $currentMonth!\n\nSpent: RM${currentMonthExpense.toStringAsFixed(2)}\nCategory Limit: RM${limit.toStringAsFixed(2)}'
        : 'Warning: You have used ${percentageUsed.toStringAsFixed(1)}% of your limit for $category in $currentMonth.\n\nSpent: RM${currentMonthExpense.toStringAsFixed(2)}\nCategory Limit: RM${limit.toStringAsFixed(2)}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isOverLimit
              ? 'Category Limit Exceeded!'
              : 'Warning: High Category Spending'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController filterController = TextEditingController();
        return AlertDialog(
          title: Text('Filter Expenses'),
          content: TextField(
            controller: filterController,
            decoration: InputDecoration(labelText: 'Enter filter query'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  filterQuery = filterController.text;
                });
                Navigator.pop(context);

                List<ExpenseModel> filteredExpenses =
                    ExpenseSearch.filterExpenses(items, filterQuery);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FilteredExpensesPage(
                      filteredExpenses: filteredExpenses,
                    ),
                  ),
                );
              },
              child: Text('FILTER'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('CANCEL'),
            ),
          ],
        );
      },
    );
  }

  void _resetFilter() {
    setState(() {
      filterQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<ExpenseModel>> monthlyExpenses = _groupExpensesByMonth();
    List<ExpenseModel> filteredExpenses =
        ExpenseSearch.filterExpenses(items, filterQuery);

    return Scaffold(
      drawer: NavBar(),
      backgroundColor: Color(0xFF292728),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Expenses',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF292728),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetFilter,
          ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'No expenses found',
                style: TextStyle(color: Colors.white),
              ),
            )
          : PageView.builder(
              itemCount: monthlyExpenses.keys.length,
              itemBuilder: (context, pageIndex) {
                String monthKey = monthlyExpenses.keys.elementAt(pageIndex);
                List<ExpenseModel> expenses = monthlyExpenses[monthKey]!;
                List<ExpenseModel> filteredMonthlyExpenses =
                    expenses.where((expense) {
                  return filteredExpenses.contains(expense);
                }).toList();

                Map<String, int> monthlyTotals =
                    _calculateMonthlyTotals(filteredMonthlyExpenses);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        DateFormat('MMMM yyyy')
                            .format(DateTime.parse(monthKey + '-01')),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryCard('Deposit',
                              monthlyTotals['deposit']!, Colors.white),
                          _buildSummaryCard(
                              'Income', monthlyTotals['income']!, Colors.blue),
                          _buildSummaryCard('Expenses',
                              monthlyTotals['expenses']!, Colors.red),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredMonthlyExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = filteredMonthlyExpenses[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4.0, horizontal: 8.0),
                            child: Card(
                              color: Colors.grey[800],
                              child: ListTile(
                                contentPadding: EdgeInsets.all(8.0),
                                title: Text(
                                  expense.item,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                subtitle: Text(
                                  expense.category,
                                  style: TextStyle(color: Colors.white70),
                                ),
                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'RM ${expense.amount}',
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 16),
                                    ),
                                    Text(
                                      '${expense.date.day} ${_monthName(expense.date.month)} ${expense.date.year}',
                                      style: TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                                onTap: () => _showUpdateExpenseDialog(
                                    items.indexOf(expense)),
                                onLongPress: () async {
                                  // Handle deletion with proper state management
                                  await _deleteExpense(expense);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: IconButton(
          icon: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: _showAddExpenseDialog,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, int amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        SizedBox(height: 4),
        Text(
          'RM $amount',
          style: TextStyle(
              color: color, fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

class ExpenseSearch {
  static List<ExpenseModel> filterExpenses(
      List<ExpenseModel> expenses, String query) {
    // Trim whitespace from the query
    query = query.trim();

    if (query.isEmpty) {
      return expenses; // Return all expenses if the query is empty
    }

    // Attempt to parse the query as a double
    double? amountQuery = double.tryParse(query);

    return expenses.where((expense) {
      // Check if the item name contains the query (case insensitive)
      bool matchesItem =
          expense.item.toLowerCase().contains(query.toLowerCase());

      // Check if the amount matches the query
      bool matchesAmount = amountQuery != null && expense.amount == amountQuery;

      // Return true if either condition matches
      return matchesItem || matchesAmount;
    }).toList();
  }
}
