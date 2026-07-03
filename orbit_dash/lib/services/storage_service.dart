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
  static const _keyVolume = 'volume';
  static const _keyHaptics = 'haptics';
  static const _keyColorblind = 'colorblind';
  static const _keyLeftHand = 'left_hand';
  static const _keyLang = 'language';

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

  /// Effects volume 0..1 (0 also implies muted).
  double get volume => _prefs?.getDouble(_keyVolume) ?? 0.8;
  set volume(double v) => _prefs?.setDouble(_keyVolume, v.clamp(0, 1));

  bool get hapticsOn => _prefs?.getBool(_keyHaptics) ?? true;
  set hapticsOn(bool v) => _prefs?.setBool(_keyHaptics, v);

  /// High-contrast / colorblind-friendly palette (distinct hues by shape).
  bool get colorblind => _prefs?.getBool(_keyColorblind) ?? false;
  set colorblind(bool v) => _prefs?.setBool(_keyColorblind, v);

  /// Left-hand mode mirrors HUD controls (pause button to the right).
  bool get leftHand => _prefs?.getBool(_keyLeftHand) ?? false;
  set leftHand(bool v) => _prefs?.setBool(_keyLeftHand, v);

  /// UI language: 'en' or 'sq' (Albanian).
  String get language => _prefs?.getString(_keyLang) ?? 'en';
  set language(String v) => _prefs?.setString(_keyLang, v);

  int get gameOverCount => _prefs?.getInt(_keyGameOverCount) ?? 0;

  /// Increments and returns the lifetime game-over counter.
  int incrementGameOverCount() {
    final next = gameOverCount + 1;
    _prefs?.setInt(_keyGameOverCount, next);
    return next;
  }
}
