import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:personal_financial_app/navbar.dart';
import '../database_helpers/category_database.dart';
import '../database_helpers/category_limit_database.dart';

class ChartPage extends StatefulWidget {
  @override
  _ChartPageState createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  final CategoryDatabaseHelper _categoryDbHelper = CategoryDatabaseHelper();
  final CategoryLimitDatabaseHelper _limitDbHelper =
      CategoryLimitDatabaseHelper();
  List<double> expensesData = [200, 300, 150, 400]; // Sample data for expenses
  List<double> financialData = [
    500,
    700,
    300,
    900
  ]; // Sample data for financial chart

  @override
  void initState() {
    super.initState();
    // Load your data here if needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Charts', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black, // Set the background color to black
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Expenses Chart
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Expenses Chart',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Card(
                color: Colors.grey[850],
                elevation: 4,
                child: Container(
                  height: 250,
                  padding: EdgeInsets.all(8.0),
                  child: PieChart(
                    PieChartData(
                      sections: showingExpenseSections(),
                      borderData: FlBorderData(show: false),
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ),
              // Financial Chart
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Financial Chart',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              Card(
                color: Colors.grey[850],
                elevation: 4,
                child: Container(
                  height: 250,
                  padding: EdgeInsets.all(8.0),
                  child: PieChart(
                    PieChartData(
                      sections: showingFinancialSections(),
                      borderData: FlBorderData(show: false),
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingExpenseSections() {
    return List.generate(expensesData.length, (i) {
      final isTouched = i == 0; // Example for touch effect
      final fontSize = isTouched ? 25 : 16;
      final radius = isTouched ? 60 : 50;
      return PieChartSectionData(
        color: Colors.primaries[i % Colors.primaries.length],
        value: expensesData[i].toDouble(), // Convert int to double
        title: '${expensesData[i]}',
        radius: radius.toDouble(), // Ensure radius is a double
        titleStyle: TextStyle(
            fontSize: fontSize.toDouble(),
            color: Colors.white), // Convert fontSize to double
      );
    });
  }

  List<PieChartSectionData> showingFinancialSections() {
    return List.generate(financialData.length, (i) {
      final isTouched = i == 0; // Example for touch effect
      final fontSize = isTouched ? 25 : 16;
      final radius = isTouched ? 60 : 50;
      return PieChartSectionData(
        color: Colors.primaries[(i + expensesData.length) %
            Colors.primaries.length], // Ensure different colors
        value: financialData[i].toDouble(), // Convert int to double
        title: '${financialData[i]}',
        radius: radius.toDouble(), // Ensure radius is a double
        titleStyle: TextStyle(
            fontSize: fontSize.toDouble(),
            color: Colors.white), // Convert fontSize to double
      );
    });
  }
}
