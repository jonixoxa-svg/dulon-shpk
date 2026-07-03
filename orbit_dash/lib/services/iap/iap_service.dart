// Platform switch for in-app purchases: Google Play Billing on Android
// (via the in_app_purchase plugin), a no-op stub on web where the demo
// runs. Import THIS file, never the implementations directly.
export 'iap_service_io.dart' if (dart.library.js_interop) 'iap_service_web.dart';

/// Product catalog — keep IDs in sync with Play Console → Monetize →
/// Products → In-app products. All are NON-CONSUMABLE (one-time),
/// fixed-price, fully transparent: you see exactly what you buy.
/// NO randomized paid content, NO currency packs (Families-safe).
///
/// TODO(you): create these products in Play Console with these exact IDs:
///   remove_ads        $3.99  — removes all interstitials permanently
///   skin_galaxy       $0.99
///   skin_supernova    $1.99
///   skin_trophy       $1.99
///   skin_diamond      $2.99
///   skin_watermelon   $0.99
///   bundle_cosmic     $4.99  — galaxy + supernova + ice comet
class IapCatalog {
  static const removeAds = 'remove_ads';
  static const skinProducts = [
    'skin_galaxy',
    'skin_supernova',
    'skin_trophy',
    'skin_diamond',
    'skin_watermelon',
    'bundle_cosmic',
  ];
  static const all = [removeAds, ...skinProducts];

  /// Fallback display prices for when the store can't be reached
  /// (the real localized price always comes from Play Billing).
  static const fallbackPrices = {
    removeAds: r'$3.99',
    'skin_galaxy': r'$0.99',
    'skin_supernova': r'$1.99',
    'skin_trophy': r'$1.99',
    'skin_diamond': r'$2.99',
    'skin_watermelon': r'$0.99',
    'bundle_cosmic': r'$4.99',
  };
}
