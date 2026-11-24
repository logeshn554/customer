import 'package:flutter/material.dart';
import 'package:allgo_mobile_shared/allgo_mobile_shared.dart';

class AllGoCustomerTheme {
  AllGoCustomerTheme._();

  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceElevated = Color(0xFF283548);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  static ThemeData get lightTheme {
    return AllGoTheme.lightTheme.copyWith(
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: AllGoTheme.lightTheme.textTheme.apply(
        fontFamily: 'Inter',
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AllGoColors.primary,
        secondary: AllGoColors.secondary,
        surface: darkSurface,
        error: AllGoColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkTextPrimary,
        onError: Colors.white,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkTextPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AllGoColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AllGoColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AllGoColors.error),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary),
        hintStyle: const TextStyle(color: darkTextTertiary),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: darkDivider, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: darkDivider,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: AllGoColors.primary,
        unselectedItemColor: darkTextTertiary,
      ),
    );
  }
}
