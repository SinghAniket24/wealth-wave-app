import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for loading assets
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class StockData {
  final String date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  StockData({required this.date, required this.open, required this.high, required this.low, required this.close, required this.volume});

  factory StockData.fromJson(Map<String, dynamic> json) {
    return StockData(
      date: json['Date'],
      open: json['Open'],
      high: json['High'],
      low: json['Low'],
      close: json['Close'],
      volume: json['Volume'].toDouble(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WealthWave',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<StockData> stockData = [];

  @override
  void initState() {
    super.initState();
    loadStockData();
  }

  Future<void> loadStockData() async {
    String jsonString = await rootBundle.loadString('assets/nft.json');
    Map<String, dynamic> jsonResponse = json.decode(jsonString);
    List<dynamic> sheetData = jsonResponse['Sheet1'];

    setState(() {
      stockData = sheetData.map((data) => StockData.fromJson(data)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WealthWave', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: stockData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Nifty Closing Price vs Date',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                InteractiveGraph(data: stockData),
                const SizedBox(height: 20),
                const Text(
                  'Stock Indicators',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                StockIndicators(
                  allTimeHigh: stockData.map((e) => e.high).reduce((a, b) => a > b ? a : b),
                  allTimeLow: stockData.map((e) => e.low).reduce((a, b) => a < b ? a : b),
                  avgVolume: stockData.map((e) => e.volume).reduce((a, b) => a + b) / stockData.length,
                  closingPrice: stockData.last.close,
                ),
              ],
            ),
    );
  }
}

class InteractiveGraph extends StatelessWidget {
  final List<StockData> data;

  const InteractiveGraph({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    List<FlSpot> chartData = [];
    
    for (int i = 0; i < data.length; i++) {
      chartData.add(FlSpot(i.toDouble(), data[i].close)); // Using close for graph
    }

    double minY = chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double maxY = chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SizedBox(
        width: double.infinity,
        height: 250,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    return Text(
                      value.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < data.length) {
                      return Text(
                        data[index].date.split(' ')[0],
                        style: const TextStyle(fontSize: 10, color: Colors.black),
                      );
                    }
                    return const SizedBox();
                  },
                  interval: 1,
                  reservedSize: 30,
                ),
              ),
            ),
            borderData: FlBorderData(show: true, border: Border.all(color: Colors.black)),
            minX: 0,
            maxX: chartData.length.toDouble(),
            minY: minY,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: chartData,
                isCurved: true,
                color: Colors.green,
                belowBarData: BarAreaData(
                  show: true,
                  color: Colors.green.withOpacity(0.2),
                ),
                dotData: FlDotData(show: false),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${data[spot.x.toInt()].date}\n${spot.y.toStringAsFixed(0)}',
                      const TextStyle(color: Colors.black),
                    );
                  }).toList();
                },
              ),
              touchCallback: (FlTouchEvent event, LineTouchResponse? response) {},
              handleBuiltInTouches: true,
            ),
          ),
        ),
      ),
    );
  }
}

class StockIndicators extends StatelessWidget {
  final double allTimeHigh;
  final double allTimeLow;
  final double avgVolume;
  final double closingPrice;

  const StockIndicators({
    super.key,
    required this.allTimeHigh,
    required this.allTimeLow,
    required this.avgVolume,
    required this.closingPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        children: [
          IndicatorCard(title: 'All-Time High', value: '₹${allTimeHigh.toStringAsFixed(2)}'),
          IndicatorCard(title: 'All-Time Low', value: '₹${allTimeLow.toStringAsFixed(2)}'),
          IndicatorCard(title: 'Average Volume', value: '${avgVolume.toStringAsFixed(0)}'),
          IndicatorCard(title: 'Closing Price', value: '₹${closingPrice.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}

class IndicatorCard extends StatelessWidget {
  final String title;
  final String value;

  const IndicatorCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 5,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}