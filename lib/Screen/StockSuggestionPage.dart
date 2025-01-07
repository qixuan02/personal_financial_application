import 'package:flutter/material.dart';
import 'package:personal_financial_app/database_helpers/financial_database_helper.dart';
import 'package:personal_financial_app/database_helpers/database_helper.dart';
import 'package:personal_financial_app/models/expense_model.dart';

class StockSuggestionPage extends StatefulWidget {
  @override
  _StockSuggestionPageState createState() => _StockSuggestionPageState();
}

class _StockSuggestionPageState extends State<StockSuggestionPage> {
  double _averageIncome = 0;
  double _totalSavings = 0;
  double _totalDebts = 0;
  double _totalExpenses = 0;
  List<Map<String, dynamic>> _suggestedStocks = [];
  String _investmentCapacity = '';

  @override
  void initState() {
    super.initState();
    _fetchFinancialData();
  }

  Future<void> _fetchFinancialData() async {
    FinancialDatabaseHelper financialDbHelper = FinancialDatabaseHelper();
    DatabaseHelper expenseDbHelper = DatabaseHelper();

    _averageIncome = await financialDbHelper.getAverageIncome();
    _totalSavings = await financialDbHelper.getTotalSavings();
    _totalDebts = await financialDbHelper.getTotalDebts();
    _totalExpenses = await _calculateTotalExpenses(expenseDbHelper);

    _calculateStockSuggestions();
  }

  Future<double> _calculateTotalExpenses(DatabaseHelper dbHelper) async {
    List<ExpenseModel> expenses = await dbHelper.getAllExpenses();
    return expenses.fold<double>(0, (sum, item) => sum + item.amount);
  }

  void _calculateStockSuggestions() {
    double availableFunds = _totalSavings - _totalDebts - _totalExpenses;
    double monthlyDisposableIncome = _averageIncome - (_totalExpenses / 12);
    double debtToIncomeRatio = _totalDebts / (_averageIncome * 12);

    // Determine investment capacity
    if (debtToIncomeRatio > 0.5 || availableFunds <= 0) {
      _investmentCapacity = 'Limited';
    } else if (monthlyDisposableIncome < 500 || availableFunds < 1000) {
      _investmentCapacity = 'Conservative';
    } else if (monthlyDisposableIncome < 2000 || availableFunds < 5000) {
      _investmentCapacity = 'Moderate';
    } else {
      _investmentCapacity = 'Growth';
    }

    // Generate suggestions based on investment capacity
    if (availableFunds > 0) {
      switch (_investmentCapacity) {
        case 'Limited':
          _suggestedStocks = [
            {
              'type': 'Micro-Investment Stocks',
              'priceRange': '\$1 - \$5 per share',
              'description': 'Start small with fractional shares or penny stocks',
              'allocation': (availableFunds * 0.1).toStringAsFixed(2),
              'riskLevel': 'Moderate',
              'suggestion': 'Consider focusing on debt repayment first'
            },
          ];
          break;

        case 'Conservative':
          _suggestedStocks = [
            {
              'type': 'Value Stocks',
              'priceRange': '\$5 - \$20 per share',
              'description': 'Stable companies with reliable dividends',
              'allocation': (availableFunds * 0.3).toStringAsFixed(2),
              'riskLevel': 'Low',
              'suggestion': 'Start with ETFs or index funds'
            },
            {
              'type': 'Fractional Shares',
              'priceRange': 'Any price (partial shares)',
              'description': 'Buy portions of expensive stocks',
              'allocation': (availableFunds * 0.2).toStringAsFixed(2),
              'riskLevel': 'Varies',
              'suggestion': 'Use apps that offer fractional trading'
            },
          ];
          break;

        case 'Moderate':
          _suggestedStocks = [
            {
              'type': 'Growth Stocks',
              'priceRange': '\$20 - \$50 per share',
              'description': 'Companies with good growth potential',
              'allocation': (availableFunds * 0.4).toStringAsFixed(2),
              'riskLevel': 'Medium',
              'suggestion': 'Mix of ETFs and individual stocks'
            },
            {
              'type': 'Dividend Stocks',
              'priceRange': '\$30 - \$70 per share',
              'description': 'Regular income through dividends',
              'allocation': (availableFunds * 0.3).toStringAsFixed(2),
              'riskLevel': 'Low-Medium',
              'suggestion': 'Focus on dividend aristocrats'
            },
          ];
          break;

        case 'Growth':
          _suggestedStocks = [
            {
              'type': 'Blue-Chip Stocks',
              'priceRange': '\$50 - \$200 per share',
              'description': 'Large, stable companies',
              'allocation': (availableFunds * 0.4).toStringAsFixed(2),
              'riskLevel': 'Medium',
              'suggestion': 'Build a diversified portfolio'
            },
            {
              'type': 'Growth Stocks',
              'priceRange': '\$30 - \$150 per share',
              'description': 'High-growth potential companies',
              'allocation': (availableFunds * 0.3).toStringAsFixed(2),
              'riskLevel': 'High',
              'suggestion': 'Research thoroughly before investing'
            },
            {
              'type': 'Dividend Growth',
              'priceRange': '\$40 - \$100 per share',
              'description': 'Increasing dividend payments',
              'allocation': (availableFunds * 0.3).toStringAsFixed(2),
              'riskLevel': 'Medium',
              'suggestion': 'Look for consistent dividend growth'
            },
          ];
          break;
      }
    } else {
      _suggestedStocks = [{
        'type': 'Notice',
        'priceRange': 'N/A',
        'description': 'Focus on building savings and reducing debt first',
        'allocation': '0.00',
        'riskLevel': 'N/A',
        'suggestion': 'Create an emergency fund before investing'
      }];
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Suggestions'),
        backgroundColor: Colors.black54,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinancialSummary(),
            SizedBox(height: 20),
            _buildInvestmentCapacity(),
            SizedBox(height: 20),
            Text(
              'Personalized Investment Suggestions:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _suggestedStocks.length,
                itemBuilder: (context, index) {
                  return _buildStockSuggestionCard(_suggestedStocks[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestmentCapacity() {
    Color capacityColor;
    switch (_investmentCapacity) {
      case 'Limited':
        capacityColor = Colors.red;
        break;
      case 'Conservative':
        capacityColor = Colors.orange;
        break;
      case 'Moderate':
        capacityColor = Colors.blue;
        break;
      case 'Growth':
        capacityColor = Colors.green;
        break;
      default:
        capacityColor = Colors.grey;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex:3,
              child: Text(
                'Investment Capacity:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _investmentCapacity,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: capacityColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 10),
            _buildSummaryRow('Monthly Income', _averageIncome),
            _buildSummaryRow('Total Savings', _totalSavings),
            _buildSummaryRow('Total Debts', _totalDebts),
            _buildSummaryRow('Monthly Expenses', _totalExpenses / 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockSuggestionCard(Map<String, dynamic> stock) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stock['type'],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 8),
            _buildStockDetail('Price Range', stock['priceRange']),
            _buildStockDetail('Suggested Allocation', '\$${stock['allocation']}'),
            _buildStockDetail('Risk Level', stock['riskLevel']),
            SizedBox(height: 8),
            Text(
              stock['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Suggestion: ${stock['suggestion']}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.italic,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}