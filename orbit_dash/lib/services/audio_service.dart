import 'package:flame_audio/flame_audio.dart';

import 'storage_service.dart';

/// Plays the game's short placeholder sound effects.
///
/// The .wav files in assets/audio/ are tiny generated placeholder sounds
/// (see tool/generate_sounds.py). Swap them for nicer ones any time —
/// keep the file names and everything keeps working.
///
/// Every call is wrapped in try/catch: audio must never crash or block the
/// game (some devices/emulators have flaky audio backends).
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  static const _tap = 'tap.wav';
  static const _orb = 'orb.wav';
  static const _death = 'death.wav';
  static const _button = 'button.wav';

  bool _loaded = false;

  bool get soundOn => StorageService.instance.soundOn;

  set soundOn(bool value) => StorageService.instance.soundOn = value;

  /// Preloads all effects into memory so playback is instant. Safe to call
  /// more than once; failures are ignored (game works fine without sound).
  Future<void> init() async {
    if (_loaded) return;
    try {
      await FlameAudio.audioCache.loadAll([_tap, _orb, _death, _button]);
      _loaded = true;
    } catch (_) {
      // No audio available — stay silent.
    }
  }

  void playTap() => _play(_tap, volume: 0.55);

  void playOrb() => _play(_orb, volume: 0.8);

  void playDeath() => _play(_death, volume: 0.9);

  void playButton() => _play(_button, volume: 0.5);

  void _play(String file, {double volume = 1.0}) {
    if (!soundOn) return;
    try {
      FlameAudio.play(file, volume: volume);
    } catch (_) {
      // Never let audio break gameplay.
    }
  }
}
