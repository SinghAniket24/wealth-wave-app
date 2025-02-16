import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StockChatScreen(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.grey,
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black87),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        iconTheme: IconThemeData(color: Colors.blue),
      ),
    );
  }
}

class StockChatScreen extends StatefulWidget {
  @override
  _StockChatScreenState createState() => _StockChatScreenState();
}

class _StockChatScreenState extends State<StockChatScreen> {
  TextEditingController _controller = TextEditingController();
  List<Map> messages = [];
  ScrollController _scrollController = ScrollController();

  // Finnhub API Key and base URL
  final String _finnhubApiKey =
      'cunokg1r01qokt72mf00cunokg1r01qokt72mf0g'; // Replace with your Finnhub API Key
  final String _baseUrl = 'https://finnhub.io/api/v1/quote';

  // Store last known data for each stock symbol
  Map<String, Map<String, dynamic>> lastKnownData = {};

  // Gemini setup
  final String _geminiApiKey = 'AIzaSyBCGYtkK5uj8iUj2mSExcfIV22SylQLPn8'; // Replace with your Gemini API Key
  late final GenerativeModel _model;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-pro', apiKey: _geminiApiKey);
  }

  // Function to fetch stock data from Finnhub API
  Future<Map<String, dynamic>> fetchStockData(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?symbol=$symbol&token=$_finnhubApiKey'),
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body); // Decode to dynamic
        if (decodedData != null && decodedData is Map) {
          // Check if it's a map
          final Map<String, dynamic> data =
              decodedData.cast<String, dynamic>(); // Explicitly cast

          if (data.isNotEmpty) {
            lastKnownData[symbol] = data; // Store the data
            return data;
          } else {
            print("API returned empty data for $symbol");
            return lastKnownData[symbol] ??
                {}; // Use last known data or empty map
          }
        } else {
          print("API returned invalid JSON for $symbol");
          return lastKnownData[symbol] ?? {};
        }
      } else {
        print(
            "API request failed for $symbol with status code: ${response.statusCode}");
        return lastKnownData[symbol] ?? {}; // Use last known data or empty map
      }
    } catch (e) {
      print("Error fetching data for $symbol: $e");
      return lastKnownData[symbol] ?? {}; // Use last known data or empty map
    }
  }

  String formatStockData(Map<String, dynamic> data, String symbol) {
    if (data.isEmpty ||
        (data['c'] == null &&
            data['h'] == null &&
            data['l'] == null &&
            data['o'] == null &&
            data['pc'] == null)) {
      // Check if all data points are null or data is completely empty
      if (lastKnownData.containsKey(symbol)) {
        // Use last known data if available
        Map<String, dynamic> lastData = lastKnownData[symbol]!;
        double currentPrice = lastData['c'] ?? 0.0;
        double highPrice = lastData['h'] ?? 0.0;
        double lowPrice = lastData['l'] ?? 0.0;
        double openPrice = lastData['o'] ?? 0.0;
        double previousClosePrice = lastData['pc'] ?? 0.0;
        double change = currentPrice - previousClosePrice;
        double changePercent = (change / previousClosePrice) * 100;

        final numberFormat = NumberFormat("#,##0.00", "en_US");

        return '''
        *[$symbol Stock Data (Last Known)](pplx://action/followup):*
        Note: Current market data unavailable. Showing last known data.
        Last Updated: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}
        Current Price: \$${numberFormat.format(currentPrice)}
        High: \$${numberFormat.format(highPrice)}
        Low: \$${numberFormat.format(lowPrice)}
        Open: \$${numberFormat.format(openPrice)}
        Previous Close: \$${numberFormat.format(previousClosePrice)}
        Change: \$${numberFormat.format(change)} (${changePercent > 0 ? '+' : ''}${numberFormat.format(changePercent)}%)
        ''';
      } else {
        // If no last known data is available
        return '''
        *[$symbol Stock Data](pplx://action/followup):*
        Note: Current market data unavailable, and no previous data found.
        The market may be closed, or the symbol may be invalid. Please check again later.
        ''';
      }
    }

    double currentPrice = data['c'];
    double highPrice = data['h'];
    double lowPrice = data['l'];
    double openPrice = data['o'];
    double previousClosePrice = data['pc'];
    double change = currentPrice - previousClosePrice;
    double changePercent = (change / previousClosePrice) * 100;

    // Format numbers to two decimal places
    final numberFormat = NumberFormat("#,##0.00", "en_US");

    return '''
    *[$symbol Stock Data](pplx://action/followup):*
    Current Price: \$${numberFormat.format(currentPrice)}
    High: \$${numberFormat.format(highPrice)}
    Low: \$${numberFormat.format(lowPrice)}
    Open: \$${numberFormat.format(openPrice)}
    Previous Close: \$${numberFormat.format(previousClosePrice)}
    Change: \$${numberFormat.format(change)} (${changePercent > 0 ? '+' : ''}${numberFormat.format(changePercent)}%)
    ''';
  }

  // Function to handle user input
  void handleUserInput(String userMessage) async {
    setState(() {
      messages.add({"data": 0, "message": userMessage});
      messages.add({"data": 2, "message": "Loading..."}); // Add loading indicator
    });

    _scrollToBottom(); // Scroll to the loading indicator

    String botResponse = await getResponse(userMessage);

    //Remove loading indicator
    setState(() {
      messages.removeWhere((message) => message["message"] == "Loading...");
      messages.add({"data": 1, "message": botResponse});
    });

    _controller.clear();
    _scrollToBottom();
  }

  Future<String> getResponse(String userMessage) async {
    String geminiResponse = '';
    try {
      geminiResponse = await getGeminiResponse(userMessage);
      return geminiResponse;
    } catch (e) {
      if (e.toString().contains("429") ||
          e.toString().contains("Exhausted resources")) {
        // If Gemini is busy, extract stock symbol and use Finnhub API
        String? stockSymbol = extractStockSymbol(userMessage);
        if (stockSymbol != null) {
          Map<String, dynamic> stockData =
              await fetchStockData(stockSymbol.toUpperCase());
          return formatStockData(stockData, stockSymbol.toUpperCase());
        } else {
          return "Gemini is currently unavailable.  Please try again later, or provide a stock symbol for direct data.";
        }
      } else {
        return "Error communicating with Gemini: $e";
      }
    }
  }

  // Function to get response from Gemini
  Future<String> getGeminiResponse(String prompt) async {
    try {
      // Add your prompt modification here:
      prompt = "You are a highly skilled stock analyst with expertise in financial modeling and risk assessment. When answering questions, prioritize accuracy and conciseness. For stock-specific data requests, provide a concise overview including: current price, recent changes, a brief outlook (if available), and the source of the data (e.g., Finnhub API). If real-time data is unavailable, clearly state that you are providing the last available data from the Finnhub API. Avoid excessive theoretical explanations and never mention dates. \n\nIf the user asks about mathematical or risk-related aspects (e.g., volatility, correlation, prediction), provide a simplified explanation suitable for a general audience. If calculations are involved, briefly describe the method used. \n\nIf the user asks a question unrelated to the stock market, respond with: 'I am a stock analyst and can only answer questions about stocks.' You are welcome to respond to general greetings and suggestions. If the user asks for 'Nifty company data' or similar, interpret it as a request for information about companies listed on the Nifty 50 index. " +
          prompt;
      final content = [Content.text(prompt)]; // Use Content.text instead
      final response = await _model.generateContent(content);
      return response?.text ??
          "I'm sorry, I couldn't understand that. Please try again.";
    } catch (e) {
      throw e; //Re-throw the exception to be caught by the calling function
    }
  }

  // Function to extract stock symbol from user message
  String? extractStockSymbol(String message) {
    // Use a regular expression to find potential stock symbols (e.g., AAPL, MSFT)
    final regex = RegExp(r'\b([A-Z]{1,5})\b');
    final match = regex.firstMatch(message);
    if (match != null) {
      return match.group(1);
    }
    return null;
  }

  // Function to scroll to the bottom of the chat
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Stock Chatbot"),
      //   backgroundColor: Colors.blue[700],
      //   titleTextStyle: TextStyle(
      //       color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
      //   centerTitle: true,
      // ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Add the controller here
              itemCount: messages.length,
              itemBuilder: (context, index) {
                if (messages[index]["data"] == 2) {
                  // Show loading indicator
                  return LoadingChatBubble();
                } else {
                  return ChatBubble(
                    message: messages[index]["message"],
                    isUserMessage: messages[index]["data"] == 0,
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask about stock prices...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 196, 237, 244),
                      hintStyle: TextStyle(color: const Color.fromARGB(255, 84, 83, 83)),
                    ),
                    
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      handleUserInput(_controller.text);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUserMessage;

  ChatBubble({required this.message, required this.isUserMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          style: TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }
}

//Loading Chat Bubble
class LoadingChatBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
    );
  }
}
