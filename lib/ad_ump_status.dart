import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:lotterynixie/l10n/app_localizations.dart';

class AdUmpState {
  const AdUmpState({
    required this.privacyStatus,
    required this.consentStatus,
    required this.privacyOptionsRequired,
    required this.isChecking,
  });

  final PrivacyOptionsRequirementStatus privacyStatus;
  final ConsentStatus consentStatus;
  final bool privacyOptionsRequired;
  final bool isChecking;

  AdUmpState copyWith({
    PrivacyOptionsRequirementStatus? privacyStatus,
    ConsentStatus? consentStatus,
    bool? privacyOptionsRequired,
    bool? isChecking,
  }) {
    return AdUmpState(
      privacyStatus: privacyStatus ?? this.privacyStatus,
      consentStatus: consentStatus ?? this.consentStatus,
      privacyOptionsRequired:
          privacyOptionsRequired ?? this.privacyOptionsRequired,
      isChecking: isChecking ?? this.isChecking,
    );
  }

  static const initial = AdUmpState(
    privacyStatus: PrivacyOptionsRequirementStatus.unknown,
    consentStatus: ConsentStatus.unknown,
    privacyOptionsRequired: false,
    isChecking: false,
  );
}

class UmpConsentController {
  UmpConsentController({this.forceEeaForDebug = false});

  final bool forceEeaForDebug;

  static const List<String> _testDeviceIds = <String>[
    '608970392F100B87D62A1174996C952C',
  ];

  ConsentRequestParameters _buildParams() {
    if (forceEeaForDebug && _testDeviceIds.isNotEmpty) {
      return ConsentRequestParameters(
        consentDebugSettings: ConsentDebugSettings(
          debugGeography: DebugGeography.debugGeographyEea,
          testIdentifiers: _testDeviceIds,
        ),
      );
    }
    return ConsentRequestParameters();
  }

  Future<AdUmpState> updateConsentInfo({AdUmpState current = AdUmpState.initial}) async {
    if (kIsWeb) {
      return current;
    }
    var state = current.copyWith(isChecking: true);
    try {
      final params = _buildParams();
      final completer = Completer<AdUmpState>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          final requirement =
              await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
          final consent = await ConsentInformation.instance.getConsentStatus();
          completer.complete(
            state.copyWith(
              privacyStatus: requirement,
              consentStatus: consent,
              privacyOptionsRequired:
                  requirement == PrivacyOptionsRequirementStatus.required,
              isChecking: false,
            ),
          );
        },
        (FormError error) {
          completer.complete(
            state.copyWith(
              privacyStatus: PrivacyOptionsRequirementStatus.unknown,
              consentStatus: ConsentStatus.unknown,
              privacyOptionsRequired: false,
              isChecking: false,
            ),
          );
        },
      );
      state = await completer.future;
      return state;
    } catch (_) {
      return state.copyWith(isChecking: false);
    }
  }

  Future<FormError?> showPrivacyOptions() async {
    if (kIsWeb) {
      return null;
    }
    final completer = Completer<FormError?>();
    ConsentForm.showPrivacyOptionsForm((FormError? error) {
      completer.complete(error);
    });
    return completer.future;
  }
}

extension ConsentStatusL10n on ConsentStatus {
  String localized(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    switch (this) {
      case ConsentStatus.obtained:
        return localization.cmpConsentStatusObtained;
      case ConsentStatus.required:
        return localization.cmpConsentStatusRequired;
      case ConsentStatus.notRequired:
        return localization.cmpConsentStatusNotRequired;
      case ConsentStatus.unknown:
        return localization.cmpConsentStatusUnknown;
    }
  }
}
