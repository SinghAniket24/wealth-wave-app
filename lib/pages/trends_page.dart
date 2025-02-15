import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fl_chart/fl_chart.dart';

List<Map<String, dynamic>> watchlist = [];

class TrendsPage extends StatefulWidget {
  const TrendsPage({super.key});
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
            .where((entry) =>
                entry.key.toLowerCase().contains(query.toLowerCase()))
            .map((entry) => {
                  "name": entry.key,
                  "close": entry.value.last["Close"],
                  "high": entry.value.last["High"],
                  "low": entry.value.last["Low"],
                  "volume": entry.value,
                  "history": entry.value,
                })
            .toList();
      }
    });
  }

  void _addToWatchlist(Map<String, dynamic> stock) {
    setState(() {
      if (!watchlist.any((item) => item["name"] == stock["name"])) {
        watchlist.add(stock);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              color: Theme.of(context).cardColor, // Card Background
              child: TextField(
                onChanged: _searchStock,
                decoration: InputDecoration(
                  hintText: "Search Stock",
                  hintStyle: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color), //Body text
                  prefixIcon: Icon(Icons.search,
                      color: Theme.of(context).iconTheme.color), //Icons color
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color), //Body text
              ),
            ),
          ),
          Expanded(
            child: filteredStocks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filteredStocks.length,
                    itemBuilder: (context, index) {
                      var stock = filteredStocks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          color: Theme.of(context).cardColor, // Card Background
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .appBarTheme
                                  .backgroundColor, // AppBar Background
                              child: Text(stock["name"][0],
                                  style: const TextStyle(
                                      color: Colors.white)), //AppBar text color
                            ),
                            title: Text(stock["name"],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.color)), //Headline text
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Close: ₹${stock["close"]}",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color)), //Body text
                                Text("High: ₹${stock["high"]}",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color)), //Body text
                                Text("Low: ₹${stock["low"]}",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color)), //Body text
                              ],
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.add,
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color), //Icons color
                              onPressed: () => _addToWatchlist(stock),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        StockDetailPage(stock: stock)),
                              );
                            },
                          ),
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

class StockDetailPage extends StatefulWidget {
  final Map<String, dynamic> stock;
  const StockDetailPage({super.key, required this.stock});
  @override
  _StockDetailPageState createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  List<FlSpot> spots = [];
  List<String> dates = [];
  Map<String, List<Map<String, dynamic>>> predictions = {};

  @override
  void initState() {
    super.initState();
    _loadPredictions();
    _prepareStockData();
  }

  Future<void> _loadPredictions() async {
    try {
      String jsonString =
          await rootBundle.loadString('assets/predictions.json');
      Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        predictions = {
          widget.stock["name"]:
              List<Map<String, dynamic>>.from(jsonData[widget.stock["name"]])
        };
      });
    } catch (e) {
      print("Error loading predictions: $e");
    }
  }

  void _prepareStockData() {
    for (int i = 0; i < widget.stock["history"].length; i++) {
      var entry = widget.stock["history"][i];
      spots.add(FlSpot(i.toDouble(), entry["Close"].toDouble()));
      dates.add(entry["Date"].split(" ")[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.stock["name"],
            style: const TextStyle(color: Colors.white)), //AppBar text color
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor, // AppBar Background
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: Theme.of(context).cardColor, // Card Background
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Stock Details",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.color)), //Headline text
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: Text("Close: ₹${widget.stock["close"]}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color))), //Body text
                          Expanded(
                              child: Text("High: ₹${widget.stock["high"]}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color))), //Body text
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: Text("Low: ₹${widget.stock["low"]}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color))), //Body text
                          Expanded(
                              child: Text("Volume: ${widget.stock["volume"]}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color))), //Body text
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: Theme.of(context).cardColor, // Card Background
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Closing Price Graph",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.color)), //Headline text
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 250,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              drawVerticalLine: true,
                              getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey.withOpacity(0.3),
                                  strokeWidth: 0.5),
                              getDrawingVerticalLine: (value) => FlLine(
                                  color: Colors.grey.withOpacity(0.3),
                                  strokeWidth: 0.5),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) => Text(
                                    value.toStringAsFixed(0),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color), //Body text
                                  ),
                                  reservedSize: 40,
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int index = value.toInt();
                                    if (index < dates.length) {
                                      return Text(
                                        dates[index],
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.color), //Body text
                                      );
                                    }
                                    return const Text('');
                                  },
                                  reservedSize: 22,
                                  interval: (spots.length / 5).ceilToDouble(),
                                ),
                              ),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                    color: Colors.grey.withOpacity(0.5))),
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                dotData: const FlDotData(show: false),
                                color: const Color.fromARGB(255, 130, 239, 122),
                                belowBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: Theme.of(context).cardColor, // Card Background
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Predictions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).iconTheme.color, //Icons color
                        ),
                      ),
                      const SizedBox(height: 12),
                      predictions.isNotEmpty &&
                              predictions[widget.stock["name"]] != null
                          ? SizedBox(
                              height: 180,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    predictions[widget.stock["name"]]!.length,
                                itemBuilder: (context, index) {
                                  var prediction =
                                      predictions[widget.stock["name"]]![index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: Container(
                                      width: 220,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.green[50]!,
                                            Colors.green[100]!
                                          ], // Light green gradient
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.1),
                                            spreadRadius: 3,
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Date: ${prediction["Date"]}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.green[
                                                  700], // Darker green for text
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "₹${prediction["Predicted Close Price (INR)"]}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[
                                                  800], // Darker green for price
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  "No predictions available",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color, //Body text
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
