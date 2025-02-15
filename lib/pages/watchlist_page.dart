import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stocks/pages/theme_provider.dart';
import 'package:stocks/pages/trends_page.dart';

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Watchlist", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: watchlist.isEmpty
            ? Center(
                child: Text(
                  "No stocks in your watchlist",
                  style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
              )
            : ListView.builder(
                itemCount: watchlist.length,
                itemBuilder: (context, index) {
                  var stock = watchlist[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    color: theme.cardColor,
                    child: ListTile(
                      leading: CircleAvatar(
                          backgroundColor: Theme.of(context).extension<CustomColors>()!.lightCircleAvatarColor,
                        child: Text(
                          stock["name"][0],
                          style: TextStyle(color: theme.colorScheme.onPrimary),
                        ),
                      ),
                      title: Text(
                        stock["name"],
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Close: ₹${stock["close"]}\nHigh: ₹${stock["high"]}\nLow: ₹${stock["low"]}",
                        style: theme.textTheme.bodyMedium,
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
                        icon: Icon(Icons.delete, color: theme.colorScheme.error),
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

  const StockDetailPage({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Stock Details", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("📉 Close: ₹${stock["close"]}", style: theme.textTheme.bodyMedium),
            Text("📈 High: ₹${stock["high"]}", style: theme.textTheme.bodyMedium),
            Text("📉 Low: ₹${stock["low"]}", style: theme.textTheme.bodyMedium),
            Text("📊 Volume: ${stock["volume"]}", style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            Text("Closing Price Graph", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 0.5),
                      getDrawingVerticalLine: (value) => FlLine(color: theme.dividerColor, strokeWidth: 0.5)),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(0), style: theme.textTheme.bodySmall);
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
                            return Text(dates[index], style: theme.textTheme.bodySmall);
                          }
                          return const Text('');
                        },
                        reservedSize: 22,
                        interval: (spots.length / 5).ceilToDouble(),
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: theme.dividerColor)),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      dotData: const FlDotData(show: false),
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
