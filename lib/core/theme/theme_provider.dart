import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager {
  static const String _themeKey = 'is_dark_mode';
  static const String _langKey = 'app_language';

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(
    ThemeMode.light,
  );
  static final ValueNotifier<String> languageNotifier = ValueNotifier('en');

  static bool get isDarkMode => themeNotifier.value == ThemeMode.dark;
  static String get language => languageNotifier.value;

  // Called in main.dart before runApp()
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

    final savedLang = prefs.getString(_langKey) ?? 'en';
    languageNotifier.value = savedLang;
  }

  // Saves Dark Mode to SharedPreferences
  static Future<void> toggleTheme(bool isDark) async {
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  // Saves Language setting to SharedPreferences (for Phase 3)
  static Future<void> setLanguage(String langCode) async {
    languageNotifier.value = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, langCode);
  }
}
