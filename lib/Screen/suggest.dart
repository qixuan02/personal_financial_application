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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Financial Suggestions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderCard(),
              SizedBox(height: 24),
              _buildInputSection(),
              SizedBox(height: 24),
              _buildCalculateButton(),
              SizedBox(height: 24),
              if (result.isNotEmpty) _buildResultCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[900]!, Colors.blue[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 40,
          ),
          SizedBox(height: 16),
          Text(
            'Your Financial Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enter your financial information to get personalized suggestions',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInputField(
            'Monthly Income (RM)',
            (value) => income = double.tryParse(value) ?? 0,
            income,
            Icons.monetization_on,
          ),
          SizedBox(height: 16),
          _buildInputField(
            'Monthly Expenses (RM)',
            (value) => averageAnnualExpenses = double.tryParse(value) ?? 0,
            averageAnnualExpenses,
            Icons.shopping_cart,
          ),
          SizedBox(height: 16),
          _buildInputField(
            'Total Savings (RM)',
            (value) => savings = double.tryParse(value) ?? 0,
            savings,
            Icons.savings,
          ),
          SizedBox(height: 16),
          _buildInputField(
            'Total Loans (RM)',
            (value) => debts = double.tryParse(value) ?? 0,
            debts,
            Icons.account_balance,
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, Function(String) onChanged,
      double initialValue, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.blue[400]),
          prefixText: 'RM ',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        controller:
            TextEditingController(text: initialValue.toStringAsFixed(2)),
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _buildCalculateButton() {
    return Container(
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          double disposableIncome = income - averageAnnualExpenses;
          double maxCarBudget =
              calculateMaxCarBudget(disposableIncome, savings, debts);
          double maxHouseBudget =
              calculateMaxHouseBudget(disposableIncome, savings, debts);

          setState(() {
            result =
                'You can afford a car in the range of: RM${(maxCarBudget * 0.8).toStringAsFixed(2)} - RM${maxCarBudget.toStringAsFixed(2)}\n\n'
                'You can afford a house in the range of: RM${(maxHouseBudget * 0.8).toStringAsFixed(2)} - RM${maxHouseBudget.toStringAsFixed(2)}';
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calculate, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Calculate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[700]!, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Financial Capacity',
            style: TextStyle(
              color: Colors.blue[400],
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...result.split('\n').map((line) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  line,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

double calculateMaxCarBudget(
    double disposableIncome, double savings, double debts) {
  return (disposableIncome * 0.2) + (savings * 0.1) - (debts * 0.05);
}

double calculateMaxHouseBudget(
    double disposableIncome, double savings, double debts) {
  return (disposableIncome * 0.3) + (savings * 0.2) - (debts * 0.1);
}
