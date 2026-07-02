import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../orbit_dash_game.dart';

/// Softly pulsing glowing dot at the orbit center. It reacts to the combo:
/// higher combo = faster, bigger, warmer pulse.
class CenterCore extends Component with HasGameReference<OrbitDashGame> {
  CenterCore() : super(priority: 1);

  double _t = 0;

  static final _glowPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
  static final _corePaint = Paint();

  @override
  void update(double dt) => _t += dt;

  @override
  void render(Canvas canvas) {
    final combo = game.combo;
    final excitement = (combo - 1) / (GameConfig.comboMax - 1);
    final pulse = 0.85 + (0.15 + 0.10 * excitement) * sin(_t * (2.4 + 2.2 * excitement));
    final r = game.shortestSide * (0.045 + 0.008 * excitement) * pulse;
    final c = game.center.toOffset();

    final color = Color.lerp(
        GameConfig.coreColor, GameConfig.frenzyColor, excitement * 0.6)!;

    _glowPaint.color = color.withValues(alpha: 0.55);
    _corePaint.color = color;
    canvas.drawCircle(c, r * 1.6, _glowPaint);
    canvas.drawCircle(c, r, _corePaint);
    canvas.drawCircle(
        c, r * 0.45, Paint()..color = Colors.white.withValues(alpha: 0.9));
  }
}
