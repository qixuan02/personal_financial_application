import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_financial_app/navbar.dart';
import '../database_helpers/database_helper.dart';
import 'package:flutter/widgets.dart';

class ChartPage extends StatefulWidget {
  final int year; // Year for which to display expenses

  ChartPage({required this.year}); // Constructor

  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<PieChartSectionData> expenseSections = [];
  int currentMonthIndex = 0; // Track the current month index
  final List<int> months =
      List.generate(12, (index) => index + 1); // List of months

  @override
  void initState() {
    super.initState();
    _loadData(currentMonthIndex); // Load data for the initial month
  }

  Future<void> _loadData(int monthIndex) async {
    final month = months[monthIndex]; // Get the month from the index
    final Map<String, double> categoryExpenses = await _databaseHelper
        .getCategoryExpensesForMonth(widget.year, month); // Fetch data
    print(
        'Fetched Category Expenses for ${month}/${widget.year}: $categoryExpenses'); // Debug print
    setState(() {
      expenseSections = _generateExpenseSections(categoryExpenses.entries
          .map((e) => {'category': e.key, 'total': e.value})
          .toList()); // Generate sections for the pie chart
    });
  }

  List<PieChartSectionData> _generateExpenseSections(
      List<Map<String, dynamic>> categoryExpenses) {
    final totalExpenses = categoryExpenses.fold<double>(
        0,
        (sum, item) =>
            sum +
            (item['total'] as num).toDouble()); // Calculate total expenses

    return List.generate(categoryExpenses.length, (i) {
      final category = categoryExpenses[i]['category'];
      final total = (categoryExpenses[i]['total'] as num).toDouble();
      final percentage = (total / totalExpenses * 100)
          .toStringAsFixed(2); // Calculate percentage

      return PieChartSectionData(
        color: Colors.primaries[i % Colors.primaries.length],
        value: total,
        title: '$category\n$percentage%', // Update title to show percentage
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, color: Colors.white),
      );
    });
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
    return monthNames[month - 1]; // Adjust for zero-based index
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Chart', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: PageView.builder(
        itemCount: months.length,
        onPageChanged: (index) {
          setState(() {
            currentMonthIndex = index; // Update current month index
            _loadData(currentMonthIndex); // Load data for the new month
          });
        },
        itemBuilder: (context, index) {
          return Container(
            color: Colors.black, // Set the background color to black
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Expenses Chart
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    '${_getMonthName(months[index])} ${widget.year}', // Display month name
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
                        sections: expenseSections, // Use the generated sections
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
