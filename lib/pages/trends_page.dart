import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:fl_chart/fl_chart.dart';
import 'responsive.dart';

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
      backgroundColor: Colors.blue[50]!,
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
                        child:AnimatedOpacity(
  opacity: 1.0,
  duration: Duration(milliseconds: 500),
  child: Card(
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Theme.of(context).cardColor, // Card Background
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor, // AppBar Background
        child: Text(stock["name"][0],
            style: const TextStyle(color: Colors.white)), 
      ),
      title: Text(stock["name"],
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color)), // Headline text
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Close: ₹${stock["close"]}",
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)), // Body text
          Text("High: ₹${stock["high"]}",
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)), // Body text
          Text("Low: ₹${stock["low"]}",
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)), // Body text
        ],
      ),
      trailing: IconButton(
  icon: Icon(Icons.add, color: Theme.of(context).iconTheme.color), 
  tooltip: 'Add to Watchlist', // Tooltip text
  onPressed: () {
    _addToWatchlist(stock);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to Watchlist'),
        duration: Duration(seconds: 2),
      ),
    );
  },
),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StockDetailPage(stock: stock)),
        );
      },
    ),
  ),
)

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
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  color: Theme.of(context).cardColor, // Card Background
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Stock Details",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ), // Headline text
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            double fontSize = constraints.maxWidth < 400 ? 14 : 16; // Responsive text size
            return Wrap(
              spacing: 16, // Space between items
              runSpacing: 8, // Space between rows
              alignment: WrapAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: (constraints.maxWidth / 2) - 16, // Ensure two columns
                  child: Text(
                    "Close: ₹${double.parse(widget.stock["close"].toString()).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth / 2) - 16,
                  child: Text(
                    "High: ₹${double.parse(widget.stock["high"].toString()).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth / 2) - 16,
                  child: Text(
                    "Low: ₹${double.parse(widget.stock["low"].toString()).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth / 2) - 16,
                  child: Text(
                    "Volume: ${double.parse(widget.stock["volume"].toString()).toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ],
            );
          },
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
  height: MediaQuery.of(context).size.height * 0.4, // Responsive height
  width: MediaQuery.of(context).size.width * 0.9, // Responsive width
  child: LineChart(
    LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${dates[spot.x.toInt()]}\nPrice: ${spot.y}',
                TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: MediaQuery.of(context).size.width > 600 ? 14 : 10, // Larger on laptops, smaller on mobile
                ),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.3),
          strokeWidth: 0.5,
        ),
        getDrawingVerticalLine: (value) => FlLine(
          color: Colors.grey.withOpacity(0.3),
          strokeWidth: 0.5,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true, // Show left labels
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(0),
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 600 ? 14 : 10, // Adjusted for laptops & mobile
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            reservedSize: MediaQuery.of(context).size.width > 600 ? 50 : 40, // More space for bigger screens
          ),
        ),
        bottomTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false), // Hide bottom labels
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Colors.grey.withOpacity(0.5),
        ),
      ),
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
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  color: Theme.of(context).cardColor,
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = MediaQuery.of(context).size.width;
        bool isMobile = screenWidth < 600;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Predictions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            const SizedBox(height: 12),
            predictions.isNotEmpty && predictions[widget.stock["name"]] != null
                ? SizedBox(
                    height: isMobile ? 140 : 180, // **Shorter height for mobile**
                    width: double.infinity,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: predictions[widget.stock["name"]]!.length,
                      itemBuilder: (context, index) {
                        var prediction = predictions[widget.stock["name"]]![index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Container(
                            width: isMobile ? screenWidth * 0.6 : 220, // **Smaller width on mobile**
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.green[50]!, Colors.green[100]!],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date: ${prediction["Date"]}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green[700],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "₹${prediction["Predicted Close Price (INR)"]}",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[800],
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
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        "No predictions available",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
          ],
        );
      },
    ),
  ),
),


            ],
          ),
        ),
      ),
    );
  }
}
