class ExpenseCategory {
  final String name;
  double limit;
  double currentExpense;

  ExpenseCategory({
    required this.name,
    this.limit = 0.0,
    this.currentExpense = 0.0,
  });

  bool isBelowThreshold() {
    return currentExpense > 0 && (limit - currentExpense) / limit <= 0.1;
  }
}
