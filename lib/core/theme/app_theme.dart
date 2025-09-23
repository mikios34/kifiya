import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryButtonColor = Color(0xFF414A61);
  static const Color backgroundColorAuth = Color(0xFF414A61);
  static const Color primaryTextColor = Color(0xFF000000);
  static const Color secondaryTextColor = Color(0xFF6B7280);
  static const Color hintTextColor = Color(0xFF9CA3AF);
  static const Color iconColor = Color(0xFF6B7280);
  static const Color loginIconBgColor = Color(0xFFE0E7FF);
  static const Color loginIconColor = Color(0xFF414A61);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color inputBorderColor = Color(0xFFE5E7EB);
  static const Color focusedBorderColor = Color(0xFF414A61);

  // Text Styles
  static TextStyle get headingStyle => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: primaryTextColor,
  );

  static TextStyle get titleStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: primaryTextColor,
  );

  static TextStyle get bodyStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: primaryTextColor,
  );

  static TextStyle get hintStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: hintTextColor,
  );

  static TextStyle get buttonTextStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle get linkTextStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: secondaryTextColor,
  );

  static TextStyle get linkActiveTextStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: primaryButtonColor,
  );

  static TextStyle get welcomeStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.white,
  );

  static TextStyle get loginHereStyle => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get registerHereStyle => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: TextTheme(
        headlineLarge: headingStyle,
        titleLarge: titleStyle,
        bodyLarge: bodyStyle,
        bodyMedium: bodyStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryButtonColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: buttonTextStyle,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: inputBorderColor),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: inputBorderColor),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: focusedBorderColor, width: 2),
        ),
        hintStyle: hintStyle,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
