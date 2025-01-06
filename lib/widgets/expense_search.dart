import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_financial_app/models/expense_model.dart';

class ExpenseSearch {
  static List<ExpenseModel> filterExpenses(List<ExpenseModel> expenses, String query) {
    if (query.isEmpty) {
      return List.from(expenses); // Return the original list if the query is empty
    }

    String lowerCaseQuery = query.toLowerCase();
    return expenses.where((expense) {
      final itemMatch = expense.item.toLowerCase().contains(lowerCaseQuery);
      final categoryMatch = expense.category.toLowerCase().contains(lowerCaseQuery);
      final amountMatch = expense.amount.toString().contains(lowerCaseQuery);
      final dateMatch = DateFormat('dd/MM/yyyy').format(expense.date).contains(lowerCaseQuery);
      return itemMatch || categoryMatch || amountMatch || dateMatch;
    }).toList();
  }
} 

class FilteredExpensesPage extends StatelessWidget {
  final List<ExpenseModel> filteredExpenses;

  FilteredExpensesPage({required this.filteredExpenses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Expenses'),
      ),
      body: ListView.builder(
        itemCount: filteredExpenses.length,
        itemBuilder: (context, index) {
          final expense = filteredExpenses[index];
          return ListTile(
            title: Text(expense.item),
            subtitle: Text('Category: ${expense.category}'),
            trailing: Text('RM ${expense.amount}'),
          );
        },
      ),
    );
  }
}