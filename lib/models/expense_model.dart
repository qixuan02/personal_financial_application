class ExpenseModel {
  int? id;
  String item;
  int amount;
  DateTime date;
  bool isIncome;
  String category;
  

  ExpenseModel({
    this.id,
    required this.item,
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.category,
    
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item': item,
      'amount': amount,
      'date': date.toIso8601String(),
      'isIncome': isIncome ? 1 : 0,
      'category': category,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      item: map['item'] ?? '',
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      isIncome: map['isIncome'] == 1,
      category: map['category'] ?? 'Other',
    );
  }
}
