import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final String apiKey = 'cujchr9r01qm7p9nrddgcujchr9r01qm7p9nrde0';
  List<dynamic> newsList = [];
  bool isLoading = true;

  Future<void> fetchNews() async {
    final String url = 'https://finnhub.io/api/v1/news?category=general&token=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          newsList = data;
          isLoading = false;
        });
      } else {
        setState(() {
          newsList = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        newsList = [];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive Text Sizes
    final headlineFontSize = screenWidth < 360 ? 16.0 : 18.0;
    final bodyFontSize = screenWidth < 360 ? 12.0 : 14.0;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Stock Market News', style: TextStyle(fontWeight: FontWeight.bold, fontSize: headlineFontSize)),
      //   centerTitle: true,
      //   backgroundColor: theme.appBarTheme.backgroundColor,
      // ),
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
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : newsList.isEmpty
                ? Center(
                    child: Text(
                      'No news available',
                      style: TextStyle(fontSize: headlineFontSize, color: theme.textTheme.bodyLarge?.color),
                    ),
                  )
                : ListView.builder(
                    itemCount: newsList.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (context, index) {
                      var article = newsList[index];
                      return Card(
                        color: theme.cardColor,
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: article['image'] != null && article['image'].isNotEmpty
                                    ? Image.network(
                                        article['image'],
                                        height: 100,
                                        width: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/error.webp',
                                            height: 100,
                                            width: 120,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        'assets/error.webp',
                                        height: 100,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      article['headline'] ?? 'No headline available',
                                      style: TextStyle(
                                        fontSize: headlineFontSize,
                                        fontWeight: FontWeight.w500,
                                        color: theme.textTheme.headlineSmall?.color,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      article['source'] ?? 'Unknown source',
                                      style: TextStyle(fontSize: bodyFontSize, color: theme.textTheme.bodySmall?.color),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: theme.elevatedButtonTheme.style?.backgroundColor?.resolve({}),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () => _launchUrl(article['url']),
                                        child: Text('Read More', style: TextStyle(fontSize: bodyFontSize)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  void _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the URL: $url')),
      );
    }
  }
}
