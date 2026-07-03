import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../orbit_dash_game.dart';

/// A shockwave ring that expands from the core outward through the orbit.
/// It has one safe gap — the player must be inside the gap when the wave
/// crosses the orbit line.
class PulseRing extends Component with HasGameReference<OrbitDashGame> {
  PulseRing({required this.gapAngle}) : super(priority: 6);

  /// Center angle of the safe gap, in radians.
  final double gapAngle;

  double _age = 0;

  double get _t => (_age / GameConfig.pulseTravelSeconds).clamp(0.0, 1.0);

  /// Current wave radius: eased so it accelerates outward.
  double get radius {
    final eased = Curves.easeIn.transform(_t);
    final coreR = game.shortestSide * 0.05;
    return coreR + (game.orbitRadius * 1.35 - coreR) * eased;
  }

  double get thickness => game.shortestSide * GameConfig.pulseThicknessFactor;

  /// The wave is lethal while its edge overlaps the orbit line.
  bool get atOrbit =>
      (radius - game.orbitRadius).abs() <
      thickness / 2 + game.ball.radius * 0.9;

  bool get deadly => _age > 0.35 && atOrbit;

  /// True if [ballAngle] is inside the safe gap (with a small forgiveness
  /// margin so edge cases favor the player).
  bool isInGap(double ballAngle) {
    final ballHalf = game.ball.radius / game.orbitRadius;
    return angleDistance(ballAngle, gapAngle) <
        GameConfig.pulseGapLength / 2 - ballHalf * 0.3;
  }

  @override
  void update(double dt) {
    _age += dt;
    if (_t >= 1) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final rect =
        Rect.fromCircle(center: game.center.toOffset(), radius: radius);
    // Fade in fast, fade out as it leaves the field.
    final alphaIn = (_age / 0.35).clamp(0.0, 1.0);
    final alphaOut = _t > 0.88 ? (1 - (_t - 0.88) / 0.12) : 1.0;
    final o = alphaIn * alphaOut.clamp(0.0, 1.0);

    final start = gapAngle + GameConfig.pulseGapLength / 2;
    final sweep = 2 * pi - GameConfig.pulseGapLength;

    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = thickness * 1.5
        ..color = GameConfig.pulseColor.withValues(alpha: 0.45 * o)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawArc(
      rect,
      start,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = thickness
        ..color = GameConfig.pulseColor.withValues(alpha: o),
    );
  }
}
