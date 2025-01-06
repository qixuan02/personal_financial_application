import 'package:flutter/material.dart';
import '../database_helpers/financial_database_helper.dart';
import '../database_helpers/database_helper.dart';

class Suggest extends StatefulWidget {
  @override
  _SuggestState createState() => _SuggestState();
}

class _SuggestState extends State<Suggest> {
  double income = 0;
  double savings = 0;
  double debts = 0;
  String result = '';
  double averageAnnualExpenses = 0;

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
    _fetchAverageAnnualExpenses();
  }

  Future<void> _fetchFinancialData() async {
    FinancialDatabaseHelper dbHelper = FinancialDatabaseHelper();
    double averageIncome = await dbHelper.getAverageIncome();
    double totalSavings = await dbHelper.getTotalSavings();
    double totalDebts = await dbHelper.getTotalDebts();

    setState(() {
      income = averageIncome;
      savings = totalSavings;
      debts = totalDebts;
    });
  }

  Future<void> _fetchAverageAnnualExpenses() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    double average = await dbHelper.calculateAverageAnnualExpenses();

    setState(() {
      averageAnnualExpenses = average;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Financial Suggestions',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Your Financial Details',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              _buildInputField('Monthly Income',
                  (value) => income = double.tryParse(value) ?? 0, income),
              _buildInputField(
                  'Monthly Expenses',
                  (value) =>
                      averageAnnualExpenses = double.tryParse(value) ?? 0,
                  averageAnnualExpenses),
              _buildInputField('Total Savings',
                  (value) => savings = double.tryParse(value) ?? 0, savings),
              _buildInputField('Total Loans',
                  (value) => debts = double.tryParse(value) ?? 0, debts),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  double disposableIncome = income - averageAnnualExpenses;
                  double maxCarBudget =
                      calculateMaxCarBudget(disposableIncome, savings, debts);
                  double maxHouseBudget =
                      calculateMaxHouseBudget(disposableIncome, savings, debts);

                  setState(() {
                    result =
                        'You can afford a car in the range of: RM${(maxCarBudget * 0.8).toStringAsFixed(2)} - RM${maxCarBudget.toStringAsFixed(2)}\n'
                        'You can afford a house in the range of: RM${(maxHouseBudget * 0.8).toStringAsFixed(2)} - RM${maxHouseBudget.toStringAsFixed(2)}';
                  });
                },
                child: Text('Calculate', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  result,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, Function(String) onChanged, double initialValue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.black),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        controller:
            TextEditingController(text: initialValue.toStringAsFixed(2)),
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  double calculateMaxCarBudget(
      double disposableIncome, double savings, double debts) {
    return (disposableIncome * 0.2) + (savings * 0.1) - (debts * 0.05);
  }

  double calculateMaxHouseBudget(
      double disposableIncome, double savings, double debts) {
    return (disposableIncome * 0.3) + (savings * 0.2) - (debts * 0.1);
  }
}
