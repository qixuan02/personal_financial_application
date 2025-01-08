import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:personal_financial_app/Screen/Investment.dart';
import 'package:personal_financial_app/Screen/StockSuggestionPageMY.dart';
import 'package:personal_financial_app/navbar.dart';

class Stock {
  final String symbol;
  final String company;
  final double price;

  Stock({required this.symbol, required this.company, required this.price});
}

class InvestmentMY extends StatefulWidget {
  @override
  _InvestmentMYState createState() => _InvestmentMYState();
}

class _InvestmentMYState extends State<InvestmentMY> {
  List<Stock> malaysianStocks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMalaysianStockPrices();
  }

  Future<void> _fetchMalaysianStockPrices() async {
    final List<Map<String, String>> stockSymbols = [
      {'symbol': '1023.KL', 'name': 'CIMB Group Holdings'},
      {'symbol': '1155.KL', 'name': 'Maybank'},
      {'symbol': '6012.KL', 'name': 'Maxis'},
      {'symbol': '5347.KL', 'name': 'Tenaga Nasional'},
      {'symbol': '3182.KL', 'name': 'Genting'},
    ];
    List<Stock> stocks = [];

    try {
      for (var stock in stockSymbols) {
        final response = await http.get(
          Uri.parse(
              'https://query1.finance.yahoo.com/v8/finance/chart/${stock['symbol']}'),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Response for ${stock['symbol']}: ${response.body}');

          final price =
              data['chart']['result'][0]['meta']['regularMarketPrice'];

          stocks.add(Stock(
            symbol: stock['symbol']!.replaceAll('.KL', ''),
            company: stock['name']!,
            price: price.toDouble(),
          ));
        } else {
          print(
              'Failed to load stock data for ${stock['symbol']}: ${response.statusCode}');
        }
      }

      setState(() {
        malaysianStocks = stocks;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching stock data: $e');
      setState(() {
        _isLoading = false;
      });
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
                  MaterialPageRoute(builder: (context) => Investment()),
                );
              },
              child: const Text(
                'MY',
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
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Add a stock symbol (e.g., 1155)',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.add, color: Colors.grey[500]),
                      fillColor: Colors.grey[800],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StockSuggestionMYPage()),
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
                          itemCount: malaysianStocks.length,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.grey[400],
                          ),
                          itemBuilder: (context, index) {
                            final stock = malaysianStocks[index];
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
                                    'RM ${stock.price.toStringAsFixed(2)}',
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
