import 'package:flutter/material.dart';

extension Responsive on BuildContext {
  // Get Screen Size
  Size get screenSize => MediaQuery.of(this).size;

  // Get Screen Height
  double get screenHeight => screenSize.height;

  // Get Screen Width
  double get screenWidth => screenSize.width;

  // Method for Checking Mobile Screen Size
  bool get isMobile => screenWidth < 600; // Define your mobile breakpoint

  // Responsive Width
  double responsiveWidth(double percentage) => screenWidth * percentage;

  // Responsive Height
  double responsiveHeight(double percentage) => screenHeight * percentage;

  // Responsive Font Size
  double responsiveFontSize(double baseFontSize) {
    // Adjust the font size based on the screen size
    if (isMobile) {
      return baseFontSize * (screenWidth / 375); // Example adjustment for mobile
    } else {
      return baseFontSize * 1.2; // Example adjustment for larger screens
    }
  }
}
