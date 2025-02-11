import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewsPageState createState() => _NewsPageState();
}
 class _NewsPageState extends State<NewsPage> {
  final String apiKey = 'cudkg6pr01qigebr4vu0cudkg6pr01qigebr4vug'; //api key finnhub
  List<dynamic> newsList = [];

  // Function to fetch NSE stock news from Finnhub
  Future<void> fetchNews() async {
    final String url =
        'https://finnhub.io/api/v1/news?category=nse&token=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Assign the data directly without filtering out articles without images
        setState(() {
          newsList = data;
        });
      } else {
        setState(() {
          newsList = []; // Clear list if an error occurs
        });
      }
    } catch (e) {
      setState(() {
        newsList = []; // Clear list in case of an exception
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNews(); // Fetch NSE news when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NSE News'),
        backgroundColor: Colors.blueAccent,
      ),
      body: newsList.isEmpty
          ? const Center(child: CircularProgressIndicator()) // Loading indicator
          : ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                var article = newsList[index];

                return Card(
                  elevation: 8,
                  margin:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: article['image'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              article['image'],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'error.webp', // Placeholder image in case of error
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          )
                        : null, // Do not show leading if no image
                    title: Text(
                      article['headline'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      article['source'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {
                      // Open the full article in browser
                      _launchUrl(article['url']);
                    },
                  ),
                );
              },
            ),
    );
  }

  // Function to launch URL in the browser
  void _launchUrl(String url) async {
    // ignore: deprecated_member_use
    if (await canLaunch(url)) {
      // ignore: deprecated_member_use
      await launch(url);
    } else {
      throw 'Could not open the URL: $url';
    }
  }
}