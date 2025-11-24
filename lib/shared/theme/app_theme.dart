import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFFB30000),
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    fontFamily: 'Montserrat',
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.bold),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
    ),
  );
}
