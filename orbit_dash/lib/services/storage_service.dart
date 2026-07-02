import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for everything Orbit Dash
/// persists locally: high score, sound preference and the game-over counter
/// used to pace interstitial ads.
///
/// All values are stored on-device only; nothing here leaves the phone.
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const _keyHighScore = 'high_score';
  static const _keySoundOn = 'sound_on';
  static const _keyGameOverCount = 'game_over_count';

  SharedPreferences? _prefs;

  /// Call once before [runApp]. Failures are swallowed: if the platform
  /// storage is unavailable the game still runs with in-memory defaults.
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (_) {
      _prefs = null;
    }
  }

  int get highScore => _prefs?.getInt(_keyHighScore) ?? 0;

  /// Returns true if [score] is a new high score (and persists it).
  bool submitScore(int score) {
    if (score <= highScore) return false;
    _prefs?.setInt(_keyHighScore, score);
    return true;
  }

  bool get soundOn => _prefs?.getBool(_keySoundOn) ?? true;

  set soundOn(bool value) => _prefs?.setBool(_keySoundOn, value);

  int get gameOverCount => _prefs?.getInt(_keyGameOverCount) ?? 0;

  /// Increments and returns the lifetime game-over counter.
  int incrementGameOverCount() {
    final next = gameOverCount + 1;
    _prefs?.setInt(_keyGameOverCount, next);
    return next;
  }
}
