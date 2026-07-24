import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class StockInsightsPage extends StatelessWidget {
  final Map<String, dynamic> stock;

  StockInsightsPage({required this.stock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(stock["Stock"], style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blueAccent, Colors.lightBlue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock["Stock"],
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Market Cap: ₹${stock["Market_Cap"]}",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildStockInfoTile(Icons.trending_up, "Last Close", "₹${stock["Last_Close"]}"),
              _buildStockInfoTile(Icons.bar_chart, "10-Day Avg", "₹${stock["Avg_Close_10Days"]}"),
              _buildStockInfoTile(Icons.show_chart, "30-Day Avg", "₹${stock["Avg_Close_30Days"]}"),
              _buildStockInfoTile(Icons.analytics, "PE Ratio", "${stock["PE_Ratio"]}"),
              _buildStockInfoTile(Icons.thermostat, "Volatility", stock["Volatility"]),
              _buildStockInfoTile(Icons.warning, "Risk Factor", stock["Risk_Factor"]),
              SizedBox(height: 20),
              Center(
                child: BounceInUp(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: Colors.blueAccent,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockInfoTile(IconData icon, String title, String value) {
    return FadeInLeft(
      child: Card(
        elevation: 4,
        margin: EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(icon, color: Colors.blueAccent, size: 28),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(value, style: TextStyle(fontSize: 16, color: Colors.black87)),
        ),
      ),
    );
  }
}
