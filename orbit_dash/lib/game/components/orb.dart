import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../orbit_dash_game.dart';

/// A collectible bonus point sitting on the orbit ring. Worth
/// [GameConfig.orbScore] × combo points. Despawns on its own if not
/// collected. While the magnet power-up is active, nearby orbs slide
/// along the ring toward the player.
class Orb extends PositionComponent with HasGameReference<OrbitDashGame> {
  Orb({required this.orbitAngle}) : super(priority: 5, anchor: Anchor.center);

  /// Angular position on the ring, in radians. Mutable for the magnet pull.
  double orbitAngle;

  bool collected = false;

  double _age = 0;
  static const _lifespan = 6.0;
  static const _fade = 0.5;

  double get radius => game.shortestSide * GameConfig.orbRadiusFactor;

  static final _glowPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
  static final _corePaint = Paint();

  double get _opacity {
    if (_age < _fade) return _age / _fade;
    final remaining = _lifespan - _age;
    if (remaining < _fade) return (remaining / _fade).clamp(0.0, 1.0);
    return 1;
  }

  void collect() {
    collected = true;
    removeFromParent();
  }

  @override
  void update(double dt) {
    _age += dt;

    if (game.magnetActive && game.state == GameState.playing) {
      final delta = shortestAngleDelta(game.ball.orbitAngle, orbitAngle);
      if (delta.abs() < GameConfig.magnetRange) {
        orbitAngle += delta.sign * min(delta.abs(), 2.2 * dt);
      }
    }

    position =
        game.center + Vector2(cos(orbitAngle), sin(orbitAngle)) * game.orbitRadius;
    if (_age >= _lifespan) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final pulse = 0.85 + 0.15 * sin(_age * 5);
    final r = radius * pulse;
    final o = _opacity;

    _glowPaint.color = GameConfig.orbColor.withValues(alpha: 0.6 * o);
    _corePaint.color = GameConfig.orbColor.withValues(alpha: o);
    canvas.drawCircle(Offset.zero, r * 1.6, _glowPaint);
    canvas.drawCircle(Offset.zero, r, _corePaint);
    canvas.drawCircle(Offset(-r * 0.2, -r * 0.2), r * 0.35,
        Paint()..color = Colors.white.withValues(alpha: 0.9 * o));
  }
}
