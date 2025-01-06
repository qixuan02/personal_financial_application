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

  // Convert a FinancialModel into a Map. The keys must correspond to the column names in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  // Create a FinancialModel from a Map. This is used when retrieving data from the database.
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

  // Optional: Add a method to validate the model's data
  bool isValid() {
    return name.isNotEmpty && amount > 0 && type.isNotEmpty;
  }
}
