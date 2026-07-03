import 'package:flutter/foundation.dart';

import '../meta_service.dart';
import 'iap_service.dart';

/// Web-demo stand-in: no store. With ?dev in the URL, purchases are
/// simulated locally so the full flow can be exercised in the browser.
class IapService extends ChangeNotifier {
  IapService._();
  static final IapService instance = IapService._();

  bool available = false;
  bool get _devMode => Uri.base.queryParameters.containsKey('dev');

  bool get removeAdsOwned =>
      MetaService.instance.ownsProduct(IapCatalog.removeAds);
  bool ownsProduct(String id) => MetaService.instance.ownsProduct(id);
  String priceOf(String id) => IapCatalog.fallbackPrices[id] ?? '—';

  Future<void> init() async {}

  Future<bool> buy(String id) async {
    if (!_devMode) return false;
    MetaService.instance.grantProduct(id);
    if (id == 'bundle_cosmic') {
      for (final s in ['skin_galaxy', 'skin_supernova', 'skin_icecomet']) {
        MetaService.instance.grantProduct(s);
      }
    }
    notifyListeners();
    return true;
  }

  Future<void> restore() async {}
}
