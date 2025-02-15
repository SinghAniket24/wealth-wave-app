import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // for loading assets
import 'package:fl_chart/fl_chart.dart';
import 'package:marquee/marquee.dart';
import 'package:stocks/pages/theme_provider.dart';
import 'dart:math' as Math; // Import for math functions






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


 StockData({
   required this.date,
   required this.open,
   required this.high,
   required this.low,
   required this.close,
   required this.volume,
 });


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

class PredictionData {
  final String date;
  final double predictedClosePrice;

  PredictionData({
    required this.date,
    required this.predictedClosePrice,
  });

  factory PredictionData.fromJson(Map<String, dynamic> json) {
    return PredictionData(
      date: json['Date'],
      predictedClosePrice: json['Predicted Close Price (INR)'],
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
 String selectedTimePeriod = '1 Year';


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


 List<StockData> filterData() {
   DateTime now = DateTime.now();
   int daysToSubtract = selectedTimePeriod == '1 Year' ? 365 : 30;
   DateTime startDate = now.subtract(Duration(days: daysToSubtract));
   return stockData.where((data) => DateTime.parse(data.date).isAfter(startDate)).toList();
 }


 double calculateChange(List<StockData> data) {
   if (data.isEmpty) return 0.0;
   double startPrice = data.first.close;
   double endPrice = data.last.close;
   return ((endPrice - startPrice) / startPrice) * 100;
 }


List<StockData> getTopCompaniesByVolume() {
  return [
    StockData(date: "Tata_Steel", open: 0, high: 0, low: 0, close: 0, volume: 45449182.280487806),
    StockData(date: "Indian_Oil", open: 0, high: 0, low: 0, close: 0, volume: 24865558.268292684),
    StockData(date: "HDFC_Bank", open: 0, high: 0, low: 0, close: 0, volume: 19843060.922764227),
    StockData(date: "SBI", open: 0, high: 0, low: 0, close: 0, volume: 17146780.3699187),
    StockData(date: "PowerGrid", open: 0, high: 0, low: 0, close: 0, volume: 17044937.166666668),
  ];
}


 @override
 Widget build(BuildContext context) {
   List<StockData> filteredData = filterData();
   double change = calculateChange(filteredData);
   List<StockData> topCompanies = getTopCompaniesByVolume(); // Get top companies


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




         //StockTicker
         StockTicker(stockData: stockData),
         const SizedBox(height: 20),
         Center(
  child: Align(
    alignment: Alignment.center,
    child: ConstrainedBox(
      constraints: const BoxConstraints(), //remove maxwidth from here
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NiftyDetailPage(stockData: stockData),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.deepPurple,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 3,
          side: const BorderSide(color: Colors.deepPurple, width: 2),
          minimumSize: Size.zero, 
          tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Allow the button to shrinkwrap
        ),
        child: const Text("Nifty 50"),
      ),
    ),
  ),
),

         const SizedBox(height: 10),
         Text(
           "${filteredData.last.date} - ${change.toStringAsFixed(2)}%",
           style: TextStyle(
             fontSize: 18,
             color: change >= 0 ? Colors.green : Colors.red,
           ),
         ),
         const SizedBox(height: 20),
         InteractiveGraph(data: filteredData),
         const SizedBox(height: 20),
         Center(child: DropdownButton<String>(
           value: selectedTimePeriod,
           onChanged: (newValue) {
             setState(() {
               selectedTimePeriod = newValue!;
             });
           },
           items: ['1 Year', '1 Month']
               .map((value) => DropdownMenuItem<String>(
             value: value,
             child: Text(value, style: const TextStyle(fontSize: 18)),
           ))
               .toList(),
         ),
         ),


         const SizedBox(height: 20),


         // Top Companies by Volume
        Padding(
           padding: const EdgeInsets.symmetric(vertical: 20),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               const Text(
                 "Top Companies by Volume",
                 style: TextStyle(
                   fontSize: 18,
                   fontWeight: FontWeight.bold,
                   color: Colors.deepPurple,
                 ),
               ),
               const SizedBox(height: 10),
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: topCompanies.map((company) {
                   return Expanded(
                     child: Card(
                       child: Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text(company.date, style: const TextStyle(fontWeight: FontWeight.bold)),
                             Text("Volume: ${company.volume.toStringAsFixed(0)}"),
                             // Add tap gesture to navigate to stock detail page
                            //  IconButton(
                            //    icon: Icon(Icons.info),
                            //    onPressed: () {
                            //      Navigator.push(
                            //        context,
                            //        MaterialPageRoute(
                            //          builder: (context) => StockDetailPage(stock: company),
                            //        ),
                            //      );
                            //    },
                            //  ),
                           ],
                         ),
                       ),
                     ),
                   );
                 }).toList(),
               ),
             ],
           ),
         ),





         //Top Profit Making Companies
         TopProfitCompaniesChart(),
         const SizedBox(height: 20),// Add space between charts


         //Top Losing Companies
         TopLosingCompaniesChart(),


         //Summary Status
         SummaryStats(stockData: filteredData),


         const SizedBox(height: 20),
       ],
     ),
   );
 }
}

