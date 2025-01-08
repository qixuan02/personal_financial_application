import 'package:flutter/material.dart';
import 'package:personal_financial_app/database_helpers/financial_database_helper.dart';
import 'package:personal_financial_app/database_helpers/database_helper.dart';
import 'package:personal_financial_app/models/expense_model.dart';

class StockSuggestionMYPage extends StatefulWidget {
  @override
  _StockSuggestionMYPageState createState() => _StockSuggestionMYPageState();
}

class _StockSuggestionMYPageState extends State<StockSuggestionMYPage> {
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

    if (debtToIncomeRatio > 0.5 || availableFunds <= 0) {
      _investmentCapacity = 'Limited';
    } else if (monthlyDisposableIncome < 500 || availableFunds < 1000) {
      _investmentCapacity = 'Conservative';
    } else if (monthlyDisposableIncome < 2000 || availableFunds < 5000) {
      _investmentCapacity = 'Moderate';
    } else {
      _investmentCapacity = 'Growth';
    }

    if (availableFunds > 0) {
      switch (_investmentCapacity) {
        case 'Limited':
          _suggestedStocks = [
            {
              'type': 'Micro-Investment Stocks',
              'priceRange': 'RM1 - RM5 per share',
              'description':
                  'Start small with fractional shares or penny stocks',
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
              'priceRange': 'RM5 - RM20 per share',
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
              'priceRange': 'RM20 - RM50 per share',
              'description': 'Companies with good growth potential',
              'allocation': (availableFunds * 0.4).toStringAsFixed(2),
              'riskLevel': 'Medium',
              'suggestion': 'Mix of ETFs and individual stocks'
            },
            {
              'type': 'Dividend Stocks',
              'priceRange': 'RM30 - RM70 per share',
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
              'priceRange': 'RM50 - RM200 per share',
              'description': 'Large, stable companies',
              'allocation': (availableFunds * 0.4).toStringAsFixed(2),
              'riskLevel': 'Medium',
              'suggestion': 'Build a diversified portfolio'
            },
            {
              'type': 'Growth Stocks',
              'priceRange': 'RM30 - RM150 per share',
              'description': 'High-growth potential companies',
              'allocation': (availableFunds * 0.3).toStringAsFixed(2),
              'riskLevel': 'High',
              'suggestion': 'Research thoroughly before investing'
            },
            {
              'type': 'Dividend Growth',
              'priceRange': 'RM40 - RM100 per share',
              'description': 'Increasing dividend payments',
              'allocation': (availableFunds * 0.3).toStringAsFixed(2),
              'riskLevel': 'Medium',
              'suggestion': 'Look for consistent dividend growth'
            },
          ];
          break;
      }
    } else {
      _suggestedStocks = [
        {
          'type': 'Notice',
          'priceRange': 'N/A',
          'description': 'Focus on building savings and reducing debt first',
          'allocation': '0.00',
          'riskLevel': 'N/A',
          'suggestion': 'Create an emergency fund before investing'
        }
      ];
    }

    setState(() {});
  }

  Color _getCapacityColor(String capacity) {
    switch (capacity) {
      case 'Limited':
        return Colors.red[100]!;
      case 'Conservative':
        return Colors.orange[100]!;
      case 'Moderate':
        return Colors.blue[100]!;
      case 'Growth':
        return Colors.green[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getCapacityTextColor(String capacity) {
    switch (capacity) {
      case 'Limited':
        return Colors.red[800]!;
      case 'Conservative':
        return Colors.orange[800]!;
      case 'Moderate':
        return Colors.blue[800]!;
      case 'Growth':
        return Colors.green[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  Color _getRiskBadgeColor(String risk) {
    switch (risk) {
      case 'Low':
        return Colors.green[100]!;
      case 'Low-Medium':
        return Colors.blue[100]!;
      case 'Medium':
        return Colors.yellow[100]!;
      case 'High':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  Color _getRiskTextColor(String risk) {
    switch (risk) {
      case 'Low':
        return Colors.green[800]!;
      case 'Low-Medium':
        return Colors.blue[800]!;
      case 'Medium':
        return Colors.yellow[800]!;
      case 'High':
        return Colors.red[800]!;
      default:
        return Colors.grey[800]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Stock Suggestions',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCapacityColor(_investmentCapacity),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '$_investmentCapacity Capacity',
                    style: TextStyle(
                      color: _getCapacityTextColor(_investmentCapacity),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Card(
              color: Colors.grey[900],
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.blue[400]),
                        SizedBox(width: 8),
                        Text(
                          'Financial Summary',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      childAspectRatio: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildSummaryItem('Monthly Income', _averageIncome),
                        _buildSummaryItem('Total Savings', _totalSavings),
                        _buildSummaryItem('Total Debts', _totalDebts),
                        _buildSummaryItem(
                            'Monthly Expenses', _totalExpenses / 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Card(
              color: Colors.grey[900],
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.blue[400]),
                        SizedBox(width: 8),
                        Text(
                          'Investment Suggestions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ..._suggestedStocks.map((stock) => _buildStockCard(stock)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'RM${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStockCard(Map<String, dynamic> stock) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[800]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stock['type'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      stock['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRiskBadgeColor(stock['riskLevel']),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${stock['riskLevel']} Risk',
                  style: TextStyle(
                    color: _getRiskTextColor(stock['riskLevel']),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Range',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      stock['priceRange'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggested Allocation',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'RM${stock['allocation']}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[400]),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  stock['suggestion'],
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.blue[400],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
