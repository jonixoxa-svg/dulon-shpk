import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../game/orbit_dash_game.dart';
import '../widgets/neon_button.dart';

/// Shown while the run is paused (pause button or app backgrounded).
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.game});

  final OrbitDashGame game;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ColoredBox(
        color: GameConfig.background.withValues(alpha: 0.85),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const Text(
                'PAUSED',
                style: TextStyle(
                  color: GameConfig.textPrimary,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8,
                  shadows: [Shadow(color: GameConfig.ballGlow, blurRadius: 20)],
                ),
              ),
              const SizedBox(height: 8),
              ValueListenableBuilder<int>(
                valueListenable: game.scoreNotifier,
                builder: (context, score, _) => Text(
                  'SCORE $score',
                  style: const TextStyle(
                    color: GameConfig.textSecondary,
                    fontSize: 15,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const Spacer(),
              NeonButton(
                label: 'RESUME',
                icon: Icons.play_arrow_rounded,
                onPressed: game.resumeGame,
              ),
              const SizedBox(height: 16),
              NeonButton(
                label: 'QUIT RUN',
                icon: Icons.flag_outlined,
                compact: true,
                colors: const [
                  GameConfig.backgroundAccent,
                  GameConfig.backgroundAccent,
                ],
                onPressed: game.quitToReady,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
