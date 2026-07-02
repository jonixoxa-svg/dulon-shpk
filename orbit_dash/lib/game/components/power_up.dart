import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../orbit_dash_game.dart';

enum PowerUpType { shield, slowmo, magnet, frenzy }

extension PowerUpTypeX on PowerUpType {
  Color get color => switch (this) {
        PowerUpType.shield => GameConfig.shieldColor,
        PowerUpType.slowmo => GameConfig.slowmoColor,
        PowerUpType.magnet => GameConfig.magnetColor,
        PowerUpType.frenzy => GameConfig.frenzyColor,
      };

  String get label => switch (this) {
        PowerUpType.shield => 'SHIELD',
        PowerUpType.slowmo => 'SLOW-MO',
        PowerUpType.magnet => 'MAGNET',
        PowerUpType.frenzy => 'FRENZY ×2',
      };
}

/// A pickup sitting on the orbit ring: a glowing hexagon with a pictogram.
/// Collecting it triggers [OrbitDashGame.applyPowerUp].
class PowerUp extends PositionComponent with HasGameReference<OrbitDashGame> {
  PowerUp({required this.orbitAngle, required this.type})
      : super(priority: 5, anchor: Anchor.center);

  final double orbitAngle;
  final PowerUpType type;

  bool collected = false;

  double _age = 0;
  static const _fade = 0.4;

  double get radius => game.shortestSide * GameConfig.powerUpRadiusFactor;

  double get _opacity {
    if (_age < _fade) return _age / _fade;
    final remaining = GameConfig.powerUpLifespan - _age;
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
    position =
        game.center + Vector2(cos(orbitAngle), sin(orbitAngle)) * game.orbitRadius;
    if (_age >= GameConfig.powerUpLifespan) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final o = _opacity;
    final pulse = 1.0 + 0.10 * sin(_age * 4);
    final r = radius * pulse;
    final c = type.color;

    // Hexagon body with glow.
    final hex = Path();
    for (var i = 0; i < 6; i++) {
      final a = -pi / 2 + i * pi / 3 + _age * 0.6; // slow spin
      final p = Offset(cos(a), sin(a)) * r;
      i == 0 ? hex.moveTo(p.dx, p.dy) : hex.lineTo(p.dx, p.dy);
    }
    hex.close();

    canvas.drawPath(
      hex,
      Paint()
        ..color = c.withValues(alpha: 0.55 * o)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    canvas.drawPath(hex, Paint()..color = c.withValues(alpha: 0.28 * o));
    canvas.drawPath(
      hex,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = c.withValues(alpha: o),
    );

    _drawGlyph(canvas, r * 0.52, Colors.white.withValues(alpha: 0.95 * o));
  }

  void _drawGlyph(Canvas canvas, double s, Color color) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = color;

    switch (type) {
      case PowerUpType.shield:
        // Simple shield outline.
        final path = Path()
          ..moveTo(-s, -s * 0.7)
          ..lineTo(s, -s * 0.7)
          ..lineTo(s, s * 0.2)
          ..quadraticBezierTo(s, s * 0.85, 0, s * 1.1)
          ..quadraticBezierTo(-s, s * 0.85, -s, s * 0.2)
          ..close();
        canvas.drawPath(path, stroke);
      case PowerUpType.slowmo:
        // Clock: circle + hands.
        canvas.drawCircle(Offset.zero, s, stroke);
        canvas.drawLine(Offset.zero, Offset(0, -s * 0.65), stroke);
        canvas.drawLine(Offset.zero, Offset(s * 0.5, s * 0.2), stroke);
      case PowerUpType.magnet:
        // Horseshoe magnet.
        final rect = Rect.fromCircle(center: Offset(0, -s * 0.15), radius: s);
        canvas.drawArc(rect, pi, pi, false, stroke);
        canvas.drawLine(
            Offset(-s, -s * 0.15), Offset(-s, s * 0.7), stroke);
        canvas.drawLine(Offset(s, -s * 0.15), Offset(s, s * 0.7), stroke);
      case PowerUpType.frenzy:
        // Lightning bolt.
        final bolt = Path()
          ..moveTo(s * 0.35, -s)
          ..lineTo(-s * 0.45, s * 0.15)
          ..lineTo(0, s * 0.15)
          ..lineTo(-s * 0.35, s)
          ..lineTo(s * 0.45, -s * 0.15)
          ..lineTo(0, -s * 0.15)
          ..close();
        canvas.drawPath(bolt, Paint()..color = color);
    }
  }
}
