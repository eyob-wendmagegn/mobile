import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waste_management_app/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeData _themeData = AppTheme.lightTheme;
  ThemeData get themeData => _themeData;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('darkMode') ?? false;
    setDarkMode(isDarkMode, notify: false);
  }

  void setDarkMode(bool value, {bool notify = true}) async {
    _isDarkMode = value;
    _themeData = value ? AppTheme.darkTheme : AppTheme.lightTheme;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);

    if (notify) notifyListeners();
  }

  void toggleTheme() {
    setDarkMode(!_isDarkMode);
  }
}
