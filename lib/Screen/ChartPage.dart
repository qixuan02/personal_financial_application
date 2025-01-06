import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_financial_app/models/financial_model.dart';
import 'package:personal_financial_app/navbar.dart';
import '../database_helpers/database_helper.dart';
import 'package:flutter/widgets.dart';
import 'package:personal_financial_app/database_helpers/financial_database_helper.dart';

class ChartPage extends StatefulWidget {
  final int currentYear;

  ChartPage({required this.currentYear}); // Constructor

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
        title: Text('Chart', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 24, 24, 24),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: PageView.builder(
        itemCount: months.length * 2,
        onPageChanged: (index) {
          setState(() {
            currentMonthIndex = index % months.length;
            int year = index < months.length
                ? widget.currentYear
                : widget.currentYear -
                    1; // Assuming previousYear is not defined
            _loadData(currentMonthIndex, year);
          });
        },
        itemBuilder: (context, index) {
          int year = index < months.length
              ? widget.currentYear
              : widget.currentYear - 1;
          return Container(
            color: Colors.black,
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    '${_getMonthName(months[currentMonthIndex])} $year',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Expenses Overview',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                Card(
                  color: Colors.black,
                  elevation: 4,
                  child: Container(
                    height: 250,
                    padding: EdgeInsets.all(8.0),
                    child: PieChart(
                      PieChartData(
                        sections: expenseSections,
                        borderData: FlBorderData(show: false),
                        centerSpaceRadius: 60,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Financial Overview',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                Card(
                  color: Colors.black,
                  elevation: 4,
                  child: Container(
                    height: 250,
                    padding: EdgeInsets.all(8.0),
                    child: PieChart(
                      PieChartData(
                        sections: financialSections,
                        borderData: FlBorderData(show: false),
                        centerSpaceRadius: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
