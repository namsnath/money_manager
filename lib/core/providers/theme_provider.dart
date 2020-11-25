import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

class ThemeProvider extends ChangeNotifier {
  final log = Logger('ThemeProvider');

  bool _isDark = true;
  bool get isDark => _isDark;
  set isDark(bool val) {
    _isDark = val;
    notifyListeners();
  }

  toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
  );
  ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
  );
  get currentTheme => _isDark ? darkTheme : lightTheme;
}

final themeProvider = ChangeNotifierProvider((_) => ThemeProvider());
