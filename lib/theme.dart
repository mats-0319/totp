import 'package:flutter/material.dart';

Color _darkColor({double o = 1}) => Color.fromRGBO(210, 209, 186, o);

Color _lightColor({double o = 1}) => Color.fromRGBO(240, 239, 226, o);

ThemeData defaultThemeData() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _darkColor(),
      surface: _darkColor(),
      onSurface: _lightColor(),
      primary: Colors.black,
      secondary: Colors.grey,
      tertiary: Colors.white,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        color: Colors.black,
        fontSize: 28,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: Colors.black, fontSize: 32),
      bodyMedium: TextStyle(color: Colors.black, fontSize: 28),
      bodySmall: TextStyle(color: Colors.black, fontSize: 24),
      labelLarge: TextStyle(color: Colors.black, fontSize: 20),
      labelMedium: TextStyle(color: Colors.black, fontSize: 16),
      labelSmall: TextStyle(color: Colors.black, fontSize: 12),
      displayLarge: TextStyle(color: Colors.grey, fontSize: 20),
      displayMedium: TextStyle(color: Colors.grey, fontSize: 16),
      displaySmall: TextStyle(color: Colors.grey, fontSize: 12),
    ),
    appBarTheme: AppBarThemeData(backgroundColor: _lightColor()),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightColor(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(backgroundColor: _lightColor(o: 0.8)),
    ),
  );
}
