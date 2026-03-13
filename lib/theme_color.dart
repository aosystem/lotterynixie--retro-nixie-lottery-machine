import 'package:flutter/material.dart';

class ThemeColor {
  final int? themeNumber;
  final BuildContext context;

  ThemeColor({this.themeNumber, required this.context});

  Brightness get _effectiveBrightness {
    switch (themeNumber) {
      case 1:
        return Brightness.light;
      case 2:
        return Brightness.dark;
      default:
        return Theme.of(context).brightness;
    }
  }

  bool get _isLight => _effectiveBrightness == Brightness.light;

  //main page
  Color get mainBackColor => _isLight ? Color.fromRGBO(200,200,200, 1.0) : Color.fromRGBO(50, 50, 50, 1.0);
  Color get mainBack2Color => _isLight ? Color.fromRGBO(255, 255, 255, 1.0) : Color.fromRGBO(0, 0, 0, 1.0);
  Color get mainButtonColor => _isLight ? Color.fromRGBO(0, 0, 0, 0.5) : Color.fromRGBO(255,255,255,0.5);
  Color get mainStartBackColor => _isLight ? Color.fromRGBO(255,255,255,0.3) : Color.fromRGBO(255,255,255,0.3);
  Color get mainStartForeColor => _isLight ? Color.fromRGBO(0,0,0,0.6) : Color.fromRGBO(255,255,255,0.8);
  Color get mainCandidateForeColor => _isLight ? Colors.orange[800]! : Colors.orange;
  Color get mainHistoryForeColor => _isLight ? Color.fromRGBO(0,0,0,0.9) : Color.fromRGBO(255,255,255,0.9);
  //setting page
  Color get backColor => _isLight ? Colors.grey[200]! : Colors.grey[900]!;
  Color get cardColor => _isLight ? Colors.white : Colors.grey[800]!;
  Color get appBarForegroundColor => _isLight ? Colors.grey[700]! : Colors.white70;
  Color get dropdownColor => cardColor;

}
