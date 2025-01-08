import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_financial_app/models/financial_model.dart';
import 'package:personal_financial_app/navbar.dart';
import '../database_helpers/database_helper.dart';
import 'package:personal_financial_app/database_helpers/financial_database_helper.dart';

class ChartPage extends StatefulWidget {
  final int currentYear;

  ChartPage({required this.currentYear});

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FinancialDatabaseHelper _financialDatabaseHelper =
      FinancialDatabaseHelper();
  List<PieChartSectionData> expenseSections = [];
  List<PieChartSectionData> financialSections = [];
  List<FinancialModel> financialData = [];
  int currentMonthIndex = 0;
  final List<int> months = List.generate(12, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    _loadData(currentMonthIndex, widget.currentYear);
    _loadFinancialData();
  }

  Future<void> _loadData(int monthIndex, int year) async {
    final month = months[monthIndex];
    final Map<String, double> categoryExpenses =
        await _databaseHelper.getCategoryExpensesForMonth(year, month);
    print('Fetched Category Expenses for ${month}/${year}: $categoryExpenses');
    setState(() {
      expenseSections = _generateExpenseSections(categoryExpenses.entries
          .map((e) => {'category': e.key, 'total': e.value})
          .toList());
    });
  }

  Future<void> _loadFinancialData() async {
    List<FinancialModel> incomeData =
        await _financialDatabaseHelper.getFinancialData('income');
    List<FinancialModel> savingsData =
        await _financialDatabaseHelper.getFinancialData('savings');
    List<FinancialModel> debtsData =
        await _financialDatabaseHelper.getFinancialData('loan');

    Map<String, double> categorizedFinancialData = {
      'Income': incomeData.fold<double>(0, (sum, item) => sum + item.amount),
      'Savings': savingsData.fold<double>(0, (sum, item) => sum + item.amount),
      'Loans': debtsData.fold<double>(0, (sum, item) => sum + item.amount),
    };

    setState(() {
      financialSections = _generateFinancialSections(categorizedFinancialData);
    });
  }

  List<PieChartSectionData> _generateExpenseSections(
      List<Map<String, dynamic>> categoryExpenses) {
    final totalExpenses = categoryExpenses.fold<double>(
        0, (sum, item) => sum + (item['total'] as num).toDouble());

    return List.generate(categoryExpenses.length, (i) {
      final category = categoryExpenses[i]['category'];
      final total = (categoryExpenses[i]['total'] as num).toDouble();
      final percentage = (total / totalExpenses * 100).toStringAsFixed(2);

      return PieChartSectionData(
        color: Colors.primaries[i % Colors.primaries.length],
        value: total,
        title: '$category\n$percentage%',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, color: Colors.white),
      );
    });
  }

  List<PieChartSectionData> _generateFinancialSections(
      Map<String, double> financialData) {
    final totalFinancial =
        financialData.values.fold<double>(0, (sum, item) => sum + item);

    return financialData.entries.map((entry) {
      final category = entry.key;
      final total = entry.value;
      final percentage = (total / totalFinancial * 100).toStringAsFixed(2);

      return PieChartSectionData(
        color: Colors.primaries[financialData.keys.toList().indexOf(category) %
            Colors.primaries.length],
        value: total,
        title: '$category\n$percentage%',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, color: Colors.white),
      );
    }).toList();
  }

  String _getMonthName(int month) {
    const List<String> monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Financial Analytics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            )),
        backgroundColor: const Color.fromARGB(255, 24, 24, 24),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 24, 24, 24),
              Colors.black,
            ],
          ),
        ),
        child: PageView.builder(
          itemCount: months.length * 2,
          onPageChanged: (index) {
            setState(() {
              currentMonthIndex = index % months.length;
              int year = index < months.length
                  ? widget.currentYear
                  : widget.currentYear - 1;
              _loadData(currentMonthIndex, year);
            });
          },
          itemBuilder: (context, index) {
            int year = index < months.length
                ? widget.currentYear
                : widget.currentYear - 1;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_getMonthName(months[currentMonthIndex])} $year',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildChartSection(
                      'Expenses Overview',
                      expenseSections,
                      Colors.orange,
                    ),
                    SizedBox(height: 24),
                    _buildChartSection(
                      'Financial Overview',
                      financialSections,
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChartSection(
      String title, List<PieChartSectionData> sections, Color accentColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  margin: EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            padding: EdgeInsets.all(16),
            child: PieChart(
              PieChartData(
                sections: sections,
                borderData: FlBorderData(show: false),
                centerSpaceRadius: 60,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
