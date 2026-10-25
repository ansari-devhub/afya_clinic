import 'package:flutter/material.dart';

/// Controller for toggling app brightness between Light and Dark mode instantly.
class ClinicalThemeController extends ChangeNotifier {
  static final ClinicalThemeController instance = ClinicalThemeController._();

  ClinicalThemeController._();

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    if ((_themeMode == ThemeMode.dark) != isDark) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }
}
