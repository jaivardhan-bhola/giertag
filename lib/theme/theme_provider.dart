import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:giertag/theme/dark.dart';
import 'package:giertag/theme/light.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeMode = lightmode;
  late SharedPreferences prefs;
  static const String THEME_KEY = 'isDark';

  void _updateStatusBar(bool isDark) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
  }

  ThemeProvider(ThemeData themeData) {
    _themeMode = themeData;
    _initPrefs();
    _updateStatusBar(_themeMode == darkmode);
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  ThemeData get themeData => _themeMode;

  bool get isDarkMode => themeData == darkmode;

  void toggleTheme() async {
    if (_themeMode == lightmode) {
      _themeMode = darkmode;
      _updateStatusBar(true);
      await prefs.setBool(THEME_KEY, true);
    } else {
      _themeMode = lightmode;
      _updateStatusBar(false);
      await prefs.setBool(THEME_KEY, false);
    }
    notifyListeners();
  }
}
