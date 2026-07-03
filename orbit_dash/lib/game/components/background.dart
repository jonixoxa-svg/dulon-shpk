import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../orbit_dash_game.dart';

class _Star {
  _Star(this.angle, this.radiusFactor, this.depth, this.twinkleSeed);

  double angle; // polar angle around screen center
  final double radiusFactor; // 0..1 of the diagonal
  final double depth; // 0 (far) .. 1 (near) — drives speed, size, alpha
  final double twinkleSeed;
}

class _Nebula {
  _Nebula(this.baseOffset, this.radiusFactor, this.driftSeed);

  final Vector2 baseOffset; // fraction of screen size, relative to center
  final double radiusFactor;
  final double driftSeed;
}

/// Animated deep-space backdrop: a radial base glow, three drifting nebula
/// blobs whose hue shifts as the player advances sectors, and a slowly
/// rotating parallax starfield (three depth layers, farther = slower).
class Background extends Component with HasGameReference<OrbitDashGame> {
  Background() : super(priority: -10);

  static const _starCount = 110;

  final List<_Star> _stars = [];
  final List<_Nebula> _nebulae = [];
  double _t = 0;
  double _hue = 235; // current hue, eased toward the sector target

  @override
  void onLoad() {
    final rng = Random(42);
    for (var i = 0; i < _starCount; i++) {
      _stars.add(_Star(
        rng.nextDouble() * 2 * pi,
        0.08 + rng.nextDouble() * 0.62,
        rng.nextDouble(),
        rng.nextDouble() * 10,
      ));
    }
    _nebulae.addAll([
      _Nebula(Vector2(-0.32, -0.28), 0.34, 0.0),
      _Nebula(Vector2(0.36, 0.10), 0.28, 2.1),
      _Nebula(Vector2(-0.10, 0.42), 0.30, 4.4),
    ]);
  }

  @override
  void update(double dt) {
    _t += dt;
    // Rotate star layers at depth-dependent speeds (parallax).
    for (final s in _stars) {
      s.angle += dt * 0.010 * (0.3 + s.depth);
    }
    // Ease the palette toward the current sector's hue.
    final target = 235 + (game.sector - 1) * 26.0;
    _hue += (target - _hue) * (1 - exp(-dt * 1.2));
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, game.size.x, game.size.y);
    final diag = game.size.length;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment.center,
          radius: 1.1,
          colors: [GameConfig.backgroundAccent, GameConfig.background],
        ).createShader(rect),
    );

    // Nebulae: huge, blurred, barely-there color washes.
    for (final n in _nebulae) {
      final drift = Offset(
        sin(_t * 0.05 + n.driftSeed) * 30,
        cos(_t * 0.04 + n.driftSeed) * 24,
      );
      final c = game.center.toOffset() +
          Offset(n.baseOffset.x * game.size.x, n.baseOffset.y * game.size.y) +
          drift;
      final hue = (_hue + n.driftSeed * 18) % 360;
      final color = HSLColor.fromAHSL(1, hue, 0.65, 0.45).toColor();
      canvas.drawCircle(
        c,
        n.radiusFactor * game.shortestSide,
        Paint()
          ..color = color.withValues(alpha: 0.055)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
      );
    }

    // Stars.
    final paint = Paint();
    for (final s in _stars) {
      final pos = game.center.toOffset() +
          Offset(cos(s.angle), sin(s.angle)) * (s.radiusFactor * diag * 0.5);
      if (!rect.contains(pos)) continue;
      final twinkle = 0.55 + 0.45 * sin(_t * (0.8 + s.depth) + s.twinkleSeed);
      paint.color = Colors.white
          .withValues(alpha: (0.10 + 0.28 * s.depth) * twinkle);
      canvas.drawCircle(pos, 0.6 + 1.5 * s.depth, paint);
    }
  }
}
