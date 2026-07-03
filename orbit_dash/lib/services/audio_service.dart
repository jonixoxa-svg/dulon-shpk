import 'package:flame_audio/flame_audio.dart';

import 'storage_service.dart';

/// Plays the game's short synthesized sound effects.
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

  static const _files = [
    'tap.wav',
    'orb1.wav',
    'orb2.wav',
    'orb3.wav',
    'orb4.wav',
    'orb5.wav',
    'whoosh.wav',
    'powerup.wav',
    'shield_break.wav',
    'sector.wav',
    'levelup.wav',
    'death.wav',
    'button.wav',
  ];

  bool _loaded = false;

  bool get soundOn => StorageService.instance.soundOn;

  set soundOn(bool value) => StorageService.instance.soundOn = value;

  /// Preloads all effects into memory so playback is instant. Safe to call
  /// more than once; failures are ignored (game works fine without sound).
  Future<void> init() async {
    if (_loaded) return;
    try {
      await FlameAudio.audioCache.loadAll(_files);
      _loaded = true;
    } catch (_) {
      // No audio available — stay silent.
    }
  }

  void playTap() => _play('tap.wav', volume: 0.55);

  /// Pitch rises with the combo level (1..5) for that slot-machine feel.
  void playOrb(int combo) =>
      _play('orb${combo.clamp(1, 5)}.wav', volume: 0.8);

  void playNearMiss() => _play('whoosh.wav', volume: 0.5);

  void playPowerUp() => _play('powerup.wav', volume: 0.75);

  void playShieldBreak() => _play('shield_break.wav', volume: 0.85);

  void playSector() => _play('sector.wav', volume: 0.7);

  void playLevelUp() => _play('levelup.wav', volume: 0.8);

  void playDeath() => _play('death.wav', volume: 0.9);

  void playButton() => _play('button.wav', volume: 0.5);

  void _play(String file, {double volume = 1.0}) {
    if (!soundOn) return;
    // Scale each effect by the user's master effects volume.
    final master = StorageService.instance.volume;
    if (master <= 0) return;
    try {
      FlameAudio.play(file, volume: volume * master);
    } catch (_) {
      // Never let audio break gameplay.
    }
  }
}
