import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../game/orbit_dash_game.dart';
import '../../services/audio_service.dart';

/// "Tap to start" screen shown before a run while the ball orbits slowly.
/// The hint text ignores taps so they fall through to the GameScreen's
/// GestureDetector, which starts the run; only the back button is tappable.
class ReadyOverlay extends StatelessWidget {
  const ReadyOverlay({super.key, required this.game});

  final OrbitDashGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: BackButton(
                color: GameConfig.textSecondary,
                onPressed: () {
                  AudioService.instance.playButton();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          const IgnorePointer(
            child: Column(
              children: [
                Spacer(flex: 3),
                Text(
                  'TAP TO START',
                  style: TextStyle(
                    color: GameConfig.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'tap anywhere to reverse direction\n'
                  'dodge the pink arcs • grab the gold orbs',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: GameConfig.textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
