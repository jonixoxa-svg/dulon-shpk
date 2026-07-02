import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/game_config.dart';
import '../services/audio_service.dart';
import '../services/progression_service.dart';
import '../services/storage_service.dart';
import 'components/background.dart';
import 'components/center_core.dart';
import 'components/obstacle.dart';
import 'components/orb.dart';
import 'components/orbit_ring.dart';
import 'components/player_ball.dart';
import 'components/power_up.dart';
import 'components/pulse_ring.dart';
import 'components/score_popup.dart';
import 'components/sweeper.dart';

/// Overlay ids used by the Flutter layer.
class GameOverlays {
  static const ready = 'ready';
  static const hud = 'hud';
  static const paused = 'paused';
  static const gameOver = 'gameOver';
}

enum GameState { ready, playing, paused, dying, gameOver }

/// The core game.
///
/// One-tap rules: the ball orbits a center point and tapping reverses its
/// direction. Everything else is built on that single verb:
///  * arc obstacles (drifters, hunters, splitters) live on the ring
///  * a sweeper beam and pulse shockwaves attack from the core
///  * orbs build a combo multiplier, power-ups bend the rules
///  * survival is paced in 20-second "sectors" that keep escalating
class OrbitDashGame extends FlameGame with HasTimeScale {
  final _rng = Random();

  GameState state = GameState.ready;

