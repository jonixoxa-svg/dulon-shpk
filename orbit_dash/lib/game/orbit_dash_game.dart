import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../config/game_config.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'components/background.dart';
import 'components/center_core.dart';
import 'components/obstacle.dart';
import 'components/orb.dart';
import 'components/orbit_ring.dart';
import 'components/player_ball.dart';

/// Overlay ids used by the Flutter layer.
class GameOverlays {
  static const ready = 'ready';
  static const hud = 'hud';
  static const gameOver = 'gameOver';
}

enum GameState { ready, playing, dying, gameOver }

/// The core game: a ball orbits a center point, tapping reverses its
/// direction, arcs on the same orbit must be dodged, orbs give bonus points.
class OrbitDashGame extends FlameGame {
  final _rng = Random();

  GameState state = GameState.ready;

  /// Live score, mirrored to the HUD.
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);

  late PlayerBall ball;

  Vector2 center = Vector2.zero();
  double orbitRadius = 0;
  double shortestSide = 0;

  double _elapsed = 0;
  int _orbsCollected = 0;
  double _obstacleTimer = 0;
  double _orbTimer = 0;
  double _shakeTime = 0;
  double _graceTime = 0;

  /// Score frozen at the moment of death (can be doubled by a rewarded ad).
  int finalScore = 0;
  bool isNewBest = false;
  bool continueUsed = false;

  /// 0 → easiest, 1 → hardest. Eased so the first seconds feel gentle.
  double get difficulty {
    final t = (_elapsed / GameConfig.difficultyRampSeconds).clamp(0.0, 1.0);
    return Curves.easeOut.transform(t);
  }

  double get currentSpeed => lerpDouble(
        GameConfig.startAngularSpeed, GameConfig.maxAngularSpeed, difficulty);

  int get score => _elapsed.floor() + _orbsCollected * GameConfig.orbScore;

  bool get isInvincible => _graceTime > 0;

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
      case GameState.dying:
      case GameState.gameOver:
        break; // Buttons on the overlay handle these states.
    }
  }

  // ── Run lifecycle ────────────────────────────────────────────────────────

  void _startRun() {
    state = GameState.playing;
    _elapsed = 0;
    _orbsCollected = 0;
    _obstacleTimer = 0;
    _orbTimer = 0;
    _graceTime = 0;
    finalScore = 0;
    isNewBest = false;
    continueUsed = false;
    scoreNotifier.value = 0;
    ball.reset();
    _clearRingObjects();
    overlays.remove(GameOverlays.ready);
    overlays.add(GameOverlays.hud);
  }

  /// Back to the "tap to start" state (used by Retry).
  void resetToReady() {
    state = GameState.ready;
    ball.reset();
    _clearRingObjects();
    overlays.remove(GameOverlays.gameOver);
    overlays.add(GameOverlays.ready);
  }

  void _clearRingObjects() {
    children.whereType<Obstacle>().toList().forEach((o) => o.removeFromParent());
    children.whereType<Orb>().toList().forEach((o) => o.removeFromParent());
  }

  void die() {
    if (state != GameState.playing) return;
    state = GameState.dying;
    finalScore = score;
    isNewBest = StorageService.instance.submitScore(finalScore);
    _shakeTime = GameConfig.screenShakeDuration;
    AudioService.instance.playDeath();
    _spawnExplosion(ball.position);
    ball.visible = false;
    overlays.remove(GameOverlays.hud);

    // Short beat so the explosion reads before the menu appears.
    Future.delayed(const Duration(milliseconds: 850), () {
      if (state == GameState.dying) {
        state = GameState.gameOver;
        overlays.add(GameOverlays.gameOver);
      }
    });
  }

  /// Rewarded-ad continue: clear the ring, restore the ball with a grace
  /// period, and keep the current score. Allowed once per run.
  void continueRun() {
    if (continueUsed) return;
    continueUsed = true;
    _clearRingObjects();
    _graceTime = GameConfig.continueGraceSeconds;
    ball.visible = true;
    state = GameState.playing;
    overlays.remove(GameOverlays.gameOver);
    overlays.add(GameOverlays.hud);
  }

  /// Rewarded-ad score doubler on the game-over screen.
  void doubleFinalScore() {
    finalScore *= 2;
    isNewBest = StorageService.instance.submitScore(finalScore) || isNewBest;
  }

  // ── Update loop ──────────────────────────────────────────────────────────

  @override
  void update(double dt) {
    super.update(dt);
    if (_shakeTime > 0) _shakeTime -= dt;
    if (state != GameState.playing) return;

    _elapsed += dt;
    if (_graceTime > 0) _graceTime -= dt;
    scoreNotifier.value = score;

    _spawnObstacles(dt);
    _spawnOrbs(dt);
    _checkCollisions();
  }

  void _spawnObstacles(double dt) {
    _obstacleTimer += dt;
    final interval = lerpDouble(
        GameConfig.startSpawnInterval, GameConfig.minSpawnInterval, difficulty);
    if (_obstacleTimer < interval) return;

    final live = children.whereType<Obstacle>().length;
    final allowed = 2 + (difficulty * (GameConfig.maxObstacles - 2)).round();
    if (live >= allowed) return;

    final angle = _findFreeAngle(isObstacle: true);
    if (angle == null) return;

    _obstacleTimer = 0;
    final arc = lerpDouble(
            GameConfig.startArcLength, GameConfig.maxArcLength, difficulty) *
        (0.85 + _rng.nextDouble() * 0.3);
    final speed = (_rng.nextDouble() * 2 - 1) *
        GameConfig.maxObstacleSpeed *
        (0.4 + 0.6 * difficulty);
    add(Obstacle(angle: angle, arcLength: arc, angularSpeed: speed));
  }

  void _spawnOrbs(double dt) {
    _orbTimer += dt;
    if (_orbTimer < GameConfig.orbSpawnInterval) return;
    if (children.whereType<Orb>().length >= 2) return;

    final angle = _findFreeAngle(isObstacle: false);
    if (angle == null) return;

    _orbTimer = 0;
    add(Orb(orbitAngle: angle));
  }

  /// Picks a random angle on the ring that is a safe distance from the ball
  /// and doesn't overlap existing obstacles. Returns null if the ring is too
  /// crowded this frame (we simply try again next frame).
  double? _findFreeAngle({required bool isObstacle}) {
    for (var attempt = 0; attempt < 8; attempt++) {
      final candidate = ball.orbitAngle +
          (_rng.nextBool() ? 1 : -1) *
              (GameConfig.spawnSafetyGap +
                  _rng.nextDouble() * (pi - GameConfig.spawnSafetyGap));

      final clearance = isObstacle ? 0.75 : 0.45;
      final blocked = children.whereType<Obstacle>().any((o) =>
          angleDistance(o.angle, candidate) < o.arcLength / 2 + clearance);
      final orbBlocked = children
          .whereType<Orb>()
          .any((o) => angleDistance(o.orbitAngle, candidate) < 0.4);
      if (!blocked && !orbBlocked) return candidate;
    }
    return null;
  }

  void _checkCollisions() {
    final ballHalfWidth = ball.radius / orbitRadius;

    for (final orb in children.whereType<Orb>().toList()) {
      if (orb.collected) continue;
      final hit = angleDistance(orb.orbitAngle, ball.orbitAngle) <
          ballHalfWidth + orb.radius / orbitRadius;
      if (hit) {
        _orbsCollected++;
        scoreNotifier.value = score;
        AudioService.instance.playOrb();
        _spawnOrbBurst(orb.position);
        orb.collect();
      }
    }

    if (isInvincible) return;
    for (final obstacle in children.whereType<Obstacle>()) {
      if (!obstacle.deadly) continue;
      final hit = angleDistance(obstacle.angle, ball.orbitAngle) <
          obstacle.arcLength / 2 + ballHalfWidth * 0.8;
      if (hit) {
        die();
        return;
      }
    }
  }

  // ── Effects ──────────────────────────────────────────────────────────────

  @override
  void render(Canvas canvas) {
    if (_shakeTime <= 0) {
      super.render(canvas);
      return;
    }
    final strength = (_shakeTime / GameConfig.screenShakeDuration) *
        GameConfig.screenShakeIntensity;
    canvas.save();
    canvas.translate(
      (_rng.nextDouble() * 2 - 1) * strength,
      (_rng.nextDouble() * 2 - 1) * strength,
    );
    super.render(canvas);
    canvas.restore();
  }

  void _spawnExplosion(Vector2 at) {
    add(ParticleSystemComponent(
      position: at.clone(),
      priority: 20,
      particle: Particle.generate(
        count: 36,
        lifespan: 0.9,
        generator: (i) {
          final dir = _rng.nextDouble() * 2 * pi;
          final speed = 60 + _rng.nextDouble() * 260;
          final color = i.isEven ? GameConfig.ballColor : Colors.white;
          return AcceleratedParticle(
            speed: Vector2(cos(dir), sin(dir)) * speed,
            acceleration: Vector2(cos(dir), sin(dir)) * -speed * 0.6,
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = color.withValues(alpha: 1 - particle.progress);
                canvas.drawCircle(
                    Offset.zero, 2 + 4 * (1 - particle.progress), paint);
              },
            ),
          );
        },
      ),
    ));
  }

  void _spawnOrbBurst(Vector2 at) {
    add(ParticleSystemComponent(
      position: at.clone(),
      priority: 20,
      particle: Particle.generate(
        count: 12,
        lifespan: 0.5,
        generator: (i) {
          final dir = _rng.nextDouble() * 2 * pi;
          final speed = 40 + _rng.nextDouble() * 120;
          return AcceleratedParticle(
            speed: Vector2(cos(dir), sin(dir)) * speed,
            child: ComputedParticle(
              renderer: (canvas, particle) {
                final paint = Paint()
                  ..color = GameConfig.orbColor
                      .withValues(alpha: 1 - particle.progress);
                canvas.drawCircle(
                    Offset.zero, 1.5 + 2.5 * (1 - particle.progress), paint);
              },
            ),
          );
        },
      ),
    ));
  }
}

/// Shortest angular distance between two angles, in [0, pi].
double angleDistance(double a, double b) {
  final diff = (a - b) % (2 * pi);
  final wrapped = diff < 0 ? diff + 2 * pi : diff;
  return wrapped > pi ? 2 * pi - wrapped : wrapped;
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;
