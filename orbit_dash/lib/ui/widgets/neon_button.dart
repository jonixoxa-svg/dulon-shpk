import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../services/audio_service.dart';

/// Rounded gradient button with a soft glow — the game's main button style.
class NeonButton extends StatelessWidget {
  const NeonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.colors = const [GameConfig.ballColor, GameConfig.coreColor],
    this.enabled = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final List<Color> colors;
  final bool enabled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: enabled
          ? colors
          : colors.map((c) => c.withValues(alpha: 0.25)).toList(),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: colors.first.withValues(alpha: 0.45),
                  blurRadius: 18,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: enabled
              ? () {
                  AudioService.instance.playButton();
                  onPressed();
                }
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 20 : 36,
              vertical: compact ? 10 : 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: compact ? 18 : 24),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 14 : 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