  // ── HUD bindings ─────────────────────────────────────────────────────────
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);
  final ValueNotifier<int> comboNotifier = ValueNotifier(1);
  final ValueNotifier<int> sectorNotifier = ValueNotifier(1);
  final ValueNotifier<List<PowerUpType>> effectsNotifier = ValueNotifier([]);

  late PlayerBall ball;

  Vector2 center = Vector2.zero();
  double orbitRadius = 0;
  double shortestSide = 0;

  // ── Run state ────────────────────────────────────────────────────────────
  double _elapsed = 0;
  double _scoreF = 0; // fractional score accumulator
  int _orbsCollected = 0;
  int _maxCombo = 1;
  int combo = 1;
  double _comboTimer = 0;

  double _arcTimer = 0;
  double _orbTimer = 0;
  double _powerUpTimer = 0;
  double _sweeperTimer = 0;
  double _pulseTimer = 0;

  double _shakeTime = 0;
  double _shakeStrength = GameConfig.screenShakeIntensity;
  double _flashTime = 0;
  double _graceTime = 0;

  // Active power-up effects.
  bool hasShield = false;
  final Map<PowerUpType, double> _effectTimers = {};

  // ── End-of-run results (read by the game-over overlay) ──────────────────
  int finalScore = 0;
  bool isNewBest = false;
  bool continueUsed = false;
  int xpGained = 0;
  bool leveledUp = false;
  int orbsThisRun = 0;
  int maxComboThisRun = 1;
  int sectorReached = 1;

  // XP double-count guard when a run is continued via rewarded ad.
  int _recordedScore = 0;
  int _recordedOrbs = 0;

  // ── Derived values ───────────────────────────────────────────────────────
  int get sector => (_elapsed / GameConfig.sectorDuration).floor() + 1;

  /// 0 → sector 1, 1 → speed-cap sector; drives speed and spawn pressure.
  double get difficulty => (_elapsed /
          (GameConfig.sectorDuration * (GameConfig.speedCapSector - 1)))
      .clamp(0.0, 1.0);

  double get currentSpeed =>
      GameConfig.startAngularSpeed +
      (GameConfig.maxAngularSpeed - GameConfig.startAngularSpeed) * difficulty;

  int get score => _scoreF.floor();

  bool get isInvincible => _graceTime > 0;

  bool get magnetActive => _effectTimers.containsKey(PowerUpType.magnet);

  bool get frenzyActive => _effectTimers.containsKey(PowerUpType.frenzy);

  int get _scoreMultiplier => frenzyActive ? 2 : 1;

  @override
  Color backgroundColor() => GameConfig.background;

  @override
  Future<void> onLoad() async {
    _updateGeometry(size);
    addAll([
      Background(),
      OrbitRing(),
      CenterCore(),
      ball = PlayerBall(),
    ]);
    overlays.add(GameOverlays.ready);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _updateGeometry(size);
  }

  void _updateGeometry(Vector2 size) {
    center = size / 2;
    shortestSide = min(size.x, size.y);
    orbitRadius = shortestSide * GameConfig.orbitRadiusFactor;
  }

  // ── Input ────────────────────────────────────────────────────────────────

  /// Single entry point for taps, wired up by the GameScreen widget.
  void handleTap() {
    switch (state) {
      case GameState.ready:
        _startRun();
      case GameState.playing:
        ball.reverse();
        AudioService.instance.playTap();
        _haptic(HapticFeedback.selectionClick);
      case GameState.paused:
      case GameState.dying:
      case GameState.gameOver:
        break; // Buttons on the overlays handle these states.
    }
  }

  // ── Run lifecycle ────────────────────────────────────────────────────────

  void _startRun() {
    state = GameState.playing;
    timeScale = 1.0;
    _elapsed = 0;
    _scoreF = 0;
    _orbsCollected = 0;
    combo = 1;
    _maxCombo = 1;
    _comboTimer = 0;
    _arcTimer = 0;
    _orbTimer = 0;
    _powerUpTimer = 0;
    _sweeperTimer = 0;
    _pulseTimer = 0;
    _graceTime = 0;
    hasShield = false;
    _effectTimers.clear();
    finalScore = 0;
    isNewBest = false;
    continueUsed = false;
    xpGained = 0;
    leveledUp = false;
    _recordedScore = 0;
    _recordedOrbs = 0;
    scoreNotifier.value = 0;
    comboNotifier.value = 1;
    sectorNotifier.value = 1;
    _refreshEffects();
    ball.reset();
    _clearHazards(clearPickups: true);
    overlays.remove(GameOverlays.ready);
    overlays.add(GameOverlays.hud);
  }

  /// Back to the "tap to start" state (used by Retry).
  void resetToReady() {
    state = GameState.ready;
    timeScale = 1.0;
    hasShield = false;
    _effectTimers.clear();
    _refreshEffects();
    ball.reset();
    _clearHazards(clearPickups: true);
    overlays.remove(GameOverlays.gameOver);
    overlays.add(GameOverlays.ready);
  }

  void _clearHazards({bool clearPickups = false}) {
    for (final c in children
        .where((c) => c is ArcObstacle || c is Sweeper || c is PulseRing)
        .toList()) {
      c.removeFromParent();
    }
    if (clearPickups) {
      for (final c in children
          .where((c) => c is Orb || c is PowerUp || c is ScorePopup)
          .toList()) {
        c.removeFromParent();
      }
    }
  }

  // ── Pause ────────────────────────────────────────────────────────────────

  void pauseGame() {
    if (state != GameState.playing) return;
    state = GameState.paused;
    overlays.remove(GameOverlays.hud);
    overlays.add(GameOverlays.paused);
    pauseEngine();
  }

  void resumeGame() {
    if (state != GameState.paused) return;
    overlays.remove(GameOverlays.paused);
    overlays.add(GameOverlays.hud);
    state = GameState.playing;
    resumeEngine();
  }

  /// Leave a paused run and go back to the ready screen.
  void quitToReady() {
    if (state != GameState.paused) return;
    resumeEngine();
    state = GameState.ready;
    timeScale = 1.0;
    hasShield = false;
    _effectTimers.clear();
    _refreshEffects();
    ball.reset();
    _clearHazards(clearPickups: true);
    overlays.remove(GameOverlays.paused);
    overlays.add(GameOverlays.ready);
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    super.lifecycleStateChange(state);
    // Auto-pause a live run when the app is backgrounded.
    if (state != AppLifecycleState.resumed) pauseGame();
  }

  // ── Death / continue ─────────────────────────────────────────────────────

  void die() {
    if (state != GameState.playing) return;

    if (hasShield) {
      _consumeShield();
      return;
    }

    state = GameState.dying;
    timeScale = GameConfig.deathSlowmo;
    finalScore = score;
    orbsThisRun = _orbsCollected;
    maxComboThisRun = _maxCombo;
    sectorReached = sector;
    isNewBest = StorageService.instance.submitScore(finalScore);

    // XP: only for the part of the run not already recorded (continues).
    final scoreDelta = finalScore - _recordedScore;
    final orbsDelta = _orbsCollected - _recordedOrbs;
    xpGained = scoreDelta + sectorReached * GameConfig.sectorBonus;
    leveledUp = ProgressionService.instance.recordRun(
      score: scoreDelta + sectorReached * GameConfig.sectorBonus,
      orbs: orbsDelta,
      maxCombo: _maxCombo,
      sector: sectorReached,
      countRun: !continueUsed,
    );
    _recordedScore = finalScore;
    _recordedOrbs = _orbsCollected;

    _shake(GameConfig.screenShakeIntensity);
    _flashTime = 0.15;
    AudioService.instance.playDeath();
    _haptic(HapticFeedback.heavyImpact);
    _spawnBurst(ball.position, skinColorA: true, count: 36, big: true);
    ball.visible = false;
    overlays.remove(GameOverlays.hud);

    // Slow-motion beat so the explosion reads, then the menu appears.
    Future.delayed(const Duration(milliseconds: 950), () {
      if (state == GameState.dying) {
        timeScale = 1.0;
        state = GameState.gameOver;
        if (leveledUp) AudioService.instance.playLevelUp();
        overlays.add(GameOverlays.gameOver);
      }
    });
  }

  void _consumeShield() {
    hasShield = false;
    _refreshEffects();
    _graceTime = 1.0;
    _shake(GameConfig.screenShakeIntensity * 0.6);
    _flashTime = 0.10;
    AudioService.instance.playShieldBreak();
    _haptic(HapticFeedback.mediumImpact);
    spawnPopup('SHIELD DOWN', ball.position, GameConfig.shieldColor);

    // The hazard that hit us is destroyed so the save feels earned.
    final ballHalf = ball.radius / orbitRadius;
    for (final o in children.whereType<ArcObstacle>().toList()) {
      if (angleDistance(o.angle, ball.orbitAngle) <
          o.arcLength / 2 + ballHalf * 1.2) {
        o.destroy();
      }
    }
    for (final s in children.whereType<Sweeper>().toList()) {
      if (angleDistance(s.angle, ball.orbitAngle) <
          GameConfig.sweeperHalfWidth + ballHalf) {
        s.removeFromParent();
      }
    }
    for (final p in children.whereType<PulseRing>().toList()) {
      if (p.atOrbit) p.removeFromParent();
    }
  }

  /// Rewarded-ad continue: clear the field, restore the ball with a grace
  /// period, and keep the score and combo. Allowed once per run.
  void continueRun() {
    if (continueUsed) return;
    continueUsed = true;
    timeScale = 1.0;
    _clearHazards();
    _graceTime = GameConfig.continueGraceSeconds;
    ball.visible = true;
    state = GameState.playing;
    overlays.remove(GameOverlays.gameOver);
    overlays.add(GameOverlays.hud);
  }

  /// Rewarded-ad score doubler on the game-over screen.
  void doubleFinalScore() {
    final bonus = finalScore;
    finalScore *= 2;
    isNewBest = StorageService.instance.submitScore(finalScore) || isNewBest;
    // The doubled half also counts as XP.
    leveledUp = ProgressionService.instance.addXp(bonus) || leveledUp;
    xpGained += bonus;
    _recordedScore = finalScore;
  }

  // ── Update loop ──────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);

    // Real-time (unscaled) cosmetics.
    if (_shakeTime > 0) _shakeTime -= dt;
    if (_flashTime > 0) _flashTime -= dt;

    if (state != GameState.playing) return;

    // Gameplay logic runs on scaled time so slow-mo affects everything.
    final sdt = dt * timeScale;

    final sectorBefore = sector;
    _elapsed += sdt;
    if (sector != sectorBefore) _enterSector(sector);

    if (_graceTime > 0) _graceTime -= sdt;

    _scoreF += sdt * _scoreMultiplier;
    scoreNotifier.value = score;

    _updateCombo(sdt);
    _updateEffects(sdt);

    _spawnArcs(sdt);
    _spawnOrbs(sdt);
    _spawnPowerUps(sdt);
    _spawnSweepers(sdt);
    _spawnPulses(sdt);

    _checkCollisions();
  }

  void _enterSector(int s) {
    sectorNotifier.value = s;
    final bonus = GameConfig.sectorBonus * _scoreMultiplier;
    _scoreF += bonus;
    AudioService.instance.playSector();
    spawnPopup('SECTOR $s', center - Vector2(0, orbitRadius * 0.45),
        GameConfig.textPrimary,
        fontSize: 26, lifespan: 1.4);
    spawnPopup('+$bonus', center - Vector2(0, orbitRadius * 0.45 - 34),
        GameConfig.orbColor);
  }

  void _updateCombo(double sdt) {
    if (combo <= 1) return;
    _comboTimer -= sdt;
    if (_comboTimer <= 0) {
      combo = 1;
      comboNotifier.value = combo;
    }
  }

  void _updateEffects(double sdt) {
    if (_effectTimers.isEmpty) return;
    final expired = <PowerUpType>[];
    _effectTimers.updateAll((type, t) => t - sdt);
    _effectTimers.forEach((type, t) {
      if (t <= 0) expired.add(type);
    });
    if (expired.isEmpty) return;
    for (final type in expired) {
      _effectTimers.remove(type);
      if (type == PowerUpType.slowmo && state == GameState.playing) {
        timeScale = 1.0;
      }
    }
    _refreshEffects();
  }

  void _refreshEffects() {
    effectsNotifier.value = [
      if (hasShield) PowerUpType.shield,
      ..._effectTimers.keys,
    ];
  }

  // ── Spawning ─────────────────────────────────────────────────────────────

  void _spawnArcs(double sdt) {
    _arcTimer += sdt;
    final interval = GameConfig.startSpawnInterval +
        (GameConfig.minSpawnInterval - GameConfig.startSpawnInterval) *
            difficulty;
    if (_arcTimer < interval) return;

    final live = children.whereType<ArcObstacle>().length;
    final allowed = 2 + (difficulty * (GameConfig.maxObstacles - 2)).round();
    if (live >= allowed) return;

    final angle = _findFreeAngle(clearance: 0.75);
    if (angle == null) return;

    _arcTimer = 0;
    final arc = (GameConfig.startArcLength +
            (GameConfig.maxArcLength - GameConfig.startArcLength) *
                difficulty) *
        (0.85 + _rng.nextDouble() * 0.3);
    final speed = (_rng.nextDouble() * 2 - 1) *
        GameConfig.maxObstacleSpeed *
        (0.4 + 0.6 * difficulty);

    // Sector-gated behavior mix.
    var kind = ArcKind.drifter;
    final roll = _rng.nextDouble();
    if (sector >= 3 && roll < 0.20) {
      kind = ArcKind.splitter;
    } else if (sector >= 2 && roll < 0.45) {
      kind = ArcKind.hunter;
    }

    add(ArcObstacle(
        angle: angle, arcLength: arc, angularSpeed: speed, kind: kind));
  }

  void _spawnOrbs(double sdt) {
    _orbTimer += sdt;
    if (_orbTimer < GameConfig.orbSpawnInterval) return;
    if (children.whereType<Orb>().length >= 2) return;

    final angle = _findFreeAngle(clearance: 0.45);
    if (angle == null) return;

    _orbTimer = 0;
    add(Orb(orbitAngle: angle));
  }

  void _spawnPowerUps(double sdt) {
    _powerUpTimer += sdt;
    if (_powerUpTimer < GameConfig.powerUpSpawnInterval) return;
    if (children.whereType<PowerUp>().isNotEmpty) return;

    final angle = _findFreeAngle(clearance: 0.5);
    if (angle == null) return;

    _powerUpTimer = 0;
    final options = [
      if (!hasShield) PowerUpType.shield,
      PowerUpType.slowmo,
      PowerUpType.magnet,
      PowerUpType.frenzy,
    ];
    add(PowerUp(
        orbitAngle: angle, type: options[_rng.nextInt(options.length)]));
  }

  void _spawnSweepers(double sdt) {
    if (sector < 2) return;
    _sweeperTimer += sdt;
    final interval = max(8.0, 15.0 - sector.toDouble());
    if (_sweeperTimer < interval) return;
    if (children.whereType<Sweeper>().isNotEmpty) return;

    _sweeperTimer = 0;
    // Telegraph away from the ball so it's always avoidable.
    final angle = ball.orbitAngle + pi + (_rng.nextDouble() - 0.5) * 1.2;
    add(Sweeper(angle: angle, direction: _rng.nextBool() ? 1 : -1));
  }

  void _spawnPulses(double sdt) {
    if (sector < 3) return;
    _pulseTimer += sdt;
    final interval = max(9.0, 17.0 - sector.toDouble());
    if (_pulseTimer < interval) return;
    if (children.whereType<PulseRing>().isNotEmpty) return;

    _pulseTimer = 0;
    // The safe gap spawns within reach of the ball at current speed.
    final reach = currentSpeed * GameConfig.pulseTravelSeconds * 0.8;
    final offset = (_rng.nextDouble() * 2 - 1) * min(reach, pi * 0.9);
    add(PulseRing(gapAngle: ball.orbitAngle + offset));
  }

  /// Picks a random angle on the ring that is a safe distance from the ball
  /// and doesn't overlap existing ring objects. Returns null if the ring is
  /// too crowded this frame (we simply try again next frame).
  double? _findFreeAngle({required double clearance}) {
    for (var attempt = 0; attempt < 8; attempt++) {
      final candidate = ball.orbitAngle +
          (_rng.nextBool() ? 1 : -1) *
              (GameConfig.spawnSafetyGap +
                  _rng.nextDouble() * (pi - GameConfig.spawnSafetyGap));

      final blocked = children.whereType<ArcObstacle>().any((o) =>
          angleDistance(o.angle, candidate) < o.arcLength / 2 + clearance);
      final orbBlocked = children
          .whereType<Orb>()
          .any((o) => angleDistance(o.orbitAngle, candidate) < 0.4);
      final powerUpBlocked = children
          .whereType<PowerUp>()
          .any((p) => angleDistance(p.orbitAngle, candidate) < 0.4);
      if (!blocked && !orbBlocked && !powerUpBlocked) return candidate;
    }
    return null;
  }

  // ── Collisions ───────────────────────────────────────────────────────────

  void _checkCollisions() {
    final ballHalf = ball.radius / orbitRadius;

    // Orbs → combo & points.
    for (final orb in children.whereType<Orb>().toList()) {
      if (orb.collected) continue;
      if (angleDistance(orb.orbitAngle, ball.orbitAngle) <
          ballHalf + orb.radius / orbitRadius) {
        final points = GameConfig.orbScore * combo * _scoreMultiplier;
        _scoreF += points;
        _orbsCollected++;
        AudioService.instance.playOrb(combo);
        spawnPopup(
            combo > 1 ? '+$points ×$combo' : '+$points',
            orb.position - Vector2(0, orb.radius * 2),
            GameConfig.orbColor);
        _spawnBurst(orb.position, color: GameConfig.orbColor, count: 12);
        combo = min(combo + 1, GameConfig.comboMax);
        _maxCombo = max(_maxCombo, combo);
        _comboTimer = GameConfig.comboHoldSeconds;
        comboNotifier.value = combo;
        scoreNotifier.value = score;
        orb.collect();
      }
    }

    // Power-ups.
    for (final p in children.whereType<PowerUp>().toList()) {
      if (p.collected) continue;
      if (angleDistance(p.orbitAngle, ball.orbitAngle) <
          ballHalf + p.radius / orbitRadius) {
        applyPowerUp(p.type, p.position.clone());
        p.collect();
      }
    }

    if (isInvincible) return;

    // Arc obstacles: death or near-miss.
    for (final o in children.whereType<ArcObstacle>()) {
      if (!o.deadly) continue;
      final d = angleDistance(o.angle, ball.orbitAngle);
      final hitAt = o.arcLength / 2 + ballHalf * 0.8;

      if (d < hitAt) {
        die();
        return;
      }

      // Near-miss: shave past the edge without touching it.
      if (d < hitAt + GameConfig.nearMissWindow) {
        o.grazed = true;
      } else if (o.grazed && !o.nearMissAwarded && d > hitAt + 0.45) {
        o.nearMissAwarded = true;
        o.grazed = false;
        final points = GameConfig.nearMissScore * _scoreMultiplier;
        _scoreF += points;
        AudioService.instance.playNearMiss();
        _haptic(HapticFeedback.lightImpact);
        spawnPopup('NEAR MISS +$points',
            ball.position - Vector2(0, ball.radius * 3), GameConfig.textSecondary,
            fontSize: 13);
      }
    }

    // Sweeper beam.
    for (final s in children.whereType<Sweeper>()) {
      if (s.deadly &&
          angleDistance(s.angle, ball.orbitAngle) <
              GameConfig.sweeperHalfWidth + ballHalf * 0.8) {
        die();
        return;
      }
    }

    // Pulse rings.
    for (final p in children.whereType<PulseRing>()) {
      if (p.deadly && !p.isInGap(ball.orbitAngle)) {
        die();
        return;
      }
    }
  }

  // ── Power-up effects ─────────────────────────────────────────────────────

  void applyPowerUp(PowerUpType type, Vector2 at) {
    AudioService.instance.playPowerUp();
    _haptic(HapticFeedback.mediumImpact);
    spawnPopup(type.label, at - Vector2(0, 30), type.color);
    _spawnBurst(at, color: type.color, count: 14);

    switch (type) {
      case PowerUpType.shield:
        hasShield = true;
      case PowerUpType.slowmo:
        _effectTimers[type] = GameConfig.slowmoDuration;
        timeScale = GameConfig.slowmoScale;
      case PowerUpType.magnet:
        _effectTimers[type] = GameConfig.magnetDuration;
      case PowerUpType.frenzy:
        _effectTimers[type] = GameConfig.frenzyDuration;
    }
    _refreshEffects();
  }

  // ── Effects & rendering ──────────────────────────────────────────────────

  void spawnPopup(String text, Vector2 at, Color color,
      {double fontSize = 18, double lifespan = 0.9}) {
    add(ScorePopup(text, at.clone(), color,
        fontSize: fontSize, lifespan: lifespan));
  }

  void _shake(double strength) {
    _shakeTime = GameConfig.screenShakeDuration;
    _shakeStrength = strength;
  }

  @override
  void render(Canvas canvas) {
    if (_shakeTime > 0) {
      final t = (_shakeTime / GameConfig.screenShakeDuration) * _shakeStrength;
      canvas.save();
      canvas.translate(
        (_rng.nextDouble() * 2 - 1) * t,
        (_rng.nextDouble() * 2 - 1) * t,
      );
      super.render(canvas);
      canvas.restore();
    } else {
      super.render(canvas);
    }

    // Full-screen hit flash on death / shield break.
    if (_flashTime > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()
          ..color =
              Colors.white.withValues(alpha: (_flashTime / 0.15) * 0.35),
      );
    }
  }

  void _spawnBurst(
    Vector2 at, {
    Color? color,
    bool skinColorA = false,
    int count = 12,
    bool big = false,
  }) {
    final base = color ?? (skinColorA ? ball.skin.core : GameConfig.ballColor);
    add(ParticleSystemComponent(
      position: at.clone(),
      priority: 20,
      particle: Particle.generate(
        count: count,
        lifespan: big ? 0.9 : 0.5,
        generator: (i) {
          final dir = _rng.nextDouble() * 2 * pi;
          final speed =
              (big ? 60 : 40) + _rng.nextDouble() * (big ? 260 : 120);
          final c = big && i.isEven ? Colors.white : base;
          return AcceleratedParticle(
            speed: Vector2(cos(dir), sin(dir)) * speed,
            acceleration:
                big ? Vector2(cos(dir), sin(dir)) * -speed * 0.6 : Vector2.zero(),
            child: ComputedParticle(
              renderer: (canvas, particle) {
                canvas.drawCircle(
                  Offset.zero,
                  (big ? 2.0 : 1.5) + (big ? 4 : 2.5) * (1 - particle.progress),
                  Paint()..color = c.withValues(alpha: 1 - particle.progress),
                );
              },
            ),
          );
        },
      ),
    ));
  }

  void _haptic(Future<void> Function() fn) {
    try {
      fn();
    } catch (_) {
      // Haptics are best-effort (no-op on web / unsupported devices).
    }
  }
}

/// Shortest angular distance between two angles, in [0, pi].
double angleDistance(double a, double b) => shortestAngleDelta(a, b).abs();

/// Signed shortest rotation from [b] to [a], in [-pi, pi].
double shortestAngleDelta(double a, double b) {
  final diff = (a - b) % (2 * pi);
  final wrapped = diff < 0 ? diff + 2 * pi : diff;
  return wrapped > pi ? wrapped - 2 * pi : wrapped;
}
