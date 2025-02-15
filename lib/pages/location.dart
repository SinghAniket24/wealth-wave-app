import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  List<dynamic> countries = [];
  List<dynamic> filteredCountries = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchCountries();
    searchController.addListener(_filterCountries);
  }

  Future<void> fetchCountries() async {
    const String url = 'https://restcountries.com/v3.1/all';
    
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Sort countries alphabetically by name
        data.sort((a, b) => (a['name']['common'] ?? "").compareTo(b['name']['common'] ?? ""));

        setState(() {
          countries = data;
          filteredCountries = data; // Initialize filtered list with full data
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load countries');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching country data: $e');
    }
  }

  void _filterCountries() {
    String query = searchController.text.toLowerCase();

    setState(() {
      filteredCountries = countries.where((country) {
        final countryName = country['name']['common'].toLowerCase();
        return countryName.contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Country', style: TextStyle(fontWeight: FontWeight.bold)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 5,
      ),
      backgroundColor: Colors.grey[900],
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Column(
              children: [
                // Search Bar with Custom UI
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search for a country...',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      ),
                    ),
                  ),
                ),

                // Country List with Enhanced UI
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredCountries.length,
                    itemBuilder: (context, index) {
                      final country = filteredCountries[index];
                      final String countryName = country['name']['common'] ?? "Unknown";
                      final String countryRegion = country['region'] ?? "Unknown";
                      final String flagUrl = country['flags']['png'] ?? "";

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Card(
                          color: Colors.grey[850],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(15),
                            leading: flagUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(flagUrl, width: 50, height: 30, fit: BoxFit.cover),
                                  )
                                : const Icon(Icons.flag, size: 30, color: Colors.grey),
                            title: Text(
                              countryName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            subtitle: Text(
                              countryRegion,
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Selected: $countryName'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: Colors.blueAccent,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
