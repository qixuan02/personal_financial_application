import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_financial_app/Screen/InvestmentMY.dart';
import 'package:personal_financial_app/Screen/StockSuggestionPage.dart';
import 'package:personal_financial_app/navbar.dart';
import 'package:personal_financial_app/widgets/fetch_stock_data.dart';

class Investment extends StatefulWidget {
  @override
  _InvestmentState createState() => _InvestmentState();
}

class _InvestmentState extends State<Investment> {
  final List<String> famousStockSymbols = [
    'AAPL',
    'TSLA',
    'MSFT',
    'GOOG',
    'AMZN'
  ];

  List<String> userStockSymbols = [];
  List<Stocks> _stocks = [];
  bool _isLoading = true;

  final _symbolController =
      TextEditingController(); // Controller for adding stocks

  @override
  void initState() {
    super.initState();
    _fetchAllStockPrices();
  }

  // Fetch famous and user-selected stocks
  void _fetchAllStockPrices() async {
    final stockService = StockService();
    final allSymbols = [...famousStockSymbols, ...userStockSymbols];
    final stocks = await stockService.fetchStockPrices(allSymbols);
    setState(() {
      _stocks = stocks;
      _isLoading = false;
    });
  }

  // Add user-selected stock
  void _addUserStock(String symbol) {
    if (symbol.isNotEmpty && !userStockSymbols.contains(symbol.toUpperCase())) {
      setState(() {
        userStockSymbols.add(symbol.toUpperCase());
        _isLoading = true;
      });
      _fetchAllStockPrices(); // Refresh the stock list
      _symbolController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: NavBar(),
        appBar: AppBar(
          title: const Text(
            'Investment',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          backgroundColor: const Color(0xFF292728),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InvestmentMY()),
                );
              },
              child: const Text(
                'US',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width,
          color: Colors.black,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'STOCKS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 17,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    controller: _symbolController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a stock symbol (e.g., NFLX)',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.add, color: Colors.grey[500]),
                      fillColor: Colors.grey[800],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _addUserStock,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StockSuggestionPage()),
                    );
                  },
                  child: Text('View Stock Suggestions'),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.separated(
                          itemCount: _stocks.length,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.grey[400],
                          ),
                          itemBuilder: (context, index) {
                            final stock = _stocks[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.all(10),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    stock.symbol,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    stock.company,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                children: [
                                  Text(
                                    '\$${stock.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
