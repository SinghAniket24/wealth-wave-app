import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart'; // Make sure to create this file for ThemeProvider

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications') ?? true;
      _selectedLanguage = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _updatePreference(String key, dynamic value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  Widget _buildSection(String title, List<Widget> children) {
    final theme = Theme.of(context); // Access current theme

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      color: theme.cardTheme.color, // Use card color from theme
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.displayLarge?.color ?? Colors.black, // Fallback color
              ),
            ),
            Divider(color: theme.dividerColor), // Use divider color from theme
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context); // Access current theme here

    return Scaffold(
      appBar: AppBar(title: Text('Settings', style: Theme.of(context).appBarTheme.titleTextStyle)),
      body: ListView(
        children: [
          _buildSection("System Settings", [
            SwitchListTile(
              title: Text('Dark Mode', style: theme.textTheme.bodyLarge ?? TextStyle()), // Updated property
              subtitle: Text('Enable dark theme', style: theme.textTheme.bodyLarge ?? TextStyle()),
              value: themeProvider.isDarkMode,
              onChanged: (bool value) {
                themeProvider.toggleTheme();
                _updatePreference('darkMode', value);
              },
            ),
            SwitchListTile(
              title: Text('Enable Notifications', style: theme.textTheme.bodyLarge ?? TextStyle()),
              subtitle: Text('Receive push notifications', style: theme.textTheme.bodyLarge ?? TextStyle()),
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                  _updatePreference('notifications', value);
                });
              },
            ),
          ]),
          _buildSection("User Preferences", [
            ListTile(
              title: Text('Language', style: theme.textTheme.bodyLarge ?? TextStyle()),
              subtitle: Text(_selectedLanguage, style: theme.textTheme.bodyLarge ?? TextStyle()),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                items:
                    ['English', 'Spanish', 'French', 'Hindi'].map((lang) => DropdownMenuItem(
                          value: lang,
                          child:
                              Text(lang, style:
                                  theme.textTheme.bodyLarge ?? TextStyle()),
                        )).toList(),
                onChanged:
                    (String? newLang) {
                  if (newLang != null) {
                    setState(() {
                      _selectedLanguage = newLang;
                      _updatePreference('language', newLang);
                    });
                  }
                },
              ),
            ),
          ]),
          _buildSection("Account Settings", [
            ListTile(
              leading:
                  Icon(Icons.lock, color:
                      Theme.of(context).iconTheme.color),
              title:
                  Text('Change Password', style:
                      theme.textTheme.bodyLarge ?? TextStyle()),
              onTap:
                  () async {
                FirebaseAuth.instance.sendPasswordResetEmail(email:
                    FirebaseAuth.instance.currentUser!.email!);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
                    Text('Password reset email sent')));
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.delete, color:
                      Colors.red),
              title:
                  Text('Delete Account', style:
                      TextStyle(color:
                          Colors.red)),
              onTap:
                  () async {
                await FirebaseAuth.instance.currentUser!.delete();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:
                    Text('Account deleted')));
                Navigator.pop(context);
              },
            ),
          ]),
        ],
      ),
    );
  }
}
