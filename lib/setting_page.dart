import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:lotterynixie/l10n/app_localizations.dart';
import 'package:lotterynixie/const_value.dart';
import 'package:lotterynixie/model.dart';
import 'package:lotterynixie/text_to_speech.dart';
import 'package:lotterynixie/ad_manager.dart';
import 'package:lotterynixie/ad_banner_widget.dart';
import 'package:lotterynixie/ad_ump_status.dart';
import 'package:lotterynixie/theme_color.dart';
import 'package:lotterynixie/loading_screen.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late AdManager _adManager;
  late UmpConsentController _adUmp;
  AdUmpState _adUmpState = AdUmpState.initial;
  int _themeNumber = 0;
  String _languageCode = '';
  late ThemeColor _themeColor;
  final _inAppReview = InAppReview.instance;
  bool _isReady = false;
  bool _isFirst = true;
  //
  final TextEditingController _controllerCandidateText = TextEditingController();
  final TextEditingController _controllerPrizeText = TextEditingController();
  final TextEditingController _controllerHistoryText = TextEditingController();
  bool _candidateInitialFlag = false;
  bool _prizeInitialFlag = false;
  bool _historyInitialFlag = false;
  bool _historyDrawFlag = true;
  int _machineImageIndex = 0;
  int _machineSpeedValue = 1;
  double _machineSoundVolume = 1.0;
  double _prizeSoundVolume = 1.0;
  late List<TtsOption> _ttsVoices;
  bool _ttsEnabled = true;
  double _ttsVolume = 1.0;
  String _ttsVoiceId = '';

  @override
  void initState() {
    super.initState();
    _initState();
  }

  void _initState() async {
    _adManager = AdManager();
    _themeNumber = Model.themeNumber;
    _languageCode = Model.languageCode;
    //
    _adUmp = UmpConsentController();
    _refreshConsentInfo();
    //
    _controllerCandidateText.text = Model.candidateText;
    _controllerPrizeText.text = Model.prizeText;
    _controllerHistoryText.text = Model.historyText;
    _historyDrawFlag = Model.historyDrawFlag;
    _machineImageIndex = Model.machineImageIndex;
    _machineSpeedValue = Model.machineSpeed;
    _machineSoundVolume = Model.machineSoundVolume;
    _prizeSoundVolume = Model.prizeSoundVolume;
    _ttsEnabled = Model.ttsEnabled;
    _ttsVolume = Model.ttsVolume;
    _ttsVoiceId = Model.ttsVoiceId;
    //speech
    await TextToSpeech.getInstance();
    _ttsVoices = TextToSpeech.ttsVoices;
    TextToSpeech.setVolume(_ttsVolume);
    TextToSpeech.setTtsVoiceId(_ttsVoiceId);
    //
    setState((){
      _isReady = true;
    });
  }

  @override
  void dispose() {
    _adManager.dispose();
    unawaited(TextToSpeech.stop());
    super.dispose();
  }

  Future<void> _onApply() async {
    if (_candidateInitialFlag) {
      await Model.setCandidateText(ConstValue.candidateTextDefault);
    } else {
      await Model.setCandidateText(_controllerCandidateText.text);
    }
    if (_prizeInitialFlag) {
      await Model.setPrizeText(ConstValue.prizeTextDefault);
    } else {
      await Model.setPrizeText(_controllerPrizeText.text);
    }
    if (_historyInitialFlag) {
      await Model.setHistoryText(ConstValue.historyTextDefault);
    } else {
      await Model.setHistoryText(_controllerHistoryText.text);
    }
    await Model.setHistoryDrawFlag(_historyDrawFlag);
    await Model.setMachineImageIndex(_machineImageIndex);
    await Model.setMachineSpeed(_machineSpeedValue);
    await Model.setMachineSoundVolume(_machineSoundVolume);
    await Model.setPrizeSoundVolume(_prizeSoundVolume);
    await Model.setTtsEnabled(_ttsEnabled);
    await Model.setTtsVoiceId(_ttsVoiceId);
    await Model.setTtsVolume(_ttsVolume);
    await Model.setThemeNumber(_themeNumber);
    await Model.setLanguageCode(_languageCode);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _refreshConsentInfo() async {
    _adUmpState = await _adUmp.updateConsentInfo(current: _adUmpState);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _onTapPrivacyOptions() async {
    final err = await _adUmp.showPrivacyOptions();
    await _refreshConsentInfo();
    if (err != null && mounted) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l.cmpErrorOpeningSettings} ${err.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const LoadingScreen();
    }
    if (_isFirst) {
      _isFirst = false;
      _themeColor = ThemeColor(themeNumber: _themeNumber, context: context);
    }
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: _themeColor.backColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        title: Text(l.setting),
        foregroundColor: _themeColor.appBarForegroundColor,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onApply,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children:[
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 100),
                  child: Column(
                    children: [
                      _buildCandidate(l),
                      _buildPrize(l),
                      _buildHistory(l),
                      _buildMachineImage(l),
                      _buildSpeed(l),
                      _buildMachineVolume(l),
                      _buildSoundVolume(l),
                      _buildSpeechSettings(l),
                      _buildTheme(l),
                      _buildLanguage(l),
                      _buildReview(l),
                      _buildCmp(l),
                      _buildUsage(l),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ])
      ),
      bottomNavigationBar: AdBannerWidget(adManager: _adManager),
    );
  }

  Widget _buildCandidate(AppLocalizations l) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 0),
            child: Row(children:<Widget>[
              Expanded(
                child: Text(l.candidate,style: const TextStyle(fontSize: 16)),
              ),
              Text(l.initial),
              Switch(
                value: _candidateInitialFlag,
                onChanged: (bool value) {
                  setState(() {
                    _candidateInitialFlag = value;
                  });
                },
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1, left: 16, right: 16, bottom: 16),
            child: TextField(
              controller: _controllerCandidateText,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          )
        ])
      )
    );
  }

  Widget _buildPrize(AppLocalizations l) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 0),
            child: Row(children:<Widget>[
              Expanded(
                child: Text(l.prize,style: const TextStyle(fontSize: 16)),
              ),
              Text(l.initial),
              Switch(
                value: _prizeInitialFlag,
                onChanged: (bool value) {
                  setState(() {
                    _prizeInitialFlag = value;
                  });
                },
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1, left: 16, right: 16, bottom: 16),
            child: TextField(
              controller: _controllerPrizeText,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ])
      )
    );
  }

  Widget _buildHistory(AppLocalizations l) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 0),
            child: Row(children:<Widget>[
              Expanded(
                child: Text(l.history,style: const TextStyle(fontSize: 16)),
              ),
              Text(l.erase),
              Switch(
                value: _historyInitialFlag,
                onChanged: (bool value) {
                  setState(() {
                    _historyInitialFlag = value;
                  });
                },
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1, left: 16, right: 16, bottom: 0),
            child: TextField(
              controller: _controllerHistoryText,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 0, left: 16, right: 16, bottom: 6),
            child: Row(children:<Widget>[
              Expanded(
                child: Text(l.historyMainDraw,style: const TextStyle(fontSize: 16)),
              ),
              Switch(
                value: _historyDrawFlag,
                onChanged: (bool value) {
                  setState(() {
                    _historyDrawFlag = value;
                  });
                },
              ),
            ]),
          ),
        ])
      )
    );
  }

  Widget _buildMachineImage(AppLocalizations l) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 0),
            child: Row(children: [
              Text(l.machineImageIndex,style: const TextStyle(fontSize: 16)),
              const Spacer(),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: <Widget>[
                Text(_machineImageIndex.toString()),
                Expanded(
                  child: Slider(
                    value: _machineImageIndex.toDouble(),
                    min: 0,
                    max: ConstValue.machineImages.length - 1,
                    divisions: ConstValue.machineImages.length - 1,
                    label: _machineImageIndex.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _machineImageIndex = value.toInt();
                      });
                    }
                  ),
                ),
              ],
            ),
          ),
        ])
      )
    );
  }

  Widget _buildSpeed(AppLocalizations l) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 0),
            child: Row(children: [
              Text(l.machineSpeed,style: const TextStyle(fontSize: 16)),
              const Spacer(),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: <Widget>[
                Text(_machineSpeedValue.toString()),
                Expanded(
                  child: Slider(
                    value: _machineSpeedValue.toDouble(),
                    min: 1,
                    max: 9,
                    divisions: 9,
                    label: _machineSpeedValue.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _machineSpeedValue = value.toInt();
                      });
                    }
                  ),
                ),
              ],
            ),
          ),
        ])
      )
    );
  }

  Widget _buildMachineVolume(AppLocalizations l) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 0),
            child: Row(children: [
              Text(l.machineSoundVolume, style: const TextStyle(fontSize: 16)),
              const Spacer(),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: <Widget>[
                Text(_machineSoundVolume.toStringAsFixed(1)),
                Expanded(
                  child: Slider(
                    value: _machineSoundVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: _machineSoundVolume.toStringAsFixed(1),
                    onChanged: (double value) {
                      setState(() {
                        _machineSoundVolume = double.parse(value.toStringAsFixed(1));
                      });
                    }
                  ),
                ),
              ],
            ),
          ),
        ])
      )
    );
  }

  Widget _buildSoundVolume(AppLocalizations l) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
        color: _themeColor.cardColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 0),
            child: Row(children: [
              Text(l.prizeSoundVolume,style: const TextStyle(fontSize: 16)),
              const Spacer(),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: <Widget>[
                Text(_prizeSoundVolume.toStringAsFixed(1)),
                Expanded(
                  child: Slider(
                    value: _prizeSoundVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: _prizeSoundVolume.toStringAsFixed(1),
                    onChanged: (double value) {
                      setState(() {
                        _prizeSoundVolume = double.parse(value.toStringAsFixed(1));
                      });
                    }
                  ),
                ),
              ],
            ),
          ),
        ])
      )
    );
  }

  Widget _buildSpeechSettings(AppLocalizations l) {
    if (_ttsVoices.isEmpty) {
      return SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(l.ttsEnabled),
                ),
                Switch(
                  value: _ttsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _ttsEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: [
                Text(l.ttsVolume),
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: <Widget>[
                Text(_ttsVolume.toStringAsFixed(1)),
                Expanded(
                  child: Slider(
                    value: _ttsVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: _ttsVolume.toStringAsFixed(1),
                    onChanged: _ttsEnabled
                        ? (double value) {
                      setState(() {
                        _ttsVolume = double.parse(value.toStringAsFixed(1));
                      });
                    }
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Row(
              children: [
                Text(l.ttsVoiceId),
                const Spacer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: DropdownButtonFormField<String>(
              dropdownColor: _themeColor.dropdownColor,
              initialValue: () {
                if (_ttsVoiceId.isNotEmpty && _ttsVoices.any((o) => o.id == _ttsVoiceId)) {
                  return _ttsVoiceId;
                }
                return _ttsVoices.first.id;
              }(),
              items: _ttsVoices
                  .map((o) => DropdownMenuItem<String>(value: o.id, child: Text(o.label)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _ttsVoiceId = v);
              },
            ),
          ),
        ],
      )
    );
  }

  Widget _buildTheme(AppLocalizations l) {
    final TextTheme t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l.theme,
                style: t.bodyMedium,
              ),
            ),
            DropdownButton<int>(
              value: _themeNumber,
              items: [
                DropdownMenuItem(value: 0, child: Text(l.systemSetting)),
                DropdownMenuItem(value: 1, child: Text(l.lightTheme)),
                DropdownMenuItem(value: 2, child: Text(l.darkTheme)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _themeNumber = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguage(AppLocalizations l) {
    final Map<String,String> languageNames = {
      'af': 'af: Afrikaans',
      'ar': 'ar: العربية',
      'bg': 'bg: Български',
      'bn': 'bn: বাংলা',
      'bs': 'bs: Bosanski',
      'ca': 'ca: Català',
      'cs': 'cs: Čeština',
      'da': 'da: Dansk',
      'de': 'de: Deutsch',
      'el': 'el: Ελληνικά',
      'en': 'en: English',
      'es': 'es: Español',
      'et': 'et: Eesti',
      'fa': 'fa: فارسی',
      'fi': 'fi: Suomi',
      'fil': 'fil: Filipino',
      'fr': 'fr: Français',
      'gu': 'gu: ગુજરાતી',
      'he': 'he: עברית',
      'hi': 'hi: हिन्दी',
      'hr': 'hr: Hrvatski',
      'hu': 'hu: Magyar',
      'id': 'id: Bahasa Indonesia',
      'it': 'it: Italiano',
      'ja': 'ja: 日本語',
      'km': 'km: ខ្មែរ',
      'kn': 'kn: ಕನ್ನಡ',
      'ko': 'ko: 한국어',
      'lt': 'lt: Lietuvių',
      'lv': 'lv: Latviešu',
      'ml': 'ml: മലയാളം',
      'mr': 'mr: मराठी',
      'ms': 'ms: Bahasa Melayu',
      'my': 'my: မြန်မာ',
      'ne': 'ne: नेपाली',
      'nl': 'nl: Nederlands',
      'or': 'or: ଓଡ଼ିଆ',
      'pa': 'pa: ਪੰਜਾਬੀ',
      'pl': 'pl: Polski',
      'pt': 'pt: Português',
      'ro': 'ro: Română',
      'ru': 'ru: Русский',
      'si': 'si: සිංහල',
      'sk': 'sk: Slovenčina',
      'sr': 'sr: Српски',
      'sv': 'sv: Svenska',
      'sw': 'sw: Kiswahili',
      'ta': 'ta: தமிழ்',
      'te': 'te: తెలుగు',
      'th': 'th: ไทย',
      'tl': 'tl: Tagalog',
      'tr': 'tr: Türkçe',
      'uk': 'uk: Українська',
      'ur': 'ur: اردو',
      'uz': 'uz: Oʻzbekcha',
      'vi': 'vi: Tiếng Việt',
      'zh': 'zh: 中文',
      'zu': 'zu: isiZulu',
    };
    final TextTheme t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l.language,
                style: t.bodyMedium,
              ),
            ),
            DropdownButton<String?>(
              value: _languageCode,
              items: [
                DropdownMenuItem(value: '', child: Text('Default')),
                ...languageNames.entries.map((entry) => DropdownMenuItem<String?>(
                  value: entry.key,
                  child: Text(entry.value),
                )),
              ],
              onChanged: (String? value) {
                setState(() {
                  _languageCode = value ?? '';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(AppLocalizations l) {
    final TextTheme t = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.reviewApp, style: t.bodyMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  icon: Icon(Icons.open_in_new, size: 16),
                  label: Text(l.reviewStore, style: t.bodySmall),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
                    side: BorderSide(color: Theme.of(context).colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await _inAppReview.openStoreListing(
                      appStoreId: 'YOUR_APP_STORE_ID',
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCmp(AppLocalizations l) {
    final TextTheme t = Theme.of(context).textTheme;
    final showButton = _adUmpState.privacyStatus == PrivacyOptionsRequirementStatus.required;
    String statusLabel = l.cmpCheckingRegion;
    IconData statusIcon = Icons.help_outline;
    switch (_adUmpState.privacyStatus) {
      case PrivacyOptionsRequirementStatus.required:
        statusLabel = l.cmpRegionRequiresSettings;
        statusIcon = Icons.privacy_tip_outlined;
        break;
      case PrivacyOptionsRequirementStatus.notRequired:
        statusLabel = l.cmpRegionNoSettingsRequired;
        statusIcon = Icons.check_circle_outline;
        break;
      case PrivacyOptionsRequirementStatus.unknown:
        statusLabel = l.cmpRegionCheckFailed;
        statusIcon = Icons.error_outline;
        break;
    }
    return Card(
      margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
      color: _themeColor.cardColor,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.cmpSettingsTitle,
              style: t.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              l.cmpConsentDescription,
              style: t.bodySmall,
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Chip(
                    avatar: Icon(statusIcon, size: 18),
                    label: Text(statusLabel),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${l.cmpConsentStatusLabel} ${_adUmpState.consentStatus.localized(context)}',
                    style: t.bodySmall,
                  ),
                  if (showButton) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _adUmpState.isChecking
                          ? null
                          : _onTapPrivacyOptions,
                      icon: const Icon(Icons.settings),
                      label: Text(
                        _adUmpState.isChecking
                            ? l.cmpConsentStatusChecking
                            : l.cmpOpenConsentSettings,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _adUmpState.isChecking
                          ? null
                          : _refreshConsentInfo,
                      icon: const Icon(Icons.refresh),
                      label: Text(l.cmpRefreshStatus),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final message = l.cmpResetStatusDone;
                        await ConsentInformation.instance.reset();
                        await _refreshConsentInfo();
                        if (!mounted) {
                          return;
                        }
                        messenger.showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                      },
                      icon: const Icon(Icons.delete_sweep_outlined),
                      label: Text(l.cmpResetStatus),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsage(AppLocalizations l) {
    final TextTheme t = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
        color: _themeColor.cardColor,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.usage1,
                style: t.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                l.usage2,
                style: t.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                l.usage3,
                style: t.bodySmall,
              ),
              const SizedBox(height: 12),
              Text(
                l.usage4,
                style: t.bodySmall,
              ),
            ],
          ),
        ),
      )
    );
  }

}
