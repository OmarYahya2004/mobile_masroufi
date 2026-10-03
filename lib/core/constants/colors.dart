import 'package:flutter/material.dart';

class AppColors {
  // Brand Logo Colors
  static const Color primaryBlue = Color(0xFF1D3557);
  static const Color primaryTeal = Color(0xFF0464A0);
  static const Color accentCyan = Color(0xFFA8DADC);

  // Shared Semantic Colors
  static const Color accentYellow = Color(0xFFF4D03F);
  static const Color errorRed = Color(0xFFE63946);
  static const Color successGreen = Color(0xFF2A9D8F);

  // Dark Mode Colors (Rich Navy-Slate instead of flat grey)
  static const Color darkBackground = Color(0xFF0D131A);
  static const Color darkSurface = Color(0xFF17212B);
  static const Color darkInputFill = Color(0xFF233040);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Colors.white;
  static const Color lightInputFill = Color(0xFFE8EEF3);
  static const Color lightText = Color(0xFF101820);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // --- Theme-Aware Helpers (Use these in your screens!) ---
  
  /// Use for AppBar Titles ('Masroufi', 'History', 'Analytics', 'Goals')
  static Color headerTitle(bool isDark) => isDark ? Colors.white : primaryTeal;

  /// Use for active icons, selected bottom nav tab, and highlighted amounts
  static Color primaryAccent(bool isDark) => isDark ? accentCyan : primaryTeal;

  /// Use for selected ChoiceChips and active chart bars
  static Color activeHighlight(bool isDark) => isDark ? accentCyan : primaryBlue;

  /// Text color on top of activeHighlight
  static Color onActiveHighlight(bool isDark) => isDark ? primaryBlue : Colors.white;
}