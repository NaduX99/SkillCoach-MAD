import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Colors for Migrated Screens ──────────────────────────────────────────
  static const Color bg = Color(0xFF071330);
  static const Color surface = Color(0xFF0D1F4A);
  static const Color card = Color(0xFF112260);
  static const Color accent = Color(0xFF3D8EFF);
  static const Color accentLight = Color(0xFF7EB8FF);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8EB4E3);
  static const Color border = Color(0xFF1E3A6B);

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF071330), Color(0xFF0A2456)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF3D8EFF), Color(0xFF1A5FB4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A3370), Color(0xFF0D1F4A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1), // Modern Indigo seed
        primary: const Color(0xFF6366F1),
        secondary: const Color(0xFF10B981), // Emerald accent
        tertiary: const Color(0xFFF59E0B), // Amber accent
      ),
      textTheme: GoogleFonts.poppinsTextTheme(),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Color(0xFF1E293B)),
      ),
    );
  }

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F3A9D), // Deep vibrant blue top
      Color(0xFF0F70C7), // Mid bright blue
      Color(0xFF70CFE4), // Light cyan bottom
    ],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0052D4),
      Color(0xFF4364F7),
      Color(0xFF6FB1FC),
    ],
  );
}

