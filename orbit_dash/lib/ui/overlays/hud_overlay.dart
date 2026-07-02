import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../game/orbit_dash_game.dart';

/// In-game HUD: just the live score at the top. Ignores all pointer events
/// so taps reach the game. No ads here — ever.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final OrbitDashGame game;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ValueListenableBuilder<int>(
              valueListenable: game.scoreNotifier,
              builder: (context, score, _) => Text(
                '$score',
                style: const TextStyle(
                  color: GameConfig.textPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  shadows: [
                    Shadow(color: GameConfig.ballGlow, blurRadius: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
