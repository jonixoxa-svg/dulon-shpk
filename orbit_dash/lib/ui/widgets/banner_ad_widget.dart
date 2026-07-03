// Platform switch for the banner slot: real AdMob banner on Android/iOS,
// an invisible zero-size widget on web (no AdMob web SDK).
//
// Import THIS file, never the implementations directly.
export 'banner_ad_widget_io.dart'
    if (dart.library.js_interop) 'banner_ad_widget_web.dart';
