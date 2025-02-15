import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  Map<String, bool> isExpanded = {
    "Our Aim": false,
    "Our Vision": false,
    "Key Features": false,
    "Technology Stack": false,
    "Contact Us": false,
  };

  void toggleExpansion(String title) {
    setState(() {
      isExpanded[title] = !isExpanded[title]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("About WealthWave"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 20),
              _buildExpandableCard(
                title: "Our Aim",
                icon: Icons.rocket_launch,
                description:
                    "To provide a user-friendly platform for stock market enthusiasts and investors to track, analyze, and optimize their investments effectively.",
              ),
              _buildExpandableCard(
                title: "Our Vision",
                icon: Icons.visibility,
                description:
                    "To revolutionize stock market tracking with AI-powered insights, real-time data, and predictive analytics, making investments smarter and more accessible.",
              ),
              _buildExpandableCard(
                title: "Key Features",
                icon: Icons.featured_play_list,
                description: "📊 Real-time Stock Data\n"
                    "📈 Market Trends & Insights\n"
                    "🔔 Watchlist & Alerts\n"
                    "📰 Latest Stock News\n"
                    "🔐 Secure & User-Friendly",
              ),
              _buildExpandableCard(
                title: "Technology Stack",
                icon: Icons.code,
                description: "💻 Frontend: Flutter\n"
                    "Flask/Python"
                    "📦 Database: Firestore / MySQL",
              ),
              _buildExpandableCard(
                title: "Contact Us",
                icon: Icons.contact_mail,
                description: "📩 Email: support@wealthwave.com",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset("assets/logo.jpg", height: 100), // Replace with your logo
            const SizedBox(height: 10),
            const Text(
              "Welcome to WealthWave",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Your ultimate stock market companion for real-time trends, market insights, and portfolio management!",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableCard({
    required String title,
    required IconData icon,
    required String description,
  }) {
    return GestureDetector(
      onTap: () => toggleExpansion(title),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            ListTile(
              leading: Icon(icon, color: Colors.blueAccent, size: 32),
              title: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: Icon(
                isExpanded[title]! ? Icons.expand_less : Icons.expand_more,
                color: Colors.blueAccent,
              ),
            ),
            if (isExpanded[title]!)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }
}