import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../config/ad_config.dart';
import '../../config/meta_config.dart';
import '../consent_service.dart';
import '../meta_service.dart';
import '../storage_service.dart';

/// Owns the whole ad lifecycle: consent → SDK init → preloading →
/// showing → reloading.
///
/// Design rules (enforced here so the rest of the app can't get them wrong):
///  * Ads are ALWAYS optional. Every entry point is try/catch'd and the
///    game keeps working offline — ads simply skip.
///  * Interstitials only show after every [AdConfig.interstitialFrequency]-th
///    game over, never mid-game.
///  * Interstitial and rewarded ads are preloaded ahead of time so showing
///    them never blocks on a network round trip.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  bool _initialized = false;
  bool _initializing = false;

  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  int _interstitialLoadAttempts = 0;
  int _rewardedLoadAttempts = 0;

  /// True once the Mobile Ads SDK is up and ads may be requested.
  bool get isReady => _initialized;

  bool get isRewardedReady => _rewardedAd != null;

  /// Whether the menu should show a privacy-settings entry (GDPR regions).
  bool get privacyOptionsRequired =>
      ConsentService.instance.privacyOptionsRequired;

  /// Reopens the UMP consent form so users can change their choice.
  Future<void> showPrivacyOptions() =>
      ConsentService.instance.showPrivacyOptions();

  /// Full startup: UMP consent flow, then SDK init, then preload.
  /// Call once (fire-and-forget) after the first frame. Never throws.
  Future<void> init() async {
    if (_initialized || _initializing) return;
    _initializing = true;
    try {
      final canRequestAds = await ConsentService.instance.gatherConsent();
      if (!canRequestAds) {
        debugPrint('AdService: consent not obtained, ads disabled.');
        return;
      }
      // ── Google Play FAMILIES compliance (mandatory) ──────────────────
      // A football-themed game appeals to children, so we default to the
      // strictest configuration: child-directed treatment ON and max ad
      // content rating "G". With this tag Google does NOT transmit the
      // advertising ID and only serves ads from Families self-certified
      // SDKs. IMPORTANT: the Play Console "Target audience and content"
      // declaration MUST match this configuration (declare the child age
      // groups there), or the app gets rejected in review.
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
          maxAdContentRating: MaxAdContentRating.g,
        ),
      );
      await MobileAds.instance.initialize();
      _initialized = true;
      _loadInterstitial();
      _loadRewarded();
    } catch (e) {
      debugPrint('AdService init failed: $e');
    } finally {
      _initializing = false;
    }
  }

  // ── Banner ───────────────────────────────────────────────────────────────

  /// Creates and starts loading a banner. The caller (BannerAdWidget) owns
  /// and disposes it. Returns null when ads are unavailable.
  BannerAd? createBanner({
    required void Function(Ad) onLoaded,
    required void Function(Ad, LoadAdError) onFailed,
  }) {
    if (!_initialized) return null;
    try {
      final banner = BannerAd(
        adUnitId: AdConfig.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: onLoaded,
          onAdFailedToLoad: onFailed,
        ),
      );
      banner.load();
      return banner;
    } catch (e) {
      debugPrint('Banner create failed: $e');
      return null;
    }
  }

  // ── Interstitial ─────────────────────────────────────────────────────────

  void _loadInterstitial() {
    if (!_initialized) return;
    try {
      InterstitialAd.load(
        adUnitId: AdConfig.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _interstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial load failed: ${error.message}');
            _interstitialAd = null;
            _retry(_interstitialLoadAttempts++, _loadInterstitial);
          },
        ),
      );
    } catch (e) {
      debugPrint('Interstitial load exception: $e');
    }
  }

  /// Called once per game over (from the game-over screen, before leaving
  /// it). Shows a preloaded interstitial after every
  /// [AdConfig.interstitialFrequency]-th game over.
  ///
  /// [onDismissed] always fires exactly once — immediately when no ad is
  /// shown, or after the user closes the ad.
  int _interstitialsThisSession = 0;

  /// Families-friendly pacing: at most one interstitial per
  /// [MetaConfig.interstitialEveryNGameOvers] game overs, hard cap of
  /// [MetaConfig.interstitialSessionCap] per session, and NEVER right
  /// after a new-best celebration (pass [suppress] = true) — don't poison
  /// the dopamine peak.
  void maybeShowInterstitial(
      {required VoidCallback onDismissed, bool suppress = false}) {
    final count = StorageService.instance.incrementGameOverCount();
    final shouldShow = !suppress &&
        !MetaService.instance.ownsProduct('remove_ads') &&
        _interstitialsThisSession < MetaConfig.interstitialSessionCap &&
        count % MetaConfig.interstitialEveryNGameOvers == 0;
    final ad = _interstitialAd;

    if (!shouldShow || ad == null) {
      onDismissed();
      return;
    }

    _interstitialAd = null;
    _interstitialsThisSession++;
    try {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitial();
          onDismissed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Interstitial show failed: ${error.message}');
          ad.dispose();
          _loadInterstitial();
          onDismissed();
        },
      );
      ad.show();
    } catch (e) {
      debugPrint('Interstitial show exception: $e');
      _loadInterstitial();
      onDismissed();
    }
  }

  // ── Rewarded ─────────────────────────────────────────────────────────────

  void _loadRewarded() {
    if (!_initialized) return;
    try {
      RewardedAd.load(
        adUnitId: AdConfig.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _rewardedLoadAttempts = 0;
          },
          onAdFailedToLoad: (error) {
            debugPrint('Rewarded load failed: ${error.message}');
            _rewardedAd = null;
            _retry(_rewardedLoadAttempts++, _loadRewarded);
          },
        ),
      );
    } catch (e) {
      debugPrint('Rewarded load exception: $e');
    }
  }

  /// Shows the preloaded rewarded ad.
  ///
  /// [onReward] fires only when the user actually earned the reward.
  /// [onDismissed] fires after the ad closes (use it to resume the game —
  /// never resume in [onReward], the ad is still covering the screen then).
  /// [onUnavailable] fires when no ad could be shown, so callers can react
  /// (e.g. skip the "continue" option) instead of leaving the user hanging.
  void showRewarded({
    required VoidCallback onReward,
    VoidCallback? onDismissed,
    VoidCallback? onUnavailable,
  }) {
    final ad = _rewardedAd;
    if (ad == null) {
      onUnavailable?.call();
      return;
    }
    _rewardedAd = null;
    try {
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadRewarded();
          onDismissed?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Rewarded show failed: ${error.message}');
          ad.dispose();
          _loadRewarded();
          onUnavailable?.call();
        },
      );
      ad.show(
        onUserEarnedReward: (ad, reward) => onReward(),
      );
    } catch (e) {
      debugPrint('Rewarded show exception: $e');
      _loadRewarded();
      onUnavailable?.call();
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Exponential backoff retry: 2s, 4s, 8s — then gives up until the next
  /// natural reload (after a show).
  void _retry(int attempt, VoidCallback loader) {
    if (attempt >= AdConfig.maxLoadAttempts) return;
    Timer(Duration(seconds: 2 << attempt), loader);
  }
}
