import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/meta_config.dart';

/// Versioned, corruption-safe save + the whole engagement economy:
/// coins, daily missions, achievements, capsules, stadium.
///
/// Save design: one JSON blob under [_key] with a `v` schema version.
/// Loading NEVER throws — any parse/shape error falls back to defaults
/// (tested in test/meta_test.dart, including garbage and truncated JSON).
/// Writes are debounce-free and atomic at the prefs layer, so killing the
/// app mid-save leaves either the old or the new blob, never a torn one.
class MetaService extends ChangeNotifier {
  MetaService._();
  static final MetaService instance = MetaService._();

  static const _key = 'meta_save';
  static const _schemaVersion = 1;

  SharedPreferences? _prefs;
  final _rng = Random();

  // ── persisted state ──
  int coins = 0;
  int coinsEarnedLifetime = 0;
  int stadiumLevel = 0;
  int capsulesPending = 0; // earned, not yet opened
  int capsulesOpened = 0;
  Map<String, int> life = {}; // lifetime counters: orbs, nearmiss, runs...
  Map<String, int> best = {}; // best-in-one-run: sector, score, combo
  String missionDate = '';
  List<int> missionIds = [];
  List<int> missionProgress = [0, 0, 0];
  List<bool> missionClaimed = [false, false, false];
  Set<String> unlockedBadges = {}; // "orbs0", "orbs1"... key+tier

