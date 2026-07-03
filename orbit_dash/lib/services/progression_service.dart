import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/game_config.dart';
import 'meta_service.dart';

/// Persistent meta-progression: XP, player level, unlockable skins and
/// lifetime stats. Everything stays on-device.
///
/// XP rule: every point scored in a run becomes 1 XP, plus a small bonus
/// per sector reached. Levels follow a gently super-linear curve so early
/// unlocks come fast and later ones feel earned.
class ProgressionService {
  ProgressionService._();

  static final ProgressionService instance = ProgressionService._();

  static const _keyXp = 'meta_xp';
  static const _keySkin = 'meta_skin';
  static const _keyRuns = 'stat_runs';
  static const _keyTotalOrbs = 'stat_total_orbs';
  static const _keyBestCombo = 'stat_best_combo';
  static const _keyBestSector = 'stat_best_sector';

  SharedPreferences? _prefs;

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      _prefs = null;
    }
  }

  // ── XP / level ──────────────────────────────────────────────────────────

  int get xp => _prefs?.getInt(_keyXp) ?? 0;

  /// Total XP required to go from [level] to the next one.
  static int xpForLevel(int level) =>
      (GameConfig.xpBase * pow(level, GameConfig.xpExponent)).round();

  /// Current level, derived from lifetime XP (level 1 at 0 XP).
  int get level {
    var remaining = xp;
    var lvl = 1;
    while (remaining >= xpForLevel(lvl)) {
      remaining -= xpForLevel(lvl);
      lvl++;
    }
    return lvl;
  }

  /// XP earned within the current level (for the progress bar).
  int get xpIntoLevel {
    var remaining = xp;
    var lvl = 1;
    while (remaining >= xpForLevel(lvl)) {
      remaining -= xpForLevel(lvl);
      lvl++;
    }
    return remaining;
  }

  /// XP still needed to level up.
  int get xpForNextLevel => xpForLevel(level);

  /// Adds XP and reports whether one or more level-ups happened.
  bool addXp(int amount) {
    if (amount <= 0) return false;
    final before = level;
    _prefs?.setInt(_keyXp, xp + amount);
    return level > before;
  }

  // ── Skins ───────────────────────────────────────────────────────────────

  int get selectedSkin {
    final i = _prefs?.getInt(_keySkin) ?? 0;
    return i.clamp(0, GameConfig.skins.length - 1);
  }

  set selectedSkin(int index) => _prefs?.setInt(_keySkin, index);

  bool isSkinUnlocked(int index) {
    final skin = GameConfig.skins[index];
    if (skin.product != null) {
      return MetaService.instance.ownsProduct(skin.product!);
    }
    return level >= skin.unlockLevel;
  }

  BallSkin get currentSkin {
    final skin = GameConfig.skins[selectedSkin];
    // Guard against a persisted skin the player no longer qualifies for.
    return isSkinUnlocked(selectedSkin) ? skin : GameConfig.skins.first;
  }

  // ── Lifetime stats ──────────────────────────────────────────────────────

  int get runs => _prefs?.getInt(_keyRuns) ?? 0;
  int get totalOrbs => _prefs?.getInt(_keyTotalOrbs) ?? 0;
  int get bestCombo => _prefs?.getInt(_keyBestCombo) ?? 0;
  int get bestSector => _prefs?.getInt(_keyBestSector) ?? 0;

  /// Records one finished run (the [score] here should already be the XP
  /// amount to award). Set [countRun] to false when the same run already
  /// counted once (rewarded-ad continue). Returns true on level-up.
  bool recordRun({
    required int score,
    required int orbs,
    required int maxCombo,
    required int sector,
    bool countRun = true,
  }) {
    try {
      if (countRun) _prefs?.setInt(_keyRuns, runs + 1);
      _prefs?.setInt(_keyTotalOrbs, totalOrbs + orbs);
      if (maxCombo > bestCombo) _prefs?.setInt(_keyBestCombo, maxCombo);
      if (sector > bestSector) _prefs?.setInt(_keyBestSector, sector);
      return addXp(score);
    } catch (e) {
      debugPrint('recordRun failed: $e');
      return false;
    }
  }
}
