import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,

  // =====================
  // COULEURS GLOBALES (DOUCES)
  // =====================
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF326ED1),       // Bleu doux
    onPrimary: Colors.white,
    secondary: Color(0xFF22C1C3),     // Turquoise doux
    onSecondary: Color(0xFF1F2937),
    tertiary: Color(0xFFFBBF24),      // Jaune doux
    onTertiary: Color(0xFF1F2937),
    error: Color(0xFFEF4444),
    onError: Colors.white,
    background: Color(0xFFF0F8FF),    // Fond très doux
    onBackground: Color(0xFF1F2937),
    surface: Colors.white,
    onSurface: Color(0xFF1F2937),
  ),

  scaffoldBackgroundColor: const Color(0xFFF9FAFB),

  // =====================
  // APP BAR
  // =====================
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: Color(0xFF326ED1),
    foregroundColor: Colors.white,
  ),

  // =====================
  // TEXTE
  // =====================
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF1F2937)),
    bodyMedium: TextStyle(color: Color(0xFF1F2937)),
    titleLarge: TextStyle(
      fontWeight: FontWeight.bold,
      color: Color(0xFF1F2937),
    ),
  ),

  // =====================
  // BOUTONS
  // =====================
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF326ED1),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF326ED1),
    ),
  ),

  // =====================
  // CARTES
  // =====================
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 3,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
);
