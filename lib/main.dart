import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:stocks/splash_screen.dart';
import 'firebase_options.dart';
import 'pages/about_page.dart';
import 'pages/watchlist_page.dart';
import 'pages/trends_page.dart';
import 'pages/sign_up.dart';
import 'pages/location.dart';
import 'pages/setting.dart';
import 'pages/news_page.dart';
import 'pages/home_page.dart';
import 'pages/theme_provider.dart';
import 'pages/Chatbot.dart';
import 'pages/analysis.dart' ;
import 'recommendation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stock App',
      theme: themeProvider.lightTheme, // Use the lightTheme from ThemeProvider
      darkTheme: themeProvider.darkTheme, // Use the darkTheme from ThemeProvider
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light, // Use ThemeMode
      home: const SplashScreen(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData) {
          User? user = snapshot.data;
          if (user != null && !user.emailVerified) {
            return const VerifyEmailScreen();
          }
          return const MyHomePage();
        } else {
          return SignUpScreen();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  String userName = "User";
  String userEmail = "";
  String userPhotoUrl = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (mounted) {
      setState(() {
        userName = currentUser?.displayName ?? "User";
        userEmail = currentUser?.email ?? "";
        userPhotoUrl = currentUser?.photoURL ?? "";
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const WatchlistPage(),
    const TrendsPage(),
     StockChatScreen(),
    const NewsPage(),
     RecommendationScreen(),
   
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access current theme
    return Scaffold(
      appBar: AppBar(
          title: const Text('WealthWave', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueAccent,
          centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: theme.appBarTheme.iconTheme?.color, // Use theme's icon color
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      drawer: Drawer(
 
        child: SingleChildScrollView(
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.primaryColor, // Use theme's primary color
                      theme.primaryColor.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: userPhotoUrl.isNotEmpty ? NetworkImage(userPhotoUrl) : null,
                      child: userPhotoUrl.isEmpty
                          ? const Icon(Icons.account_circle, size: 50, color: Colors.blue)
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      userName.isNotEmpty ? userName : "Loading...",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      userEmail.isNotEmpty ? userEmail : "No Email",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.person, 'Profile', context),
              _buildDrawerItem(Icons.location_on, 'Location', context, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LocationPage()),
                );
              }),
              _buildDrawerItem(Icons.settings, 'Settings', context, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              }),
              ListTile(
                leading: Icon(Icons.logout, color: theme.iconTheme.color),
                title: Text('Log Out', style: theme.textTheme.bodyLarge),
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MyApp()),
                      (route) => false,
                    );
                  }
                },
              ),
              const Divider(),
              _buildDrawerItem(Icons.file_copy, 'Analysis', context, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  AnalysisScreen()),
                );
              }),
              _buildDrawerItem(Icons.info, 'About', context, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              }),
              
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
          BottomNavigationBarItem(label: 'Watchlist', icon: Icon(Icons.list)),
          BottomNavigationBarItem(label: 'Search', icon: Icon(Icons.trending_up)),
          BottomNavigationBarItem(label: 'Chatbot', icon:Icon(Icons.smart_toy)),
          BottomNavigationBarItem(label: 'News', icon: Icon(Icons.new_releases)),
          BottomNavigationBarItem(label: 'Suggestions' , icon:Icon(Icons.lightbulb_circle)),
        
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: theme.primaryColor, // Highlight color for selected icon
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context, [VoidCallback? onTap]) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(title, style: theme.textTheme.bodyLarge),
      onTap: onTap ?? () => Navigator.pop(context),
    );
  }
}

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({Key? key}) : super(key: key);

  @override
  VerifyEmailScreenState createState() => VerifyEmailScreenState();
}

class VerifyEmailScreenState extends State<VerifyEmailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Your Email")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "A verification email has been sent to your email address. Please verify before logging in.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser; // Get the updated user
                await user?.reload();
                if (user?.emailVerified ?? false) {
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MyHomePage()),
                    );
                  }
                }
              },
              child: const Text("I've Verified"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                User? user = FirebaseAuth.instance.currentUser;
                await user?.sendEmailVerification();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Verification email resent.")),
                  );
                }
              },
              child: const Text("Resend Email"),
            ),
          ],
        ),
      ),
    );
  }
}