  // ── session/run scratch ──
  final Map<String, int> _run = {};
  final List<String> banners = []; // achievement banners for the HUD to drain

  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _load(_prefs?.getString(_key));
    } catch (_) {}
    _rollMissionsIfNeeded();
    if (kIsWeb && Uri.base.queryParameters.containsKey('dev') && coins < 100) {
      coins = 2000; capsulesPending = 5; _save(); // web demo/testing grant
    }
  }

  void _load(String? raw) {
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      // Schema migrations go here as `if ((j['v'] as int? ?? 0) < 2) {...}`.
      coins = j['coins'] as int? ?? 0;
      coinsEarnedLifetime = j['coinsLife'] as int? ?? 0;
      stadiumLevel = j['stadium'] as int? ?? 0;
      capsulesPending = j['capsP'] as int? ?? 0;
      capsulesOpened = j['capsO'] as int? ?? 0;
      life = Map<String, int>.from(j['life'] as Map? ?? {});
      best = Map<String, int>.from(j['best'] as Map? ?? {});
      missionDate = j['mDate'] as String? ?? '';
      missionIds = List<int>.from(j['mIds'] as List? ?? []);
      missionProgress = List<int>.from(j['mProg'] as List? ?? [0, 0, 0]);
      missionClaimed = List<bool>.from(j['mClaim'] as List? ?? [false, false, false]);
      unlockedBadges = Set<String>.from(j['badges'] as List? ?? []);
      if (missionIds.length != 3) missionIds = [];
    } catch (e) {
      debugPrint('Save corrupt, using defaults: $e');
    }
  }

  void _save() {
    try {
      _prefs?.setString(_key, jsonEncode({
        'v': _schemaVersion,
        'coins': coins, 'coinsLife': coinsEarnedLifetime,
        'stadium': stadiumLevel,
        'capsP': capsulesPending, 'capsO': capsulesOpened,
        'life': life, 'best': best,
        'mDate': missionDate, 'mIds': missionIds,
        'mProg': missionProgress, 'mClaim': missionClaimed,
        'badges': unlockedBadges.toList(),
      }));
    } catch (e) {
      debugPrint('Save failed: $e');
    }
    notifyListeners();
  }

  // ── coins ──
  void addCoins(int n) {
    coins += n;
    coinsEarnedLifetime += n;
    _bump('coins', n);
  }

  bool spendCoins(int n) {
    if (coins < n) return false;
    coins -= n;
    _save();
    return true;
  }

  // ── daily missions ──
  static String todayKey([DateTime? d]) {
    final t = d ?? DateTime.now();
    return '${t.year}-${t.month}-${t.day}';
  }

  /// Picks 3 missions seeded by the date: everyone gets the same set, and
  /// the 'runs' family is always included so every day starts with a
  /// mission finishable in under 3 minutes.
  static List<int> pickMissions(String dateKey) {
    var seed = dateKey.hashCode;
    int next(int mod) { seed = (seed * 1103515245 + 12345) & 0x7fffffff; return seed % mod; }
    final quick = [12, 13]; // 'runs' templates
    final ids = <int>{quick[next(quick.length)]};
    while (ids.length < 3) {
      ids.add(next(MetaConfig.missionPool.length));
    }
    return ids.toList();
  }

  void _rollMissionsIfNeeded() {
    final today = todayKey();
    if (missionDate == today && missionIds.length == 3) return;
    missionDate = today;
    missionIds = pickMissions(today);
    missionProgress = [0, 0, 0];
    missionClaimed = [false, false, false];
    _save();
  }

  List<Mission> get todaysMissions {
    _rollMissionsIfNeeded();
    return missionIds.map((i) => MetaConfig.missionPool[i]).toList();
  }

  bool claimMission(int i) {
    final m = todaysMissions[i];
    if (missionClaimed[i] || missionProgress[i] < m.target) return false;
    missionClaimed[i] = true;
    addCoins(m.reward);
    capsulesPending++; // every claimed mission feeds a capsule
    _save();
    return true;
  }

  // ── event hooks (called by the game) ──
  void onOrb() { _bump('orbs', 1); addCoins(MetaConfig.coinPerOrb); }
  void onNearMiss() { _bump('nearmiss', 1); addCoins(MetaConfig.coinPerNearMiss); }
  void onSector(int sector) {
    addCoins(MetaConfig.coinPerSector);
    _bestOf('sector', sector);
    _missionBest('sector', sector);
  }
  void onCombo(int combo) { _bestOf('combo', combo); _missionBest('combo', combo); }
  void onPowerUp() { _bump('powerups', 1); _runBump('powerups', 1); }
  void onRunEnd({required int score}) {
    _bump('runs', 1);
    _bestOf('score', score);
    _missionBest('score', score);
    _missionBest('powerups', _run['powerups'] ?? 0);
    capsulesPending++; // every finished run drops a gift capsule
    _run.clear();
    _save();
  }

  void _runBump(String k, int n) => _run[k] = (_run[k] ?? 0) + n;
  void _bump(String k, int n) {
    life[k] = (life[k] ?? 0) + n;
    _missionAdd(k, n);
    _checkBadges(k, life[k]!);
    _save();
  }
  void _bestOf(String k, int v) {
    if (v > (best[k] ?? 0)) { best[k] = v; _checkBadges(k, v); _save(); }
  }
  void _missionAdd(String kind, int n) {
    final ms = todaysMissions;
    for (var i = 0; i < 3; i++) {
      if (ms[i].kind == kind && !missionClaimed[i]) {
        missionProgress[i] = min(ms[i].target, missionProgress[i] + n);
      }
    }
  }
  void _missionBest(String kind, int v) {
    final ms = todaysMissions;
    for (var i = 0; i < 3; i++) {
      if (ms[i].kind == kind && !missionClaimed[i] && v > missionProgress[i]) {
        missionProgress[i] = min(ms[i].target, v);
      }
    }
  }

  // ── achievements ──
  void _checkBadges(String key, int value) {
    for (final tr in MetaConfig.achievementTracks) {
      if (tr.key != key) continue;
      for (var t = 0; t < 3; t++) {
        final id = '$key$t';
        if (value >= tr.tiers[t] && !unlockedBadges.contains(id)) {
          unlockedBadges.add(id);
          banners.add('${tr.name} ${['BRONZE','SILVER','GOLD'][t]}');
          addCoins(25 * (t + 1));
        }
      }
    }
  }

  int badgeTier(String key) {
    for (var t = 2; t >= 0; t--) {
      if (unlockedBadges.contains('$key$t')) return t + 1;
    }
    return 0;
  }

  // ── capsules (variable reward — earned by play only, never purchased) ──
  CapsuleReward rollCapsule() {
    capsulesPending = max(0, capsulesPending - 1);
    capsulesOpened++;
    _bump('capsules', 1);
    final r = _rng.nextDouble();
    var acc = 0.0;
    var tier = MetaConfig.capsuleTiers.first;
    for (final t in MetaConfig.capsuleTiers) {
      acc += t.weight;
      if (r < acc) { tier = t; break; }
    }
    final c = tier.minCoins +
        (tier.maxCoins > tier.minCoins ? _rng.nextInt(tier.maxCoins - tier.minCoins + 1) : 0);
    addCoins(c);
    _save();
    return CapsuleReward(tier, c);
  }

  // ── stadium ──
  bool buyStadiumUpgrade() {
    if (stadiumLevel >= MetaConfig.stadiumStages.length) return false;
    final cost = MetaConfig.stadiumStages[stadiumLevel].cost;
    if (!spendCoins(cost)) return false;
    stadiumLevel++;
    _bestOf('stadium', stadiumLevel);
    _save();
    return true;
  }

  // ── seasonal event hook (fresh-content structure) ──
  String? get seasonName {
    final m = DateTime.now().month;
    if (m == 12 || m <= 2) return 'WINTER EVENT';
    if (m >= 6 && m <= 8) return 'SUMMER TOURNAMENT';
    return null;
  }
}

class CapsuleReward {
  CapsuleReward(this.tier, this.coins);
  final CapsuleTier tier;
  final int coins;
}
