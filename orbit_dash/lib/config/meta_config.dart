import 'package:flutter/material.dart';

/// Data tables for the engagement layer: capsules, missions, achievements,
/// stadium. Everything here is earned BY PLAY ONLY — no purchases, no
/// dark patterns (Google Play Families hard requirement).
class MetaConfig {
  MetaConfig._();

  // ── Gift capsules (variable reward — earned, never bought) ─────────────
  // rarity roll: cumulative weights.
  static const capsuleTiers = [
    CapsuleTier('COMMON', 0.60, Color(0xFF9AA6B8), 10, 25),
    CapsuleTier('RARE', 0.25, Color(0xFF41A7FF), 30, 60),
    CapsuleTier('EPIC', 0.12, Color(0xFFB35CFF), 80, 150),
    CapsuleTier('LEGENDARY', 0.03, Color(0xFFFFC93C), 300, 300),
  ];

  // ── Stadium meta-progression (visible from the menu) ───────────────────
  static const stadiumStages = [
    StadiumStage('Pitch lines', 50),
    StadiumStage('Goal posts', 80),
    StadiumStage('Floodlight west', 120),
    StadiumStage('Floodlight east', 170),
    StadiumStage('South stand', 230),
    StadiumStage('North stand', 300),
    StadiumStage('Scoreboard', 380),
    StadiumStage('East stand', 470),
    StadiumStage('West stand', 570),
    StadiumStage('Cheering fans', 680),
    StadiumStage('Stadium roof', 800),
    StadiumStage('Victory flags', 950),
    StadiumStage('Big screen', 1120),
    StadiumStage('Night lights', 1300),
    StadiumStage('Fireworks!', 1500),
  ];

  // ── Daily missions (3 per day, seeded by date) ──────────────────────────
  // Every template is completable through normal play; the 'runs' family
  // guarantees at least one mission finishable in under 3 minutes.
  static const missionPool = [
    Mission('orbs', 5, 'Collect 5 orbs', 15),
    Mission('orbs', 15, 'Collect 15 orbs', 30),
    Mission('orbs', 30, 'Collect 30 orbs', 50),
    Mission('sector', 2, 'Reach sector 2', 15),
    Mission('sector', 3, 'Reach sector 3', 30),
    Mission('sector', 5, 'Reach sector 5', 60),
    Mission('score', 50, 'Score 50 in one run', 20),
    Mission('score', 150, 'Score 150 in one run', 45),
    Mission('nearmiss', 5, 'Survive 5 near-misses', 15),
    Mission('nearmiss', 20, 'Survive 20 near-misses', 40),
    Mission('combo', 5, 'Hit combo ×5', 35),
    Mission('powerups', 2, 'Grab 2 power-ups in one run', 25),
    Mission('runs', 1, 'Play a run', 10),
    Mission('runs', 3, 'Play 3 runs', 25),
    Mission('coins', 50, 'Earn 50 coins', 30),
  ];

  // ── Achievements: 10 tracks × bronze/silver/gold ────────────────────────
  static const achievementTracks = [
    Track('orbs', 'Orb Collector', [50, 500, 5000]),
    Track('nearmiss', 'Daredevil', [25, 250, 2500]),
    Track('sector', 'Explorer', [3, 6, 10]),
    Track('score', 'High Scorer', [100, 300, 800]),
    Track('runs', 'Regular', [10, 100, 1000]),
    Track('coins', 'Tycoon', [100, 1000, 10000]),
    Track('capsules', 'Gift Hunter', [5, 25, 100]),
    Track('stadium', 'Architect', [5, 10, 15]),
    Track('combo', 'Combo Master', [3, 4, 5]),
    Track('powerups', 'Collector', [10, 100, 500]),
  ];

  // Micro-reward economy: coins per event (frequent, small — the player
  // should get positive feedback every few seconds).
  static const int coinPerOrb = 1;
  static const int coinPerSector = 5;
  static const int coinPerNearMiss = 1;

  // Interstitial pacing (Families-friendly): at most one per N game overs,
  // hard session cap, and NEVER after a new-best celebration.
  static const int interstitialEveryNGameOvers = 4;
  static const int interstitialSessionCap = 3;
}

class CapsuleTier {
  const CapsuleTier(this.name, this.weight, this.color, this.minCoins, this.maxCoins);
  final String name;
  final double weight;
  final Color color;
  final int minCoins, maxCoins;
}

class StadiumStage {
  const StadiumStage(this.name, this.cost);
  final String name;
  final int cost;
}

class Mission {
  const Mission(this.kind, this.target, this.label, this.reward);
  final String kind; // matches a counter key
  final int target;
  final String label;
  final int reward; // coins
}

class Track {
  const Track(this.key, this.name, this.tiers);
  final String key;
  final String name;
  final List<int> tiers; // bronze / silver / gold thresholds
}
