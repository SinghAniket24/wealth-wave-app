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
      // appBar: AppBar(
      //   title: const Text("Watchlist", style: TextStyle(fontWeight: FontWeight.bold)),
      //   backgroundColor: theme.appBarTheme.backgroundColor,
      //   centerTitle: true,
      // ),
      body: Container( // Wrap the body in a Container
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue.shade100,
              Colors.lightBlue.shade50, 
            ],
          ),
        ),
        child: Padding(
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
      ),
    );
  }
}



class StockDetailPage extends StatelessWidget {
  final Map<String, dynamic> stock;

  const StockDetailPage({Key? key, required this.stock}) : super(key: key);

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
        title: Text(stock["name"],
            style: const TextStyle(color: Colors.white)), // AppBar text color
        backgroundColor:
            theme.appBarTheme.backgroundColor, // AppBar Background color
        iconTheme: const IconThemeData(color: Colors.white), // AppBar icon color
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue,
              Colors.lightBlue.shade50, // Lighter shade of blue
            ],
          ),
        ),
        child: SingleChildScrollView( // Added SingleChildScrollView for smaller screens
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                color: theme.cardColor, // Card Background
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Stock Details",
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.textTheme.titleLarge?.color),
                      ),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: constraints.maxWidth / 2 - 8,
                                child: Text("📉 Close: ₹${stock["close"]}",
                                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyLarge?.color)),
                              ),
                              SizedBox(
                                width: constraints.maxWidth / 2 - 8,
                                child: Text("📈 High: ₹${stock["high"]}",
                                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyLarge?.color)),
                              ),
                              SizedBox(
                                width: constraints.maxWidth / 2 - 8,
                                child: Text("📉 Low: ₹${stock["low"]}",
                                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyLarge?.color)),
                              ),
                              SizedBox(
                                width: constraints.maxWidth / 2 - 8,
                                child: Text("📊 Volume: ${stock["volume"]}",
                                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyLarge?.color)),
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
                
            ],
          ),
        ),
      ),
    );
  }
}
