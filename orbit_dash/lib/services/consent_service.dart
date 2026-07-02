import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Handles the Google UMP (User Messaging Platform) consent flow required
/// by AdMob for users in the EEA/UK under GDPR.
///
/// Flow (per Google's documentation):
///  1. Request a consent info update on every app start.
///  2. Load & show the consent form if it is required (Google decides based
///     on the user's region and your AdMob "Privacy & messaging" setup).
///  3. Only start requesting ads once [ConsentInformation.canRequestAds()]
///     is true.
///
/// TODO(you): in the AdMob console, go to Privacy & messaging → create a
/// GDPR message for this app, otherwise European users get no ads at all.
class ConsentService {
  ConsentService._();

  static final ConsentService instance = ConsentService._();

  bool _privacyOptionsRequired = false;

  /// Whether the main menu should show a "Privacy settings" entry that
  /// reopens the consent form (required by GDPR once consent was gathered).
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  /// Runs the full consent flow. Returns true when ads may be requested.
  ///
  /// Never throws and never blocks forever: on any failure (offline, UMP
  /// unreachable, ...) it falls back to the cached consent state, so the
  /// game itself always starts.
  Future<bool> gatherConsent() async {
    final completer = Completer<bool>();

    final params = ConsentRequestParameters(
        // While testing the GDPR form, uncomment this block and add your
        // device's hashed ID (printed in logcat by the UMP SDK):
        //
        // consentDebugSettings: ConsentDebugSettings(
        //   debugGeography: DebugGeography.debugGeographyEea,
        //   testIdentifiers: ['YOUR-TEST-DEVICE-HASHED-ID'],
        // ),
        );

    try {
      ConsentInformation.instance.requestConsentInfoUpdate(
        params,
        () async {
          try {
            await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
              if (formError != null) {
                debugPrint(
                  'UMP consent form error: '
                  '${formError.errorCode} ${formError.message}',
                );
              }
              _finish(completer);
            });
          } catch (e) {
            debugPrint('UMP form exception: $e');
            _finish(completer);
          }
        },
        (FormError error) {
          debugPrint(
            'UMP consent update error: ${error.errorCode} ${error.message}',
          );
          _finish(completer);
        },
      );
    } catch (e) {
      debugPrint('UMP exception: $e');
      _finish(completer);
    }

    return completer.future;
  }

  Future<void> _finish(Completer<bool> completer) async {
    if (completer.isCompleted) return;
    var canRequestAds = false;
    try {
      canRequestAds = await ConsentInformation.instance.canRequestAds();
      _privacyOptionsRequired =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus() ==
              PrivacyOptionsRequirementStatus.required;
    } catch (_) {}
    completer.complete(canRequestAds);
  }

  /// Reopens the consent form so EEA users can change their choice.
  Future<void> showPrivacyOptions() async {
    try {
      await ConsentForm.showPrivacyOptionsForm((formError) {
        if (formError != null) {
          debugPrint('Privacy options error: ${formError.message}');
        }
      });
    } catch (e) {
      debugPrint('Privacy options exception: $e');
    }
  }
}
