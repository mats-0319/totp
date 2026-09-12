import 'package:flutter/material.dart';

ThemeData defaultThemeData() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color.fromRGBO(210, 209, 186, 1),
      // z-index: 0
      surface: Color.fromRGBO(210, 209, 186, 1),
      // z-index: 1
      onSurface: Color.fromRGBO(240, 239, 226, 1),
      primary: Colors.black,
      secondary: Colors.grey,
      tertiary: Colors.white,
      error: Color.fromRGBO(214, 87, 81, 0.8),
    ),
    textTheme: TextTheme(
      titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(color: Colors.black, fontSize: 24),
    ),
  );
}

TextStyle blackText(int fontSizeOffset) {
  return TextStyle(color: Colors.black, fontSize: 24 + fontSizeOffset * 4);
}

TextStyle greyText(int fontSizeOffset) {
  return TextStyle(color: Colors.grey, fontSize: 24 + fontSizeOffset * 4);
}
