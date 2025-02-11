import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stocks/pages/trends_page.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Watchlist", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: watchlist.isEmpty
            ? Center(
                child: Text(
                  "No stocks in your watchlist",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: watchlist.length,
                itemBuilder: (context, index) {
                  var stock = watchlist[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          stock["name"][0],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        stock["name"],
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        "Close: ₹${stock["close"]}\nHigh: ₹${stock["high"]}\nLow: ₹${stock["low"]}",
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StockDetailPage(stock: stock),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          watchlist.removeAt(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${stock['name']} removed from watchlist"),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
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
      dates.add(entry["Date"].split(" ")[0]);
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