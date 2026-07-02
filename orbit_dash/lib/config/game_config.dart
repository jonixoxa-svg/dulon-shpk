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
  static const Color hunterColor = Color(0xFFFF6E40); // aggressive orange
  static const Color splitterColor = Color(0xFFD500F9); // purple
  static const Color sweeperColor = Color(0xFFFF1744); // alarm red
  static const Color pulseColor = Color(0xFF00E676); // toxic green
  static const Color orbColor = Color(0xFFFFD166); // warm gold
  static const Color ringColor = Color(0x22FFFFFF);
  static const Color coreColor = Color(0xFF7C4DFF); // violet core
  static const Color shieldColor = Color(0xFF40C4FF);
  static const Color slowmoColor = Color(0xFFB388FF);
  static const Color magnetColor = Color(0xFFFFAB40);
  static const Color frenzyColor = Color(0xFFFF4081);
  static const Color textPrimary = Color(0xFFF4F7FF);
  static const Color textSecondary = Color(0xFF8FA3C8);

  static const Gradient titleGradient = LinearGradient(
    colors: [ballColor, coreColor, obstacleColor],
  );

  // ── Geometry (fractions of the shortest screen side) ────────────────────
  static const double orbitRadiusFactor = 0.34;
  static const double ballRadiusFactor = 0.030;
  static const double orbRadiusFactor = 0.022;
  static const double powerUpRadiusFactor = 0.026;
  static const double obstacleThicknessFactor = 0.030;

  // ── Ball movement ───────────────────────────────────────────────────────
  /// Angular speed of the ball in rad/s at sector 1 / at the speed cap.
  static const double startAngularSpeed = 1.9;
  static const double maxAngularSpeed = 4.4;

  // ── Sectors (difficulty waves) ──────────────────────────────────────────
  /// Seconds each sector lasts before the game escalates.
  static const double sectorDuration = 20;

  /// Ball speed reaches [maxAngularSpeed] at this sector (then stays).
  static const int speedCapSector = 8;

  /// Bonus awarded for surviving into a new sector.
  static const int sectorBonus = 10;

  // ── Obstacles ───────────────────────────────────────────────────────────
  static const double startSpawnInterval = 2.3;
  static const double minSpawnInterval = 0.95;

  static const double startArcLength = 0.55;
  static const double maxArcLength = 0.85;

  /// Passive angular drift of arc obstacles (rad/s).
  static const double maxObstacleSpeed = 0.55;

  /// Hunters accelerate toward the ball up to this angular speed (rad/s).
  static const double hunterMaxSpeed = 0.85;
  static const double hunterAcceleration = 0.55;

  /// Obstacles fade in for this long before they become deadly, so a spawn
  /// can never instantly kill the player.
  static const double obstacleWarningSeconds = 0.9;

  /// Live-arc cap grows from 2 up to this with sectors.
  static const int maxObstacles = 5;

  /// Minimum angular gap (radians) between the ball and a freshly spawned
  /// obstacle, so spawns are always dodgeable.
  static const double spawnSafetyGap = 1.1;

  // ── Sweeper beam ────────────────────────────────────────────────────────
  /// Seconds the beam telegraphs (thin warning line) before becoming deadly.
  static const double sweeperWarnSeconds = 1.2;
  static const double sweeperActiveSeconds = 4.5;
  static const double sweeperSpeed = 1.1; // rad/s
  static const double sweeperHalfWidth = 0.09; // radians, deadly half-angle

  // ── Pulse ring ──────────────────────────────────────────────────────────
  /// Seconds for the ring to expand from the core to beyond the orbit.
  static const double pulseTravelSeconds = 2.6;
  static const double pulseGapLength = 1.5; // radians of safe gap
  static const double pulseThicknessFactor = 0.022;

  // ── Orbs & combo ────────────────────────────────────────────────────────
  static const double orbSpawnInterval = 3.0;
  static const int orbScore = 5;

  /// Combo climbs by 1 per orb up to [comboMax]; decays after
  /// [comboHoldSeconds] without a pickup. Orb points are multiplied by it.
  static const int comboMax = 5;
  static const double comboHoldSeconds = 6.0;

  /// Points for shaving past a deadly arc without dying.
  static const int nearMissScore = 2;
  static const double nearMissWindow = 0.16; // radians beyond the arc edge

  // ── Power-ups ───────────────────────────────────────────────────────────
  static const double powerUpSpawnInterval = 11.0;
  static const double powerUpLifespan = 7.0;
  static const double slowmoDuration = 5.0;
  static const double slowmoScale = 0.62;
  static const double magnetDuration = 8.0;
  static const double magnetRange = 1.6; // radians of attraction
  static const double frenzyDuration = 8.0;

  // ── Death / continue ────────────────────────────────────────────────────
  static const double screenShakeDuration = 0.45;
  static const double screenShakeIntensity = 14;

  /// Slow-motion factor while the death explosion plays.
  static const double deathSlowmo = 0.25;

  /// Invincibility after a rewarded-ad continue.
  static const double continueGraceSeconds = 2.0;

  // ── Progression / meta ──────────────────────────────────────────────────
  /// XP needed to reach level n+1 is `xpBase * n^xpExponent` (rounded).
  static const int xpBase = 150;
  static const double xpExponent = 1.35;

  /// Unlockable ball skins: name, core color, glow color, unlock level.
  static const List<BallSkin> skins = [
    BallSkin('CYAN', Color(0xFF00E5FF), Color(0xFF00B8D4), 1),
    BallSkin('EMBER', Color(0xFFFF9E40), Color(0xFFFF3D00), 2),
    BallSkin('VENOM', Color(0xFF76FF03), Color(0xFF1FA512), 3),
    BallSkin('NOVA', Color(0xFFFFF176), Color(0xFFFFB300), 5),
    BallSkin('GHOST', Color(0xFFE0F7FF), Color(0xFF80DEEA), 7),
    BallSkin('VOID', Color(0xFFB388FF), Color(0xFF6200EA), 10),
  ];
}

class BallSkin {
  const BallSkin(this.name, this.core, this.glow, this.unlockLevel);

  final String name;
  final Color core;
  final Color glow;
  final int unlockLevel;
}
