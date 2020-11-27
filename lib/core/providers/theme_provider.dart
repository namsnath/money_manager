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

  get currentTheme => _isDark ? ThemeData.dark() : ThemeData.light();
}

final themeProvider = ChangeNotifierProvider((_) => ThemeProvider());
