import 'package:flutter/material.dart';

class ThemeModeNumber {
  ThemeModeNumber._();

  static ThemeMode numberToThemeMode(int value) {
    switch (value) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
