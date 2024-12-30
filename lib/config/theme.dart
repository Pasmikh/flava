import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlavaTheme {
  // Primary colors
  static const Color primaryColor = Color(0xFF2C3E50);
  static const Color secondaryColor = Color(0xFFECF0F1);
  static const Color accentColor = Color(0xFF3498DB);
  
  // Text colors
  static const Color textColor = Color(0xFF2C3E50);
  static const Color textColorLight = Color(0xFFECF0F1);
  
  // Game-specific colors
  static const Color greenObjectColor = Color(0xFF27AE60);
  static const Color redObjectColor = Color(0xFFE74C3C);
  static const Color timerBackgroundColor = Color(0x4D2C3E50);
  
  // Text styles
  static final TextStyle headerStyle = GoogleFonts.roboto(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static final TextStyle subheaderStyle = GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: textColor,
  );

  static final TextStyle textStyle = GoogleFonts.roboto(
    fontSize: 16,
    color: textColor,
  );

  static final TextStyle buttonTextStyle = GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textColorLight,
  );

  // Timer text styles
  static final TextStyle timerStyle = GoogleFonts.robotoMono(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: primaryColor,
  );

  static final TextStyle playerNameStyle = GoogleFonts.roboto(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: textColorLight,
  );

  // Theme data
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: secondaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
        background: secondaryColor,
        onPrimary: textColorLight,
        onSecondary: textColorLight,
        onSurface: textColor,
        onBackground: textColor,
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: textColorLight,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(8),
      ),
    );
  }
}