import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fl_chart/fl_chart.dart';

// Global list to store the watchlist items
List<Map<String, dynamic>> watchlist = [];

class TrendsPage extends StatefulWidget {
  @override
  _TrendsPageState createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  Map<String, List<Map<String, dynamic>>> stockData = {};
  List<Map<String, dynamic>> filteredStocks = [];

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  Future<void> _loadStockData() async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/nifty_stock_sheet_sort1.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);

      Map<String, List<Map<String, dynamic>>> tempStockData = {};
      jsonData.forEach((company, values) {
        tempStockData[company] = List<Map<String, dynamic>>.from(values);
      });

      setState(() {
        stockData = tempStockData;
        _generateStockList();
      });
    } catch (e) {
      print("Error loading stock data: $e");
    }
  }

  void _generateStockList() {
    List<Map<String, dynamic>> tempList = [];
    stockData.forEach((company, values) {
      if (values.isNotEmpty) {
        tempList.add({
          "name": company,
          "close": values.last["Close"],
          "high": values.last["High"],
          "low": values.last["Low"],
          "volume": values.last["Volume"],
          "history": values,
        });
      }
    });

    setState(() {
      filteredStocks = tempList;
    });
  }

  void _searchStock(String query) {
    setState(() {
      if (query.isEmpty) {
        _generateStockList();
      } else {
        filteredStocks = stockData.entries
            .where((entry) => entry.key.toLowerCase().contains(query.toLowerCase()))
            .map((entry) => {
                  "name": entry.key,
                  "close": entry.value.last["Close"],
                  "high": entry.value.last["High"],
                  "low": entry.value.last["Low"],
                  "volume": entry.value.last["Volume"],
                  "history": entry.value,
                })
            .toList();
      }
    });
  }

  void _addToWatchlist(Map<String, dynamic> stock) {
    setState(() {
      // Add the stock to the global watchlist if not already present
      if (!watchlist.any((item) => item["name"] == stock["name"])) {
        watchlist.add(stock);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Stock Trends"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: _searchStock,
              decoration: InputDecoration(
                hintText: "Search Stock",
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredStocks.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredStocks.length,
                    itemBuilder: (context, index) {
                      var stock = filteredStocks[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple,
                            child: Text(
                              stock["name"][0],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(stock["name"],
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              "Close: ₹${stock["close"]}\nHigh: ₹${stock["high"]}\nLow: ₹${stock["low"]}"),
                          trailing: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () => _addToWatchlist(stock),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StockDetailPage(stock: stock),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class StockDetailPage extends StatelessWidget {
  final Map<String, dynamic> stock;

  StockDetailPage({required this.stock});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    List<String> dates = [];
    for (int i = 0; i < stock["history"].length; i++) {
      var entry = stock["history"][i];
      spots.add(FlSpot(i.toDouble(), entry["Close"].toDouble()));
      dates.add(entry["Date"].split(" ")[0]); // Extracting Date
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(stock["name"]),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Stock Details",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("📉 Close: ₹${stock["close"]}"),
            Text("📈 High: ₹${stock["high"]}"),
            Text("📉 Low: ₹${stock["low"]}"),
            Text("📊 Volume: ${stock["volume"]}"),
            SizedBox(height: 20),
            Text("Closing Price Graph",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) =>
                          FlLine(color: Colors.grey, strokeWidth: 0.5),
                      getDrawingVerticalLine: (value) =>
                          FlLine(color: Colors.grey, strokeWidth: 0.5)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(0),
                              style: TextStyle(fontSize: 12));
                        },
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index < dates.length) {
                            return Text(dates[index],
                                style: TextStyle(fontSize: 10),
                                textAlign: TextAlign.center);
                          }
                          return Text('');
                        },
                        reservedSize: 22,
                        interval: (spots.length / 5).ceilToDouble(),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.deepPurple,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}