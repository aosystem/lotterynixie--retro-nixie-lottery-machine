import 'package:just_audio/just_audio.dart';

import 'package:lotterynixie/const_value.dart';

class AudioPlay {
  static final List<AudioPlayer> _playerMachineStart = [
    AudioPlayer(),
    AudioPlayer(),
  ];
  static final List<AudioPlayer> _playerMachineStop = [
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
  ];
  static final List<AudioPlayer> _playerPrize = [
    AudioPlayer(),
    AudioPlayer(),
  ];
  int _playerMachineStartPtr = 0;
  int _playerMachineStopPtr = 0;
  int _playerPrizePtr = 0;

  double _machineSoundVolume = 1.0;
  double _prizeSoundVolume = 1.0;

  AudioPlay() {
    _initial();
  }
  void _initial() async {
    for (int i = 0; i < _playerMachineStart.length; i++) {
      await _playerMachineStart[i].setVolume(0);
      await _playerMachineStart[i].setAsset(ConstValue.audioMachineStart);
    }
    for (int i = 0; i < _playerMachineStop.length; i++) {
      await _playerMachineStop[i].setVolume(0);
      await _playerMachineStop[i].setAsset(ConstValue.audioMachineStop);
    }
    for (int i = 0; i < _playerPrize.length; i++) {
      await _playerPrize[i].setVolume(0);
      await _playerPrize[i].setAsset(ConstValue.audioPrize);
    }
  }
  void dispose() {
    for (int i = 0; i < _playerMachineStart.length; i++) {
      _playerMachineStart[i].dispose();
    }
    for (int i = 0; i < _playerMachineStop.length; i++) {
      _playerMachineStop[i].dispose();
    }
    for (int i = 0; i < _playerPrize.length; i++) {
      _playerPrize[i].dispose();
    }
  }
  set machineSoundVolume(double vol) {
    _machineSoundVolume = vol;
  }
  set prizeSoundVolume(double vol) {
    _prizeSoundVolume = vol;
  }
  //
  void playMachineStart() async {
    _playerMachineStartPtr += 1;
    if (_playerMachineStartPtr >= _playerMachineStart.length) {
      _playerMachineStartPtr = 0;
    }
    await _playerMachineStart[_playerMachineStartPtr].setVolume(_machineSoundVolume);
    await _playerMachineStart[_playerMachineStartPtr].pause();
    await _playerMachineStart[_playerMachineStartPtr].seek(Duration.zero);
    await _playerMachineStart[_playerMachineStartPtr].play();
  }
  void playMachineStop() async {
    _playerMachineStopPtr += 1;
    if (_playerMachineStopPtr >= _playerMachineStop.length) {
      _playerMachineStopPtr = 0;
    }
    await _playerMachineStop[_playerMachineStopPtr].setVolume(_machineSoundVolume);
    await _playerMachineStop[_playerMachineStopPtr].pause();
    await _playerMachineStop[_playerMachineStopPtr].seek(Duration.zero);
    await _playerMachineStop[_playerMachineStopPtr].play();
  }
  void playPrize() async {
    _playerPrizePtr += 1;
    if (_playerPrizePtr >= _playerPrize.length) {
      _playerPrizePtr = 0;
    }
    await _playerPrize[_playerPrizePtr].setVolume(_prizeSoundVolume);
    await _playerPrize[_playerPrizePtr].pause();
    await _playerPrize[_playerPrizePtr].seek(Duration.zero);
    await _playerPrize[_playerPrizePtr].play();
  }
}