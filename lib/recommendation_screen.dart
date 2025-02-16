import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'stock_insights.dart';

class RecommendationScreen extends StatefulWidget {
  @override
  _RecommendationScreenState createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  int _currentStep = 0;
  List<dynamic> _stockData = [];
  List<dynamic> _filteredStocks = [];
  bool _showResults = false;
  final _scrollController = ScrollController();

  final TextEditingController _budgetController = TextEditingController();
  String _selectedRisk = "Medium";
  String _selectedInvestmentGoal = "Growth";
  String _selectedVolatility = "Medium";

  @override
  void initState() {
    super.initState();
    _loadStockData();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadStockData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/Suggestion_stock_data.json');
      List<dynamic> data = jsonDecode(jsonString);
      setState(() {
        _stockData = data;
      });
      print("✅ Stock data loaded successfully!");
    } catch (e) {
      print("❌ Error loading stock data: $e");
    }
  }

  void _filterStocks() {
    double budget = double.tryParse(_budgetController.text) ?? double.infinity;

    setState(() {
      _filteredStocks = _stockData.where((stock) {
        double lastClose = (stock["Last_Close"] as num?)?.toDouble() ?? 0;
        String riskFactor = stock["Risk_Factor"] ?? "";
        String stockVolatility = stock["Volatility"] ?? "";
        double peRatio = (stock["PE_Ratio"] as num?)?.toDouble() ?? 0;
        double marketCap = (stock["Market_Cap"] as num?)?.toDouble() ?? 0;

        bool matchesInvestmentGoal = false;
        if (_selectedInvestmentGoal == "Growth") {
          matchesInvestmentGoal = peRatio < 20 && marketCap > 500000;
        } else if (_selectedInvestmentGoal == "Stable") {
          matchesInvestmentGoal = marketCap > 700000 && peRatio > 10;
        } else if (_selectedInvestmentGoal == "High Return") {
          matchesInvestmentGoal = peRatio < 15 && stockVolatility == "High";
        }

        return lastClose <= budget &&
            riskFactor == _selectedRisk &&
            stockVolatility == _selectedVolatility &&
            matchesInvestmentGoal;
      }).toList();
      _showResults = true;

      if (_filteredStocks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No recommendations found based on your criteria.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _showStockDetails(BuildContext context, Map<String, dynamic> stock) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockInsightsPage(stock: stock),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[50]!,
              Colors.blue[100]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Personalized Stock Recommendations",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[800]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Select your preferences and get the best stock recommendations tailored for you.",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stepper(
                      currentStep: _currentStep,
                      type: StepperType.vertical,
                      physics: ClampingScrollPhysics(),
                      onStepContinue: () {
                        if (_currentStep == 2) {
                          setState(() {
                            _currentStep++;
                          });
                        } else if (_currentStep == 3) {
                          _filterStocks();
                        } else {
                          setState(() {
                            _currentStep++;
                          });
                        }
                      },
                      onStepCancel: () {
                        if (_currentStep > 0) {
                          setState(() {
                            _currentStep--;
                          });
                        }
                      },
                      steps: [
                        Step(
                          title: Text("Investment Budget", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          content: TextField(
                            controller: _budgetController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Enter your budget (₹)",
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                          ),
                        ),
                        Step(
                          title: Text("Risk Capability", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          content: DropdownButtonFormField<String>(
                            value: _selectedRisk,
                            decoration: InputDecoration(border: OutlineInputBorder()),
                            items: ["Low", "Medium", "High"].map((String risk) {
                              return DropdownMenuItem(value: risk, child: Text(risk));
                            }).toList(),
                            onChanged: (newRisk) {
                              setState(() {
                                _selectedRisk = newRisk!;
                              });
                            },
                          ),
                        ),
                        Step(
                          title: Text("Investment Goal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          content: DropdownButtonFormField<String>(
                            value: _selectedInvestmentGoal,
                            decoration: InputDecoration(border: OutlineInputBorder()),
                            items: ["Growth", "Stable", "High Return"].map((String goal) {
                              return DropdownMenuItem(value: goal, child: Text(goal));
                            }).toList(),
                            onChanged: (newGoal) {
                              setState(() {
                                _selectedInvestmentGoal = newGoal!;
                              });
                            },
                          ),
                        ),
                        Step(
                          title: Text("Get Recommendations", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          content: ElevatedButton(
                            onPressed: () {
                              _filterStocks();
                            },
                            child: Text("Get Stock Recommendations"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (_showResults)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    controller: _scrollController,
                    itemCount: _filteredStocks.length,
                    itemBuilder: (context, index) {
                      var stock = _filteredStocks[index];
                      return Card(
                        elevation: 6,
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: Icon(Icons.trending_up, color: Colors.green, size: 30),
                          title: Text(stock["Stock"] ?? "Unknown Stock", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          subtitle: Text("Last Close: ₹${(stock["Last_Close"] as num?)?.toStringAsFixed(2) ?? 'N/A'}"),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                          onTap: () => _showStockDetails(context, stock),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
