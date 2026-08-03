import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    primaryColor: const Color(0xFFFF6B35),

    scaffoldBackgroundColor: Colors.white,

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFF6B35),
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
  );
}
