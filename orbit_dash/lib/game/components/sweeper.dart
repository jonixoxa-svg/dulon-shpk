import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../orbit_dash_game.dart';

/// A laser beam radiating from the core that sweeps around the ring.
/// It telegraphs itself as a blinking thin line, then goes hot and rotates
/// for a few seconds. Touching it while hot is death.
class Sweeper extends Component with HasGameReference<OrbitDashGame> {
  Sweeper({required this.angle, required this.direction})
      : super(priority: 7);

  /// Current beam angle in radians.
  double angle;

  /// +1 or -1, rotation direction.
  final int direction;

  double _age = 0;
  static const _fadeOut = 0.4;

  double get _totalLife =>
      GameConfig.sweeperWarnSeconds +
      GameConfig.sweeperActiveSeconds +
      _fadeOut;

  bool get _warning => _age < GameConfig.sweeperWarnSeconds;

  bool get _fading =>
      _age > GameConfig.sweeperWarnSeconds + GameConfig.sweeperActiveSeconds;

  bool get deadly => !_warning && !_fading;

  @override
  void update(double dt) {
    _age += dt;
    if (!_warning) angle += direction * GameConfig.sweeperSpeed * dt;
    if (_age >= _totalLife) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final length = game.orbitRadius * 1.32;
    final thickness = game.shortestSide * 0.018;

    canvas.save();
    canvas.translate(game.center.x, game.center.y);
    canvas.rotate(angle);

    if (_warning) {
      // Blinking warning line where the beam will appear.
      final blink = 0.25 + 0.75 * (sin(_age * 18).abs());
      canvas.drawRect(
        Rect.fromLTWH(0, -1, length, 2),
        Paint()
          ..color =
              GameConfig.sweeperColor.withValues(alpha: 0.55 * blink),
      );
    } else {
      final fade = _fading
          ? 1 -
              ((_age -
                          GameConfig.sweeperWarnSeconds -
                          GameConfig.sweeperActiveSeconds) /
                      _fadeOut)
                  .clamp(0.0, 1.0)
          : 1.0;
      final beam = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -thickness / 2, length, thickness),
        Radius.circular(thickness / 2),
      );
      canvas.drawRRect(
        beam,
        Paint()
          ..color = GameConfig.sweeperColor.withValues(alpha: 0.55 * fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
      canvas.drawRRect(
        beam,
        Paint()
          ..color = GameConfig.sweeperColor.withValues(alpha: fade),
      );
      canvas.drawRect(
        Rect.fromLTWH(0, -thickness * 0.18, length, thickness * 0.36),
        Paint()..color = Colors.white.withValues(alpha: 0.85 * fade),
      );
    }
    canvas.restore();
  }
}
