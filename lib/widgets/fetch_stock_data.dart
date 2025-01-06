import 'dart:convert';
import 'package:http/http.dart' as http;

class Stocks {
  final String symbol;
  final String company;
  final double price;

  Stocks({required this.symbol, required this.company, required this.price});
}

class StockService {
  final String apiKey = 'ct04c6hr01qo5uuene7gct04c6hr01qo5uuene80';

  Future<List<Stocks>> fetchStockPrices(List<String> symbols) async {
    List<Stocks> stocks = [];
    for (String symbol in symbols) {
      final String url =
          'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final stock = Stocks(
            symbol: symbol,
            company:
                symbol, // Replace with a mapping of symbol to company name if needed
            price:
                (data['c'] ?? 0).toDouble(), // Ensure it's converted to double
          );
          stocks.add(stock);
        } else {
          print('Error fetching $symbol: ${response.statusCode}');
        }
      } catch (e) {
        print('Error fetching $symbol: $e');
      }
    }
    return stocks;
  }
}
