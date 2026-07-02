import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../orbit_dash_game.dart';

/// Subtle radial glow behind the play field so the scene isn't flat black.
class Background extends Component with HasGameReference<OrbitDashGame> {
  Background() : super(priority: -10);

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, game.size.x, game.size.y);
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.1,
        colors: [
          GameConfig.backgroundAccent,
          GameConfig.background,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }
}
