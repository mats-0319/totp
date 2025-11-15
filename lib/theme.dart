import 'package:flutter/material.dart';

ThemeData defaultThemeData() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color.fromRGBO(210, 208, 186, 1),
      surface: Color.fromRGBO(210, 208, 186, 1),
      // background
      onSurface: Color.fromRGBO(240, 239, 226, 1),
      // items background
      primary: Colors.black,
      secondary: Colors.grey,
      error: Color.fromRGBO(214, 87, 81, 0.8),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
      // default display
      bodyMedium: TextStyle(color: Colors.black, fontSize: 24),
      // big black text
      displayLarge: TextStyle(color: Colors.black, fontSize: 32),
      displayMedium: TextStyle(color: Colors.black, fontSize: 28),
      displaySmall: TextStyle(color: Colors.black, fontSize: 24),
      // small black text
      headlineLarge: TextStyle(color: Colors.black, fontSize: 20),
      headlineMedium: TextStyle(color: Colors.black, fontSize: 16),
      headlineSmall: TextStyle(color: Colors.black, fontSize: 12),
      // small grey text
      labelLarge: TextStyle(color: Colors.grey, fontSize: 20),
      labelMedium: TextStyle(color: Colors.grey, fontSize: 16),
      labelSmall: TextStyle(color: Colors.grey, fontSize: 12),
    ),
  );
}
