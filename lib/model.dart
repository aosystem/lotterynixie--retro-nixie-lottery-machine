import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lotterynixie/const_value.dart';
import 'package:lotterynixie/l10n/app_localizations.dart';

class Model {
  Model._();

  static const String _prefCandidateText = 'candidateTexts';
  static const String _prefPrizeText = 'prizeTexts';
  static const String _prefHistoryText = 'historyTexts';
  static const String _prefHistoryDrawFlag = 'historyDrawFlag';
  static const String _prefMachineImageIndex = 'machineImageIndex';
  static const String _prefMachineSpeed = 'machineSpeed';
  static const String _prefMachineSoundVolume = 'machineSoundVolume';
  static const String _prefPrizeSoundVolume = 'prizeSoundVolume';
  static const String _prefTtsEnabled = 'ttsEnabled';
  static const String _prefTtsVoiceId = 'ttsVoiceId';
  static const String _prefTtsVolume = 'ttsVolume';
  static const String _prefThemeNumber = 'themeNumber';
  static const String _prefLanguageCode = 'languageCode';

  static bool _ready = false;
  static String _candidateText = ConstValue.candidateTextDefault;
  static String _prizeText = ConstValue.prizeTextDefault;
  static String _historyText = ConstValue.historyTextDefault;
  static bool _historyDrawFlag = true;
  static int _machineImageIndex = 0;
  static int _machineSpeed = 1;
  static double _machineSoundVolume = 1.0;
  static double _prizeSoundVolume = 1.0;
  static bool _ttsEnabled = true;
  static double _ttsVolume = 1.0;
  static String _ttsVoiceId = '';
  static int _themeNumber = 0;
  static String _languageCode = '';

  static String get candidateText => _candidateText;
  static String get prizeText => _prizeText;
  static String get historyText => _historyText;
  static bool get historyDrawFlag => _historyDrawFlag;
  static int get machineImageIndex => _machineImageIndex;
  static int get machineSpeed => _machineSpeed;
  static double get machineSoundVolume => _machineSoundVolume;
  static double get prizeSoundVolume => _prizeSoundVolume;
  static bool get ttsEnabled => _ttsEnabled;
  static double get ttsVolume => _ttsVolume;
  static String get ttsVoiceId => _ttsVoiceId;
  static int get themeNumber => _themeNumber;
  static String get languageCode => _languageCode;

  static Future<void> ensureReady() async {
    if (_ready) {
      return;
    }
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //
    _candidateText = prefs.getString(_prefCandidateText) ?? ConstValue.candidateTextDefault;
    _prizeText = prefs.getString(_prefPrizeText) ?? ConstValue.prizeTextDefault;
    _historyText = prefs.getString(_prefHistoryText) ?? ConstValue.historyTextDefault;
    _historyDrawFlag = prefs.getBool(_prefHistoryDrawFlag) ?? true;
    _machineImageIndex = (prefs.getInt(_prefMachineImageIndex) ?? 0).clamp(0,3);
    _machineSpeed = (prefs.getInt(_prefMachineSpeed) ?? 1).clamp(1,9);
    _machineSoundVolume = (prefs.getDouble(_prefMachineSoundVolume) ?? 1.0).clamp(0.0,1.0);
    _prizeSoundVolume = (prefs.getDouble(_prefPrizeSoundVolume) ?? 1.0).clamp(0.0,1.0);
    _ttsEnabled = prefs.getBool(_prefTtsEnabled) ?? true;
    _ttsVoiceId = prefs.getString(_prefTtsVoiceId) ?? '';
    _ttsVolume = (prefs.getDouble(_prefTtsVolume) ?? 1.0).clamp(0.0,1.0);
    _themeNumber = (prefs.getInt(_prefThemeNumber) ?? 0).clamp(0, 2);
    _languageCode = prefs.getString(_prefLanguageCode) ?? ui.PlatformDispatcher.instance.locale.languageCode;
    _languageCode = _resolveLanguageCode(_languageCode);
    _ready = true;
  }

  static String _resolveLanguageCode(String code) {
    final supported = AppLocalizations.supportedLocales;
    if (supported.any((l) => l.languageCode == code)) {
      return code;
    } else {
      return '';
    }
  }

  static List<int> getCandidateNumbers() {
    return _parseStrToNumbers(_candidateText);
  }

  static List<Map<String,dynamic>> getPrizeList() {
    List<Map<String,dynamic>> mapList = [];
    final List<String> lines = _prizeText.replaceAll('\r','').split('\n');
    for (int i = 0; i < lines.length; i++) {
      final List<String> ary = lines[i].split(':');
      final List<int> numbers = _parseStrToNumbers(ary[0]);
      final Map<String,dynamic> mapOne = {'numbers':numbers,'prize':ary[1]};
      mapList.add(mapOne);
    }
    return mapList;
  }

  static List<int> getHistoryNumbers() {
    return _parseStrToNumbers(_historyText);
  }