class NiftyDetailPage extends StatefulWidget {
  final List<StockData> stockData;

  const NiftyDetailPage({Key? key, required this.stockData}) : super(key: key);

  @override
  _NiftyDetailPageState createState() => _NiftyDetailPageState();
}

class _NiftyDetailPageState extends State<NiftyDetailPage> {
  List<PredictionData> predictedData = [];
  bool loadingError = false;

  @override
  void initState() {
    super.initState();
    loadPredictionData();
  }

  Future<void> loadPredictionData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/predicted_stock_prices.json');
      Map<String, dynamic> jsonResponse = json.decode(jsonString);
      List<dynamic> predictionList = jsonResponse['Nifty 50 Predictions'];

      setState(() {
        predictedData = predictionList.map((item) => PredictionData.fromJson(item)).toList();
        loadingError = false;
      });
    } catch (e) {
      print('Error loading prediction data: $e');
      setState(() {
        predictedData = [];
        loadingError = true;
      });
    }
  }

  List<StockData> filterData(String period) {
    DateTime now = DateTime.now();
    int daysToSubtract = period == '1 Year' ? 365 : period == '1 Month' ? 30 : 7;
    DateTime startDate = now.subtract(Duration(days: daysToSubtract));
    return widget.stockData.where((data) => DateTime.parse(data.date).isAfter(startDate)).toList();
  }

  double getAllTimeHigh(List<StockData> data) {
    if (data.isEmpty) return 0.0;
    return data.map((e) => e.high).reduce((a, b) => a > b ? a : b);
  }

  double getAllTimeLow(List<StockData> data) {
    if (data.isEmpty) return 0.0;
    return data.map((e) => e.low).reduce((a, b) => a < b ? a : b);
  }

  double getAvgVolume(List<StockData> data) {
    if (data.isEmpty) return 0.0;
    return data.map((e) => e.volume).reduce((a, b) => a + b) / data.length;
  }

  @override
  Widget build(BuildContext context) {
    List<StockData> filteredData = filterData("1 Year");
    double allTimeHigh = getAllTimeHigh(filteredData);
    double allTimeLow = getAllTimeLow(filteredData);
    double avgVolume = getAvgVolume(filteredData);
    double closingPrice = filteredData.isNotEmpty ? filteredData.last.close : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nifty 50 Detailed View"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stock Indicators Side-by-Side
          Row(
            children: [
              Expanded(
                child: StockIndicatorCard(
                  title: "All Time High",
                  value: allTimeHigh.toStringAsFixed(2),
                ),
              ),
              const SizedBox(width: 8), // Add some spacing between the cards
              Expanded(
                child: StockIndicatorCard(
                  title: "All Time Low",
                  value: allTimeLow.toStringAsFixed(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Add spacing between rows
          Row(
            children: [
              Expanded(
                child: StockIndicatorCard(
                  title: "Avg Volume",
                  value: avgVolume.toStringAsFixed(0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StockIndicatorCard(
                  title: "Closing Price",
                  value: closingPrice.toStringAsFixed(2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Interactive Graph
          InteractiveGraph(data: filteredData),

          const SizedBox(height: 40),
          const Text(
            'Predicted Stock Prices',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          ),
          if (loadingError)
            const Text('Failed to load predictions.')
          else if (predictedData.isNotEmpty)
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: predictedData.length,
                itemBuilder: (context, index) {
                  final prediction = predictedData[index];
                  return Container(
                    width: 220,
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // Align center vertically
                          crossAxisAlignment: CrossAxisAlignment.center, // Align center horizontally
                          children: [
                            Text(
                              'Date: ${prediction.date}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blueAccent,
                              ),
                              textAlign: TextAlign.center, // Center align text
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Predicted Close: ${prediction.predictedClosePrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center, // Center align text
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            const Text('No predictions available.'),
        ],
      ),
    );
  }
}

class StockIndicatorCard extends StatelessWidget {
  final String title;
  final String value;

  const StockIndicatorCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}




class StockDetailPage extends StatelessWidget {
 final StockData stock;


 const StockDetailPage({super.key, required this.stock});


 @override
 Widget build(BuildContext context) {
   // Placeholder name if company name is not available in the dataset
   String companyName = 'Company Name'; // Can be hardcoded or dynamic if possible.


   // Create a list of stock data for graph (using previous days)
   List<StockData> stockDataForGraph = [stock]; // You can extend this if you want to show a history of data


   return Scaffold(
     appBar: AppBar(
       title: const Text("Stock Detail"),
       backgroundColor: Colors.blueAccent,
     ),
     body: Padding(
       padding: const EdgeInsets.all(16.0),
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           // Company Name
           Text(
             companyName,
             style: const TextStyle(
               fontSize: 24,
               fontWeight: FontWeight.bold,
               color: Colors.blueAccent,
             ),
           ),
           const SizedBox(height: 20),


           // Stock Data Graph
           InteractiveGraph(data: stockDataForGraph),
           const SizedBox(height: 20),


           // Stock Information
           Text('Stock Date: ${stock.date}', style: const TextStyle(fontSize: 18)),
           Text('Open Price: \$${stock.open.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
           Text('High Price: \$${stock.high.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
           Text('Low Price: \$${stock.low.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
           Text('Closing Price: \$${stock.close.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18)),
           Text('Volume: ${stock.volume.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18)),
         ],
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
   return Column(
     children: [
       IndicatorCard(title: 'All-Time High', value: '\$${allTimeHigh.toStringAsFixed(2)}'),
       IndicatorCard(title: 'All-Time Low', value: '\$${allTimeLow.toStringAsFixed(2)}'),
       IndicatorCard(title: 'Volume', value: avgVolume.toStringAsFixed(0)),
       IndicatorCard(title: 'Closing Price', value: '\$${closingPrice.toStringAsFixed(2)}'),
     ],
   );
 }
}


class IndicatorCard extends StatelessWidget {
 final String title;
 final String value;


 const IndicatorCard({super.key, required this.title, required this.value});


 @override
 Widget build(BuildContext context) {
   return Card(
     margin: const EdgeInsets.symmetric(vertical: 10),
     child: Padding(
       padding: const EdgeInsets.all(16.0),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
           Text(value, style: const TextStyle(fontSize: 16)),
         ],
       ),
     ),
   );
 }
}


class InteractiveGraph extends StatelessWidget {
 final List<StockData> data;
 const InteractiveGraph({super.key, required this.data});


 @override
 Widget build(BuildContext context) {
   List<FlSpot> chartData = data.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.close)).toList();


   return SizedBox(
     width: double.infinity,
     height: 250,
     child: LineChart(LineChartData(
       gridData: FlGridData(show: true),
       titlesData: FlTitlesData(
         leftTitles: AxisTitles(
           sideTitles: SideTitles(
             showTitles: true,
             interval: 800, // Adjust this based on your data range
             reservedSize: 50, // Prevents text overlap
           ),
         ),
         topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
         rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
         bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
       ),
       lineBarsData: [
         LineChartBarData(spots: chartData, isCurved: true, color: Colors.green,
           dotData: FlDotData(show: false), // Hides dots
         )
       ],
       lineTouchData: LineTouchData(
         touchTooltipData: LineTouchTooltipData(
           getTooltipItems: (List<LineBarSpot> touchedSpots) {
             return touchedSpots.map((spot) {
               String date = data[spot.x.toInt()].date;
               double value = spot.y;
               return LineTooltipItem(
                 '$date\n${value.toStringAsFixed(2)}',
                 const TextStyle(color: Colors.white, fontSize: 12),
               );
             }).toList();
           },
         ),
       ),
     )),
   );
 }
}


//Profit Making
class TopProfitCompaniesChart extends StatelessWidget {
 final List<Map<String, dynamic>> topProfitCompanies = [
   {'name': 'Vedanta', 'profitPercentage': 81.51},
   {'name': 'Mahindra Mahindra', 'profitPercentage': 72.07},
   {'name': 'Divis Laboratories', 'profitPercentage': 62.38},
   {'name': 'Airtel', 'profitPercentage': 42.32},
   {'name': 'Wipro', 'profitPercentage': 35.35},
 ];


 @override
 Widget build(BuildContext context) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       const Text(
         "Top 5 Gaining Companies",
         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
       ),
       const SizedBox(height: 10),
       Container(
         height: 300,
         padding: const EdgeInsets.all(12),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(12),
           boxShadow: [
             BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
           ],
         ),
         child: BarChart(
           BarChartData(
             alignment: BarChartAlignment.spaceAround,
             maxY: topProfitCompanies.map((e) => e['profitPercentage']).reduce((a, b) => a > b ? a : b) + 5,
             barTouchData: BarTouchData(
               touchTooltipData: BarTouchTooltipData(
                 getTooltipItem: (group, groupIndex, rod, rodIndex) {
                   return BarTooltipItem(
                     "${topProfitCompanies[group.x]['name']}\n${rod.toY.toStringAsFixed(2)}%",
                     const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                   );
                 },
               ),
             ),
             titlesData: FlTitlesData(
               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
               leftTitles: AxisTitles(
                 axisNameWidget: const Text("Profit (%)"),
                 sideTitles: SideTitles(
                   showTitles: true,
                   reservedSize: 40,
                   getTitlesWidget: (value, meta) {
                     return Text("${value.toInt()}%", style: const TextStyle(fontSize: 12));
                   },
                 ),
               ),
               bottomTitles: AxisTitles(
                 axisNameWidget: const Text("Company"),
                 sideTitles: SideTitles(
                   showTitles: true,
                   getTitlesWidget: (value, meta) {
                     return Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Text(
                         topProfitCompanies[value.toInt()]['name'],
                         style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                       ),
                     );
                   },
                 ),
               ),
             ),
             gridData: FlGridData(show: true, drawHorizontalLine: true, checkToShowHorizontalLine: (value) => value % 10 == 0),
             barGroups: topProfitCompanies.asMap().entries.map((entry) {
               int index = entry.key;
               double profit = entry.value['profitPercentage'];


               return BarChartGroupData(
                 x: index,
                 barRods: [
                   BarChartRodData(
                     toY: profit,
                     color: Colors.greenAccent,
                     width: 30,
                     borderRadius: BorderRadius.circular(6),
                     gradient: const LinearGradient(
                       colors: [Colors.green, Colors.lightGreen],
                       begin: Alignment.bottomCenter,
                       end: Alignment.topCenter,
                     ),
                   ),
                 ],
               );
             }).toList(),
           ),
         ),
       ),
     ],
   );
 }
}




//Top Losing
class TopLosingCompaniesChart extends StatelessWidget {
 final List<Map<String, dynamic>> topLosingCompanies = [
   {'name': 'HUL', 'lossPercentage': -1.43},
   {'name': 'Coal India', 'lossPercentage': -1.71},
   {'name': 'Tata Steel', 'lossPercentage': -1.96},
   {'name': 'Tata Power', 'lossPercentage': -4.40},
   {'name': 'Larsen Toubro', 'lossPercentage': -6.00},
 ];


 @override
 Widget build(BuildContext context) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       const Text(
         "Top 5 Losing Companies",
         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
       ),
       const SizedBox(height: 10),
       Container(
         height: 300,
         padding: const EdgeInsets.all(12),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(12),
           boxShadow: [
             BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 4)),
           ],
         ),
         child: BarChart(
           BarChartData(
             alignment: BarChartAlignment.spaceAround,
             maxY: topLosingCompanies.map((e) => e['lossPercentage']).reduce((a, b) => a > b ? a : b) + 5,
             barTouchData: BarTouchData(
               touchTooltipData: BarTouchTooltipData(
                 getTooltipItem: (group, groupIndex, rod, rodIndex) {
                   return BarTooltipItem(
                     "${topLosingCompanies[group.x]['name']}\n${rod.toY.toStringAsFixed(2)}%",
                     const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                   );
                 },
               ),
             ),
             titlesData: FlTitlesData(
               topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
               rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
               leftTitles: AxisTitles(
                 axisNameWidget: const Text("Loss (%)"),
                 sideTitles: SideTitles(
                   showTitles: true,
                   reservedSize: 40,
                   getTitlesWidget: (value, meta) {
                     return Text("${value.toInt()}%", style: const TextStyle(fontSize: 12));
                   },
                 ),
               ),
               bottomTitles: AxisTitles(
                 axisNameWidget: const Text("Company"),
                 sideTitles: SideTitles(
                   showTitles: true,
                   getTitlesWidget: (value, meta) {
                     return Padding(
                       padding: const EdgeInsets.only(top: 8.0),
                       child: Text(
                         topLosingCompanies[value.toInt()]['name'],
                         style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                       ),
                     );
                   },
                 ),
               ),
             ),
             gridData: FlGridData(show: true, drawHorizontalLine: true, checkToShowHorizontalLine: (value) => value % 10 == 0),
             barGroups: topLosingCompanies.asMap().entries.map((entry) {
               int index = entry.key;
               double loss = entry.value['lossPercentage'];


               return BarChartGroupData(
                 x: index,
                 barRods: [
                   BarChartRodData(
                     toY: loss,
                     color: Colors.redAccent,
                     width: 30,
                     borderRadius: BorderRadius.circular(6),
                     gradient: const LinearGradient(
                       colors: [Colors.red, Colors.orangeAccent],
                       begin: Alignment.bottomCenter,
                       end: Alignment.topCenter,
                     ),
                   ),
                 ],
               );
             }).toList(),
           ),
         ),
       ),
     ],
   );
 }
}




//Summary Status of all the companies ( Analysis of the Full Dataset)
class SummaryStats extends StatelessWidget {
  final List<StockData> stockData;

  const SummaryStats({Key? key, required this.stockData}) : super(key: key);

  double getAllTimeHigh() {
    if (stockData.isEmpty) return 0.0;
    return stockData.map((e) => e.close).reduce((a, b) => a > b ? a : b);
  }

  double getAllTimeLow() {
    if (stockData.isEmpty) return 0.0;
    return stockData.map((e) => e.close).reduce((a, b) => a < b ? a : b);
  }

  double getAveragePrice() {
    if (stockData.isEmpty) return 0.0;
    return stockData.map((e) => e.close).reduce((a, b) => a + b) / stockData.length;
  }

  double getPriceChangePercentage() {
    if (stockData.length < 2) return 0.0;
    double firstPrice = stockData.first.close;
    double lastPrice = stockData.last.close;
    return ((lastPrice - firstPrice) / firstPrice) * 100;
  }

  // Calculate Volatility (Standard Deviation of Closing Prices)
  double getVolatility() {
    if (stockData.length < 2) return 0.0;

    double avgPrice = getAveragePrice();
    double sumOfSquaredDifferences = stockData.map((e) => (e.close - avgPrice) * (e.close - avgPrice)).reduce((a, b) => a + b);
    double variance = sumOfSquaredDifferences / stockData.length;
    return Math.sqrt(variance); // Need to import 'dart:math' for sqrt
  }

  // Calculate the Moving Average (e.g., 20-day moving average)
  double getMovingAverage(int period) {
    if (stockData.length < period) return 0.0;

    double sum = 0;
    for (int i = stockData.length - period; i < stockData.length; i++) {
      sum += stockData[i].close;
    }
    return sum / period;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple[500], // Light Deep Purple for background
          borderRadius: BorderRadius.circular(12), // Optional: Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Summary Stats",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatCard(
                    title: 'Highest Closing Price',
                    value: 'Rs ${getAllTimeHigh().toStringAsFixed(2)}',
                  ),
                  StatCard(
                    title: 'Lowest Closing Price',
                    value: 'Rs ${getAllTimeLow().toStringAsFixed(2)}',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatCard(
                    title: 'Average Closing Price',
                    value: 'Rs ${getAveragePrice().toStringAsFixed(2)}',
                  ),
                  StatCard(
                    title: 'Price Change ',
                    value: '${getPriceChangePercentage().toStringAsFixed(2)}%',
                    valueColor: getPriceChangePercentage() >= 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatCard(
                    title: 'Volatility',
                    value: getVolatility().toStringAsFixed(2),
                  ),
                  StatCard(
                    title: '20-Day Moving Avg',
                    value: 'Rs ${getMovingAverage(20).toStringAsFixed(2)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
 final String title;
 final String value;
 final Color valueColor;


 const StatCard({
   super.key,
   required this.title,
   required this.value,
   this.valueColor = Colors.black,
 });


 @override
 Widget build(BuildContext context) {
   return Column(
     children: [
       Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
       const SizedBox(height: 4),
       Text(
         value,
         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor),
       ),
     ],
   );
 }
}


//Marquee
class StockTicker extends StatelessWidget {
 final List<StockData> stockData;


 const StockTicker({super.key, required this.stockData});


 @override
 Widget build(BuildContext context) {
   return Container(
      height: 50,
      color: Colors.blueAccent,
      child: Marquee(
        text: stockData
            .take(5) // Display the last 5 closing prices
            .map((e) => '${e.date}: Rs ${e.close.toStringAsFixed(2)}')
            .join("   |   "), // Join with separator
        style: const TextStyle(fontSize: 16, color: Colors.white),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        blankSpace: 200.0,
        velocity: 50.0,
        startPadding: 10.0,
      ),
    );
 }
}


