import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:lotterynixie/ad_banner_widget.dart';
import 'package:lotterynixie/ad_manager.dart';
import 'package:lotterynixie/audio_play.dart';
import 'package:lotterynixie/const_value.dart';
import 'package:lotterynixie/l10n/app_localizations.dart';
import 'package:lotterynixie/loading_screen.dart';
import 'package:lotterynixie/model.dart';
import 'package:lotterynixie/parse_locale_tag.dart';
import 'package:lotterynixie/setting_page.dart';
import 'package:lotterynixie/text_to_speech.dart';
import 'package:lotterynixie/theme_mode_number.dart';
import 'package:lotterynixie/theme_color.dart';
import 'package:lotterynixie/main.dart';

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});
  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  late AdManager _adManager;
  final AudioPlay _audioPlay = AudioPlay();
  late ThemeColor _themeColor;
  bool _isReady = false;
  bool _isFirst = true;
  //
  bool _busyFlag = false;
  int _resultNumber = 0;
  final List<int> _pieceSpeeds = [1,2,3,4,5];
  final TextEditingController _controllerDisplayPrizeString = TextEditingController();
  final TextEditingController _controllerDisplayRemainString = TextEditingController();
  final TextEditingController _controllerDisplayHistoryString = TextEditingController();
  double _displayPrizeStringOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _initState();
  }

  Future<void> _initState() async {
    _adManager = AdManager();
    _audioPlay.machineSoundVolume = Model.machineSoundVolume;
    _audioPlay.prizeSoundVolume = Model.prizeSoundVolume;
    _audioPlay.playMachineStop();
    await TextToSpeech.applyPreferences(Model.ttsVoiceId,Model.ttsVolume);
    if (!kIsWeb && Platform.isAndroid) {
      _audioPlay.playMachineStop();
    }
    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  @override
  void dispose() {
    _adManager.dispose();
    super.dispose();
  }

  Widget _digit(dynamic constraints, double left, int column) {
    return Positioned(
        left: constraints.maxHeight * left,
        top: constraints.maxHeight * 0.345,
        child: SizedBox(
          width: constraints.maxHeight * 0.09,
          child: Image.asset(_resultNumberCellImage(column)),
        )
    );
  }

  Widget _stage(AppLocalizations l) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 1 / 1,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              children: <Widget>[
                Image.asset(ConstValue.machineImages[Model.machineImageIndex]),
                _digit(constraints, 0.162, 4),
                _digit(constraints, 0.307, 3),
                _digit(constraints, 0.452, 2),
                _digit(constraints, 0.597, 1),
                _digit(constraints, 0.744, 0),
                _prizeArea(),
                Positioned(
                  right: 6,
                  bottom: 6,
                  child: ElevatedButton(
                    onPressed: _busyFlag ? null : _lottery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _themeColor.mainStartBackColor,
                      foregroundColor: _themeColor.mainStartForeColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 10,
                      ),
                    ),
                    child: Text(l.start,style: const TextStyle(fontSize: 18.0)),
                  ),
                ),
              ]
            );
          }
        )
      )
    );
  }

  Future<void> _openSetting() async {
    if (_busyFlag) {
      return;
    }
    final updatedSettings = await Navigator.push<bool>(context,
      MaterialPageRoute(builder: (_) => const SettingPage()),
    );
    if (updatedSettings == true) {
      if (mounted) {
        _audioPlay.machineSoundVolume = Model.machineSoundVolume;
        _audioPlay.prizeSoundVolume = Model.prizeSoundVolume;
        List<int> historyNumbers = Model.getHistoryNumbers();
        historyNumbers = historyNumbers.reversed.toList();
        _controllerDisplayHistoryString.text = historyNumbers.join(', ');
        await TextToSpeech.applyPreferences(Model.ttsVoiceId,Model.ttsVolume);
        //
        final mainState = context.findAncestorStateOfType<MainAppState>();
        if (mainState != null) {
          mainState
            ..themeMode = ThemeModeNumber.numberToThemeMode(Model.themeNumber)
            ..locale = parseLocaleTag(Model.languageCode)
            ..setState(() {});
          setState(() {
            _isFirst = true;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const LoadingScreen();
    }
    if (_isFirst) {
      _isFirst = false;
      _themeColor = ThemeColor(themeNumber: Model.themeNumber, context: context);
    }
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _themeColor.mainBackColor,
      body: Stack(children:[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_themeColor.mainBack2Color,_themeColor.mainBackColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            image: DecorationImage(
              image: AssetImage('assets/image/tile.png'),
              repeat: ImageRepeat.repeat,
              opacity: 0.1,
            ),
          ),
        ),
        SafeArea(
          child: Column(children:[
            SizedBox(
              height: 36,
              child: Row(children:[
                const Spacer(),
                Opacity(
                  opacity: _busyFlag ? 0.3 : 1,
                  child: IconButton(
                    tooltip: l.setting,
                    icon: Icon(Icons.settings, color: _themeColor.mainButtonColor),
                    onPressed: _openSetting,
                  ),
                ),
              ])
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _stage(l),
                    _remainArea(),
                    _historyArea(),
                  ]
                )
              )
            ),
          ])
        )
      ]),
      bottomNavigationBar: AdBannerWidget(adManager: _adManager),
    );
  }

  Widget _prizeArea() {
    return AnimatedOpacity(
        opacity: _displayPrizeStringOpacity,
        duration: const Duration(milliseconds: 500),
        child: _controllerDisplayPrizeString.text.isEmpty
            ? const SizedBox.shrink()
            : Container(
            margin: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              color: Colors.yellowAccent,
              borderRadius: BorderRadius.circular(50.0),
            ),
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
                width: double.infinity,
                child: Text(
                  _controllerDisplayPrizeString.text,
                  maxLines: null,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 22.0),
                )
            )
        )
    );
  }

  Widget _remainArea() {
    if (Model.historyDrawFlag == false) {
      return SizedBox.shrink();
    }
    return TextField(
      controller: _controllerDisplayRemainString,
      maxLines: null,
      readOnly: true,
      style: TextStyle(color: _themeColor.mainCandidateForeColor),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 0),
        border: InputBorder.none,
      ),
    );
  }

  Widget _historyArea() {
    if (Model.historyDrawFlag == false) {
      return SizedBox.shrink();
    }
    return TextField(
      controller: _controllerDisplayHistoryString,
      maxLines: null,
      readOnly: true,
      style: TextStyle(color: _themeColor.mainHistoryForeColor, fontSize: 26),
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 10),
        border: InputBorder.none,
      ),
    );
  }

  String _resultNumberCellImage(int column) {
    if (_resultNumber == -1) {
      return ConstValue.numberImages[10];
    }
    final int num = (_resultNumber / pow(10, column)).floor() % 10;
    return ConstValue.numberImages[num];
  }

  void _lottery() async {
    if (_busyFlag) {
      return;
    }
    setState(() {
      _busyFlag = true;
    });
    _controllerDisplayPrizeString.text = '';
    final List<int> historyNumbers = Model.getHistoryNumbers().reversed.toList();
    _controllerDisplayHistoryString.text = historyNumbers.join(', ');
    int nextNumber = await _nextNumber();
    if (nextNumber == -1) {
      setState(() {
        _resultNumber = nextNumber;
        _busyFlag = false;
      });
      return;
    }
    if (await Model.addHistoryText(nextNumber) == false) {
      return;
    }
    _pieceSpeeds.shuffle();
    _audioPlay.playMachineStart();
    final int digitSpeed = (10 - Model.machineSpeed) * 15;
    _lotteryRecursion(nextNumber, digitSpeed, 4);
  }

  void _lotteryRecursion(int nextNumber, int timeRemain, int stopColumn) {
    for (int column = stopColumn; column >= 0; column--) {
      if (timeRemain % _pieceSpeeds[column] == 0) {
        setState(() {
          _resultNumber = _resultNumberIncrement(_resultNumber, column);
        });
      }
    }
    timeRemain -= 1;
    if (timeRemain <= 0) {
      if (_resultNumberIsSamePiece(nextNumber,_resultNumber,stopColumn)) {
        _audioPlay.playMachineStop();
        stopColumn -= 1;
      }
    }
    if (stopColumn >= 0) {
      Timer(const Duration(milliseconds: 50), () =>
          _lotteryRecursion(nextNumber, timeRemain, stopColumn)
      );
    } else {
      setState(() async {
        _resultNumber = nextNumber;
        await Future.delayed(const Duration(milliseconds: 500));
        if (Model.ttsEnabled && Model.ttsVolume > 0.0) {
          TextToSpeech.speak(nextNumber.toString());
        }
        _prizeDraw(nextNumber);
        setState(() {
          _controllerDisplayHistoryString.text =
          '$nextNumber\n${_controllerDisplayHistoryString.text}';
          _busyFlag = false;
        });
      });
    }
  }

  Future<int> _nextNumber() async {
    List<int> remains = Model.getCandidateNumbers();
    if (Model.getHistoryNumbers().isNotEmpty) {
      remains = remains.where((int num) => !Model.getHistoryNumbers().contains(num)).toList();
    }
    if (remains.isEmpty) {
      return -1;
    }
    _controllerDisplayRemainString.text = 'Candidates:${Model.getCandidateNumbers().length}　Results:${Model.getHistoryNumbers().length + 1}　Remaining:${remains.length - 1}';
    final int nextNumber = remains[Random().nextInt(remains.length)];
    return nextNumber;
  }

  int _resultNumberIncrement(int resultNumber, int column) {
    final List<int> numberPieces = [
      _resultNumber % 10,
      (_resultNumber / 10).floor() % 10,
      (_resultNumber / 100).floor() % 10,
      (_resultNumber / 1000).floor() % 10,
      (_resultNumber / 10000).floor() % 10,
    ];
    numberPieces[column] += 1;
    if (numberPieces[column] >= 10) {
      numberPieces[column] = 0;
    }
    final String str = numberPieces[4].toString() + numberPieces[3].toString() + numberPieces[2].toString() + numberPieces[1].toString() + numberPieces[0].toString();
    return int.parse(str);
  }

  bool _resultNumberIsSamePiece(int nextNumber, int resultNumber, column) {
    final int nextDigit = (nextNumber / pow(10,column)).floor() % 10;
    final int resultDigit = (resultNumber / pow(10,column)).floor() % 10;
    return (nextDigit == resultDigit) ? true : false;
  }

  void _prizeDraw(int nextNumber) async {
    for (final Map<String, dynamic> mapListOne in Model.getPrizeList()) {
      for (int j = 0; j < mapListOne['numbers'].length; j++) {
        if (mapListOne['numbers'][j] == nextNumber) {
          _controllerDisplayPrizeString.text = mapListOne['prize'];
          _displayPrizeStringOpacity = 1.0;
          await Future.delayed(const Duration(milliseconds: 1200));
          _audioPlay.playPrize();
          setState(() {});
          return;
        }
      }
    }
    _controllerDisplayPrizeString.text = '';
    _displayPrizeStringOpacity = 0.0;
    setState(() {});
  }

}
