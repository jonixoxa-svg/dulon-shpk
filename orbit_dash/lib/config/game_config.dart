import 'package:flutter/material.dart';

/// All gameplay tuning values and the neon color palette in one place.
class GameConfig {
  GameConfig._();

  // ── Palette ─────────────────────────────────────────────────────────────
  static const Color background = Color(0xFF070B14);
  static const Color backgroundAccent = Color(0xFF101A2E);
  static const Color ballColor = Color(0xFF00E5FF); // neon cyan
  static const Color ballGlow = Color(0xFF00B8D4);
  static const Color obstacleColor = Color(0xFFFF2D78); // neon pink
  static const Color orbColor = Color(0xFFFFD166); // warm gold
  static const Color ringColor = Color(0x22FFFFFF);
  static const Color coreColor = Color(0xFF7C4DFF); // violet core
  static const Color textPrimary = Color(0xFFF4F7FF);
  static const Color textSecondary = Color(0xFF8FA3C8);

  static const Gradient titleGradient = LinearGradient(
    colors: [ballColor, coreColor, obstacleColor],
  );

  // ── Geometry (fractions of the shortest screen side) ────────────────────
  static const double orbitRadiusFactor = 0.34;
  static const double ballRadiusFactor = 0.030;
  static const double orbRadiusFactor = 0.022;
  static const double obstacleThicknessFactor = 0.030;

  // ── Ball movement ───────────────────────────────────────────────────────
  /// Angular speed of the ball in rad/s at the start of a run.
  static const double startAngularSpeed = 1.9;

  /// Angular speed of the ball after [difficultyRampSeconds].
  static const double maxAngularSpeed = 4.2;

  /// Seconds over which speed and spawning ramp from easiest to hardest.
  static const double difficultyRampSeconds = 75;

  // ── Obstacles ───────────────────────────────────────────────────────────
  /// Seconds between obstacle spawns at the start / at max difficulty.
  static const double startSpawnInterval = 2.4;
  static const double minSpawnInterval = 1.05;

  /// Arc length of an obstacle in radians at start / at max difficulty.
  static const double startArcLength = 0.55;
  static const double maxArcLength = 0.85;

  /// Obstacles drift around the ring at up to this speed (rad/s).
  static const double maxObstacleSpeed = 0.55;

  /// Obstacles fade in for this long before they become deadly, so a spawn
  /// can never instantly kill the player.
  static const double obstacleWarningSeconds = 0.9;

  /// Maximum number of live obstacles at max difficulty.
  static const int maxObstacles = 4;

  /// Minimum angular gap (radians) between the ball and a freshly spawned
  /// obstacle, so spawns are always dodgeable.
  static const double spawnSafetyGap = 1.1;

  // ── Orbs ────────────────────────────────────────────────────────────────
  static const double orbSpawnInterval = 3.2;
  static const int orbScore = 5;

  // ── Death / continue ────────────────────────────────────────────────────
  static const double screenShakeDuration = 0.45;
  static const double screenShakeIntensity = 14;

  /// Invincibility after a rewarded-ad continue, so the player is not
  /// instantly killed again.
  static const double continueGraceSeconds = 2.0;
}
