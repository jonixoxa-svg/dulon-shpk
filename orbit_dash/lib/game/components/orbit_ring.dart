import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../orbit_dash_game.dart';

/// The faint circle the ball travels on.
class OrbitRing extends Component with HasGameReference<OrbitDashGame> {
  OrbitRing() : super(priority: 0);

  static final _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..color = GameConfig.ringColor;

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(game.center.toOffset(), game.orbitRadius, _paint);
  }
}
