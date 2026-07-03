import 'package:flutter/services.dart';

import 'storage_service.dart';

/// Centralized haptics that respect the in-app toggle (which in turn should
/// only ever be ON if the user hasn't disabled system haptics — we can't
/// read that flag on all platforms, so the toggle is the user's control).
/// Every call is best-effort: no-op on web / unsupported devices.
class HapticsService {
  HapticsService._();
  static final HapticsService instance = HapticsService._();

  bool get enabled => StorageService.instance.hapticsOn;

  void _do(void Function() fn) {
    if (!enabled) return;
    try {
      fn();
    } catch (_) {}
  }

  /// Light tick — threading a gap / near-miss.
  void light() => _do(HapticFeedback.selectionClick);

  /// Medium — checkpoint / key / power-up.
  void medium() => _do(HapticFeedback.mediumImpact);

  /// Heavy — death.
  void heavy() => _do(HapticFeedback.heavyImpact);

  /// Success pattern — level complete / new best (double medium).
  void success() {
    if (!enabled) return;
    _do(HapticFeedback.mediumImpact);
    Future.delayed(const Duration(milliseconds: 90),
        () => _do(HapticFeedback.heavyImpact));
  }
}
