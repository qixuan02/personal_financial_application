class FinancialModel {
  final int? id;
  final String name;
  final double amount;
  final DateTime date;
  final String type;

  FinancialModel({
    this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory FinancialModel.fromMap(Map<String, dynamic> map) {
    try {
      return FinancialModel(
        id: map['id'],
        name: map['name'],
        amount: map['amount'],
        date: DateTime.parse(map['date']),
        type: map['type'],
      );
    } catch (e) {
      throw FormatException('Error parsing FinancialModel: $e');
    }
  }

  bool isValid() {
    return name.isNotEmpty && amount > 0 && type.isNotEmpty;
  }
}
