import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../game/components/power_up.dart';
import '../../game/orbit_dash_game.dart';
import '../../services/audio_service.dart';

/// In-game HUD: live score, combo multiplier, sector badge, active
/// power-up chips and a pause button. No ads here — ever.
class HudOverlay extends StatelessWidget {
  const HudOverlay({super.key, required this.game});

  final OrbitDashGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Pause — the only tappable HUD element.
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                onPressed: () {
                  AudioService.instance.playButton();
                  game.pauseGame();
                },
                icon: const Icon(Icons.pause_rounded,
                    color: GameConfig.textSecondary, size: 30),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // Sector badge.
                ValueListenableBuilder<int>(
                  valueListenable: game.sectorNotifier,
                  builder: (context, sector, _) => Text(
                    'SECTOR $sector',
                    style: const TextStyle(
                      color: GameConfig.textSecondary,
                      fontSize: 12,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                // Score.
                ValueListenableBuilder<int>(
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
                // Combo multiplier (hidden at ×1).
                ValueListenableBuilder<int>(
                  valueListenable: game.comboNotifier,
                  builder: (context, combo, _) => AnimatedScale(
                    scale: combo > 1 ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutBack,
                    child: Text(
                      'COMBO ×$combo',
                      style: TextStyle(
                        color: Color.lerp(GameConfig.orbColor,
                            GameConfig.frenzyColor, (combo - 1) / 4),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        shadows: const [
                          Shadow(color: GameConfig.orbColor, blurRadius: 12),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Active power-up chips.
                ValueListenableBuilder<List<PowerUpType>>(
                  valueListenable: game.effectsNotifier,
                  builder: (context, effects, _) => Wrap(
                    spacing: 6,
                    children: [
                      for (final e in effects)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: e.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: e.color.withValues(alpha: 0.8)),
                          ),
                          child: Text(
                            e.label,
                            style: TextStyle(
                              color: e.color,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
