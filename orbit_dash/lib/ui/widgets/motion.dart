import 'package:flutter/material.dart';

/// Choreographed page transition used everywhere: slide up + fade + subtle
/// scale, 260ms, easeOutCubic. Replaces the default MaterialPageRoute so the
/// app feels like one designed product (Pillar A motion spec).
Route<T> slideFadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, animation, secondary) => page,
    transitionsBuilder: (context, anim, secondary, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
              .animate(curved),
          child: ScaleTransition(
            scale: Tween(begin: 0.98, end: 1.0).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}
