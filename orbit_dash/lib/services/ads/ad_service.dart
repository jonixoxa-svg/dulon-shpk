// Platform switch for the ads layer.
//
// On Android/iOS this exports the real AdMob implementation; when compiled
// for the web (used only for the hosted gameplay demo) it exports a no-op
// stub, because the google_mobile_ads plugin does not support web.
//
// Everything outside this folder imports THIS file, never the
// implementations directly.
export 'ad_service_io.dart' if (dart.library.js_interop) 'ad_service_web.dart';
