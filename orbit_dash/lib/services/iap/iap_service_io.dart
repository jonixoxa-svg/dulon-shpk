import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../meta_service.dart';
import 'iap_service.dart';

/// Google Play Billing implementation.
///
/// Flow: init() connects and queries products; buy() launches the system
/// purchase sheet (which shows Google's parental-control dialog on child
/// accounts — that's what makes direct IAP Families-safe); the purchase
/// stream delivers updates which we complete/acknowledge and persist.
/// restore() re-queries owned products — purchases survive reinstall.
///
/// In debug builds [debugFakePurchases] short-circuits the store so the
/// whole flow (buy → owned → perks → restore) is testable without Play.
class IapService extends ChangeNotifier {
  IapService._();
  static final IapService instance = IapService._();

  static const bool debugFakePurchases = kDebugMode;

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  final Map<String, ProductDetails> _products = {};
  bool available = false;

  bool get removeAdsOwned => MetaService.instance.ownsProduct(IapCatalog.removeAds);
  bool ownsProduct(String id) => MetaService.instance.ownsProduct(id);

  String priceOf(String id) =>
      _products[id]?.price ?? IapCatalog.fallbackPrices[id] ?? '—';

  Future<void> init() async {
    try {
      available = await _iap.isAvailable();
      if (!available && !debugFakePurchases) return;
      _sub ??= _iap.purchaseStream.listen(_onPurchases, onError: (e) {
        debugPrint('IAP stream error: $e');
      });
      if (available) {
        final resp =
            await _iap.queryProductDetails(IapCatalog.all.toSet());
        for (final p in resp.productDetails) {
          _products[p.id] = p;
        }
        // Restore on every launch so a reinstall gets its purchases back.
        await _iap.restorePurchases();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('IAP init failed: $e');
    }
  }

  void _onPurchases(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          // NOTE: for a server-backed game verify p.verificationData here.
          _grant(p.productID);
          if (p.pendingCompletePurchase) _iap.completePurchase(p);
        case PurchaseStatus.pending:
          break; // Play shows its own pending UI (e.g. cash payment)
        case PurchaseStatus.error:
          debugPrint('IAP error: ${p.error}');
        case PurchaseStatus.canceled:
          break;
      }
    }
    notifyListeners();
  }

  void _grant(String id) {
    MetaService.instance.grantProduct(id);
    if (id == 'bundle_cosmic') {
      MetaService.instance.grantProduct('skin_galaxy');
      MetaService.instance.grantProduct('skin_supernova');
      MetaService.instance.grantProduct('skin_icecomet');
    }
  }

  Future<bool> buy(String id) async {
    if (ownsProduct(id)) return true;
    if (debugFakePurchases && !available) {
      _grant(id); // debug-only fake flow for testing without Play
      notifyListeners();
      return true;
    }
    final details = _products[id];
    if (details == null) return false;
    try {
      return await _iap.buyNonConsumable(
          purchaseParam: PurchaseParam(productDetails: details));
    } catch (e) {
      debugPrint('IAP buy failed: $e');
      return false;
    }
  }

  Future<void> restore() async {
    try {
      if (available) await _iap.restorePurchases();
    } catch (e) {
      debugPrint('IAP restore failed: $e');
    }
  }
}
