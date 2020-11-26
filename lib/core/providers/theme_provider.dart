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

  static final Map<String, Color> solarisedCommon = {
    'yellow': Color(0xFFB58900),
    'orange': Color(0xFFCB4B16),
    'red': Color(0xFFDC322F),
    'magenta': Color(0xFFD33682),
    'violet': Color(0xFF6C71C4),
    'blue': Color(0xFF268BD2),
    'cyan': Color(0xFF2AA198),
    'green': Color(0xFF859900),
  };

  static final Map<String, Color> solarisedLight = {
    'base03': Color(0xFF002B36),
    'base02': Color(0xFF073642),
    'base01': Color(0xFF586E75), // Optional Emphasized Content
    'base00': Color(0xFF657B83), // Body Text / Default Code / Primary Content
    'base0': Color(0xFF839496),
    'base1': Color(0xFF93A1A1), // Comments/Secondary Content
    'base2': Color(0xFFEEE8D5), // Background Highlights
    'base3': Color(0xFFFDF6E3), // Background
  };

  static final Map<String, Color> solarisedDark = {
    'base03': Color(0xFFFDF6E3),
    'base02': Color(0xFFEEE8D5),
    'base01': Color(0xFF93A1A1), // Optional Emphasized Content
    'base00': Color(0xFF839496), // Body Text / Default Code / Primary Content
    'base0': Color(0xFF657B83),
    'base1': Color(0xFF586E75), // Comments/Secondary Content
    'base2': Color(0xFF073642), // Background Highlights
    'base3': Color(0xFF002B36), // Background
  };

  getThemeColor(String key) =>
      _isDark ? solarisedDark[key] : solarisedLight[key];

  getFlippedColor(String key) =>
      _isDark ? solarisedLight[key] : solarisedDark[key];

  get currentTheme => ThemeData(
        brightness: _isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: getThemeColor('base3'),
        cardColor: getThemeColor('base2'),
        canvasColor: getThemeColor('base2'),
        buttonTheme: ButtonThemeData(
          buttonColor: solarisedCommon['blue'],
          textTheme: ButtonTextTheme.primary,
        ),
        primaryTextTheme: TextTheme(
          headline6: TextStyle(
            // For AppBar title
            color: getThemeColor('base01'),
          ),
        ),
        primaryIconTheme: IconThemeData(
          // For AppBar actions
          color: getThemeColor('base01'),
        ),
        textTheme: TextTheme(
          headline1: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: getThemeColor('base01'),
          ),
          headline2: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: getThemeColor('base01'),
          ),
          headline3: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: getThemeColor('base01'),
          ),
          bodyText1: TextStyle(
            color: getThemeColor('base00'),
          ),
          bodyText2: TextStyle(
            color: getThemeColor('base00'),
          ),
          subtitle1: TextStyle(
            color: getThemeColor('base01'),
          ),
          caption: TextStyle(
            color: getThemeColor('base01'),
          ),
        ),
        iconTheme: IconThemeData(color: getThemeColor('base00')),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: solarisedCommon['blue'],
          foregroundColor: getFlippedColor('base3'),
        ),
        appBarTheme: AppBarTheme(
          brightness: _isDark ? Brightness.dark : Brightness.light,
          color: getThemeColor('base2'),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedIconTheme: IconThemeData(
            color: solarisedCommon['cyan'],
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(
            color: solarisedCommon['cyan'],
          ),
          errorStyle: TextStyle(
            color: solarisedCommon['red'],
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(
              color: solarisedCommon['cyan'],
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: solarisedCommon['cyan'],
              width: 2.0,
            ),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: solarisedCommon['red'],
            ),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: solarisedCommon['red'],
              width: 2.0,
            ),
          ),
        ),
      );
}

final themeProvider = ChangeNotifierProvider((_) => ThemeProvider());
