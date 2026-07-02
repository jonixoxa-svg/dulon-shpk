/// Central place for every AdMob ID used by the app.
///
/// The IDs below are Google's OFFICIAL TEST IDs. They always serve test ads
/// and are safe to click. The app works and can be fully tested with them.
///
/// ─────────────────────────────────────────────────────────────────────────
/// TODO(you): BEFORE RELEASING TO GOOGLE PLAY
///
/// 1. Create an AdMob account at https://admob.google.com
/// 2. Add a new Android app ("Orbit Dash") and copy its App ID.
/// 3. Create three ad units for that app:
///      - Banner        → paste its ID into [bannerAdUnitId]
///      - Interstitial  → paste its ID into [interstitialAdUnitId]
///      - Rewarded      → paste its ID into [rewardedAdUnitId]
/// 4. Replace the App ID in TWO places:
///      - [appId] below (documentation only)
///      - android/app/src/main/AndroidManifest.xml
///        (the com.google.android.gms.ads.APPLICATION_ID meta-data tag)
///
/// NEVER ship with test IDs (no revenue) and NEVER click your own real ads
/// (account ban). See README.md → "Set up AdMob" for the full walkthrough.
/// ─────────────────────────────────────────────────────────────────────────
class AdConfig {
  AdConfig._();

  /// AdMob App ID (test). Also referenced in AndroidManifest.xml.
  /// TODO(you): replace with your real App ID, e.g. ca-app-pub-XXXX~YYYY
  static const String appId = 'ca-app-pub-3940256099942544~3347511713';

  /// Banner: shown at the bottom of the main menu and the game-over screen
  /// only. Never shown during gameplay.
  /// TODO(you): replace with your real banner ad unit ID.
  static const String bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  /// Interstitial: shown after every [interstitialFrequency]-th game over.
  /// TODO(you): replace with your real interstitial ad unit ID.
  static const String interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

  /// Rewarded: "continue after death" and "double your score".
  /// TODO(you): replace with your real rewarded ad unit ID.
  static const String rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  /// Show an interstitial after every N-th game over. Keep this at 3 or
  /// higher: more frequent full-screen ads hurt retention and can violate
  /// Google Play / AdMob policy on intrusive ads.
  static const int interstitialFrequency = 3;

  /// How many times a failed ad load is retried (with exponential backoff).
  static const int maxLoadAttempts = 3;
}
