import 'package:flutter/foundation.dart';

/// No-op ads implementation for the web demo build.
///
/// AdMob has no web SDK, so on web the game simply runs ad-free: banners
/// render nothing, interstitials dismiss immediately and rewarded offers
/// report themselves unavailable (so the UI hides those buttons).
///
/// Must mirror the public API of ad_service_io.dart exactly.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  bool get isReady => false;

  bool get isRewardedReady => false;

  bool get privacyOptionsRequired => false;

  Future<void> init() async {}

  void maybeShowInterstitial({required VoidCallback onDismissed}) {
    onDismissed();
  }

  void showRewarded({
    required VoidCallback onReward,
    VoidCallback? onDismissed,
    VoidCallback? onUnavailable,
  }) {
    onUnavailable?.call();
  }

  Future<void> showPrivacyOptions() async {}
}