  static Future<void> setCandidateText(String value) async {
    value = _candidateFormat(value);
    _candidateText = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefCandidateText, value);
  }

  static Future<void> setPrizeText(String value) async {
    value = _prizeFormat(value);
    _prizeText = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefPrizeText, value);
  }

  static Future<void> setHistoryText(String value) async {
    value = _historyFormat(value);
    _historyText = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefHistoryText, value);
  }

  static Future<void> setHistoryDrawFlag(bool value) async {
    _historyDrawFlag = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefHistoryDrawFlag, value);
  }

  static Future<void> setMachineImageIndex(int value) async {
    _machineImageIndex = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefMachineImageIndex, value);
  }

  static Future<void> setMachineSpeed(int value) async {
    _machineSpeed = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefMachineSpeed, value);
  }

  static Future<void> setMachineSoundVolume(double value) async {
    _machineSoundVolume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefMachineSoundVolume, _machineSoundVolume);
  }

  static Future<void> setPrizeSoundVolume(double value) async {
    _prizeSoundVolume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefPrizeSoundVolume, _prizeSoundVolume);
  }

  static Future<bool> addHistoryText(int value) async {
    List<int> numbers = getHistoryNumbers();
    if (numbers.contains(value)) {
      return false;
    }
    numbers.add(value);
    _historyText = numbers.map((int value) => value.toString()).join(',');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefHistoryText, _historyText);
    return true;
  }

  static Future<void> setTtsEnabled(bool value) async {
    _ttsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefTtsEnabled, value);
  }

  static Future<void> setTtsVoiceId(String value) async {
    _ttsVoiceId = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefTtsVoiceId, value);
  }

  static Future<void> setTtsVolume(double value) async {
    _ttsVolume = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefTtsVolume, value);
  }

  static Future<void> setThemeNumber(int value) async {
    _themeNumber = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefThemeNumber, value);
  }

  static Future<void> setLanguageCode(String value) async {
    _languageCode = value;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLanguageCode, value);
  }

  static List<int> _parseStrToNumbers(String numString) {
    final List<String> numStrings = numString.split(',');
    final List<int> numbers = <int>[];
    for (final String str in numStrings) {
      if (str.contains('-')) {
        final List<String> ary = str.split('-');
        if (_isStringToIntParsable(ary[0]) && _isStringToIntParsable(ary[1])) {
          for (int i = int.parse(ary[0]); i <= int.parse(ary[1]); i++) {
            numbers.add(i);
          }
        }
      } else {
        if (_isStringToIntParsable(str)) {
          numbers.add(int.parse(str));
        }
      }
    }
    return Set<int>.from(numbers).toList();
  }

  static bool _isStringToIntParsable(String str) {
    return int.tryParse(str) != null;
  }

  static String _candidateFormat(String str) {
    str = str.replaceAll('０','0');
    str = str.replaceAll('１','1');
    str = str.replaceAll('２','2');
    str = str.replaceAll('３','3');
    str = str.replaceAll('４','4');
    str = str.replaceAll('５','5');
    str = str.replaceAll('６','6');
    str = str.replaceAll('７','7');
    str = str.replaceAll('８','8');
    str = str.replaceAll('９','9');
    str = str.replaceAll('、',',');
    str = str.replaceAll('，',',');
    str = str.replaceAll('ー','-');
    str = str.replaceAll('―','-');
    str = str.replaceAll(RegExp(r'[^0-9,-]'), '');
    str = str.replaceAll(RegExp(r',+'), ',');
    str = str.replaceAll(RegExp(r'\-+'), '-');
    return str;
  }

  static String _prizeFormat(String str) {
    final List<String> lines = str.replaceAll('\r','').split('\n');
    List<String> prizes = [];
    for (String str in lines) {
      str = str.replaceAll('：',':');
      if (str.contains(':') == false) {
        continue;
      }
      List<String> ary = str.split(':');
      ary[0] = ary[0].replaceAll('０','0');
      ary[0] = ary[0].replaceAll('１','1');
      ary[0] = ary[0].replaceAll('２','2');
      ary[0] = ary[0].replaceAll('３','3');
      ary[0] = ary[0].replaceAll('４','4');
      ary[0] = ary[0].replaceAll('５','5');
      ary[0] = ary[0].replaceAll('６','6');
      ary[0] = ary[0].replaceAll('７','7');
      ary[0] = ary[0].replaceAll('８','8');
      ary[0] = ary[0].replaceAll('９','9');
      ary[0] = ary[0].replaceAll('、',',');
      ary[0] = ary[0].replaceAll('，',',');
      ary[0] = ary[0].replaceAll('ー','-');
      ary[0] = ary[0].replaceAll('―','-');
      ary[0] = ary[0].replaceAll(RegExp(r'[^0-9,-]'), '');
      ary[0] = ary[0].replaceAll(RegExp(r',+'), ',');
      ary[0] = ary[0].replaceAll(RegExp(r'\-+'), '-');
      prizes.add('${ary[0]}:${ary[1]}');
    }
    return prizes.join('\n');
  }

  static String _historyFormat(String str) {
    str = str.replaceAll('０','0');
    str = str.replaceAll('１','1');
    str = str.replaceAll('２','2');
    str = str.replaceAll('３','3');
    str = str.replaceAll('４','4');
    str = str.replaceAll('５','5');
    str = str.replaceAll('６','6');
    str = str.replaceAll('７','7');
    str = str.replaceAll('８','8');
    str = str.replaceAll('９','9');
    str = str.replaceAll('、',',');
    str = str.replaceAll('，',',');
    str = str.replaceAll(RegExp(r'[^0-9,]'), '');
    str = str.replaceAll(RegExp(r',+'), ',');
    return str;
  }

}
