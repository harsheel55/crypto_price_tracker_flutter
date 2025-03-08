import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(CryptoApp());
}

class CryptoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Price Tracker',
      theme: ThemeData.dark(),
      home: CryptoHomePage(),
    );
  }
}

class CryptoHomePage extends StatefulWidget {
  @override
  _CryptoHomePageState createState() => _CryptoHomePageState();
}

class _CryptoHomePageState extends State<CryptoHomePage> {
  List cryptoData = [];
  final String apiKey = "CG-DpUAt3ebzgfnJYvLKTvW3Fqm";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchCryptoData();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) => fetchCryptoData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchCryptoData() async {
    final url = Uri.parse(
        'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=10&page=1&sparkline=true');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        cryptoData = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crypto Tracker')),
      body: cryptoData.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: cryptoData.length,
              itemBuilder: (context, index) {
                var coin = cryptoData[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 5,
                  child: ListTile(
                    leading: Image.network(coin['image'], width: 40),
                    title: Text(coin['name'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text("\$${coin['current_price'].toString()}", style: TextStyle(fontSize: 16)),
                    trailing: Text(
                      "${coin['price_change_percentage_24h'].toStringAsFixed(2)}%",
                      style: TextStyle(
                          color: coin['price_change_percentage_24h'] >= 0
                              ? Colors.green
                              : Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
