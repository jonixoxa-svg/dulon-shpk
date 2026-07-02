import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../orbit_dash_game.dart';

/// A deadly arc segment on the orbit ring. It fades in as a warning, drifts
/// slowly around the ring, then fades out and removes itself.
class Obstacle extends Component with HasGameReference<OrbitDashGame> {
  Obstacle({
    required this.angle,
    required this.arcLength,
    required this.angularSpeed,
  }) : super(priority: 6);

  /// Angular position of the arc's center, in radians.
  double angle;

  /// Total arc length in radians.
  final double arcLength;

  /// Drift speed around the ring, rad/s (either direction).
  final double angularSpeed;

  double _age = 0;
  final double _lifespan = 7 + Random().nextDouble() * 3;
  static const _fadeOut = 0.6;

  static final _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  static final _glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

  /// Opacity ramps 0→1 during the warning window, 1→0 during fade-out.
  double get _opacity {
    if (_age < GameConfig.obstacleWarningSeconds) {
      return _age / GameConfig.obstacleWarningSeconds;
    }
    final remaining = _lifespan - _age;
    if (remaining < _fadeOut) return (remaining / _fadeOut).clamp(0.0, 1.0);
    return 1;
  }

  /// Only a fully materialized arc can kill the player: never during the
  /// warning fade-in and not once it is mostly faded out.
  bool get deadly =>
      _age >= GameConfig.obstacleWarningSeconds && _opacity > 0.35;

  @override
  void update(double dt) {
    _age += dt;
    angle += angularSpeed * dt;
    if (_age >= _lifespan) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromCircle(
        center: game.center.toOffset(), radius: game.orbitRadius);
    final thickness = game.shortestSide * GameConfig.obstacleThicknessFactor;
    final start = angle - arcLength / 2;
    final o = _opacity;

    _glowPaint
      ..strokeWidth = thickness * 1.4
      ..color = GameConfig.obstacleColor.withValues(alpha: 0.5 * o);
    _paint
      ..strokeWidth = thickness
      ..color = GameConfig.obstacleColor.withValues(alpha: o);

    canvas.drawArc(rect, start, arcLength, false, _glowPaint);
    canvas.drawArc(rect, start, arcLength, false, _paint);
  }
}
