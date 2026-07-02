import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../game/orbit_dash_game.dart';
import '../overlays/game_over_overlay.dart';
import '../overlays/hud_overlay.dart';
import '../overlays/ready_overlay.dart';

/// Hosts the Flame game plus its Flutter overlays. A full-screen
/// GestureDetector feeds taps into the game so input works regardless of
/// which overlay is visible.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final OrbitDashGame _game;

  @override
  void initState() {
    super.initState();
    _game = OrbitDashGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConfig.background,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _game.handleTap(),
        child: GameWidget(
          game: _game,
          overlayBuilderMap: {
            GameOverlays.ready: (context, OrbitDashGame game) =>
                ReadyOverlay(game: game),
            GameOverlays.hud: (context, OrbitDashGame game) =>
                HudOverlay(game: game),
            GameOverlays.gameOver: (context, OrbitDashGame game) =>
                GameOverOverlay(game: game),
          },
        ),
      ),
    );
  }
}
