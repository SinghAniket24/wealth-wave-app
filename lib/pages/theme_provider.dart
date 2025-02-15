import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get lightTheme => ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent, // Bright blue for contrast
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor: Colors.white, // White background for the scaffold
        cardColor: Colors.white, // Keep cards white for light mode
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87), // Darker black for better contrast
          displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold), // For headings
        ),
        iconTheme: const IconThemeData(color: Colors.blueGrey), // Darker icon color for contrast
        listTileTheme: ListTileThemeData(tileColor: Colors.grey[200]), // Light grey for ListView items
        extensions: <ThemeExtension<dynamic>>[
          CustomColors(
            lightCircleAvatarColor: Colors.blueAccent, 
            darkCircleAvatarColor: Colors.deepPurpleAccent,
            sizedBoxColor: Colors.grey[350]!,
          ),
        ],
      );

  ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B1B1B), // Darker shade for app bar
          titleTextStyle: TextStyle(color: Colors.yellowAccent, fontSize: 20, fontWeight: FontWeight.bold), // Bright yellow for contrast
          iconTheme: IconThemeData(color: Colors.yellowAccent), // Bright yellow icons
        ),
        scaffoldBackgroundColor: const Color(0xFF121212), // Darker background for the scaffold
        cardColor: const Color(0xFF1E1E1E), // Dark gray for cards to distinguish from background
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70), // Light gray for body text
          displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Bright white for headings
        ),
        iconTheme: const IconThemeData(color: Colors.white70), // Light gray icons for better visibility
        listTileTheme: ListTileThemeData(tileColor: Colors.grey[850]), // Dark grey for ListView items
        extensions: <ThemeExtension<dynamic>>[
          CustomColors(
            lightCircleAvatarColor: Colors.blueAccent, 
            darkCircleAvatarColor: Colors.deepPurpleAccent,
            sizedBoxColor: Colors.grey[850]!,
          ),
        ],
      );

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class CustomColors extends ThemeExtension<CustomColors> {
  final Color lightCircleAvatarColor;
  final Color darkCircleAvatarColor;
  final Color sizedBoxColor;

  CustomColors({
    required this.lightCircleAvatarColor,
    required this.darkCircleAvatarColor,
    required this.sizedBoxColor,
  });

  @override
  CustomColors copyWith({
    Color? lightCircleAvatarColor,
    Color? darkCircleAvatarColor,
    Color? sizedBoxColor,
  }) {
    return CustomColors(
      lightCircleAvatarColor: lightCircleAvatarColor ?? this.lightCircleAvatarColor,
      darkCircleAvatarColor: darkCircleAvatarColor ?? this.darkCircleAvatarColor,
      sizedBoxColor: sizedBoxColor ?? this.sizedBoxColor,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      lightCircleAvatarColor: Color.lerp(lightCircleAvatarColor, other.lightCircleAvatarColor, t)!,
      darkCircleAvatarColor: Color.lerp(darkCircleAvatarColor, other.darkCircleAvatarColor, t)!,
      sizedBoxColor: Color.lerp(sizedBoxColor, other.sizedBoxColor, t)!,
    );
  }
}
