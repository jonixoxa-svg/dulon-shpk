import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../orbit_dash_game.dart';

/// The three arc-obstacle behaviors.
enum ArcKind {
  /// Passively drifts around the ring at a fixed speed.
  drifter,

  /// Accelerates around the ring toward the player's current angle.
  hunter,

  /// When its lifetime ends, splits into two smaller, faster drifters.
  splitter,
}

/// A deadly arc segment on the orbit ring. Fades in as a warning, moves
/// according to its [kind], then fades out and removes itself.
class ArcObstacle extends Component with HasGameReference<OrbitDashGame> {
  ArcObstacle({
    required this.angle,
    required this.arcLength,
    required this.angularSpeed,
    this.kind = ArcKind.drifter,
    this.generation = 0,
  }) : super(priority: 6);

  /// Angular position of the arc's center, in radians.
  double angle;

  /// Total arc length in radians.
  final double arcLength;

  /// Current drift speed around the ring, rad/s. Hunters mutate this.
  double angularSpeed;

  final ArcKind kind;

  /// Splitter children are generation 1 and never split again.
  final int generation;

  // Near-miss bookkeeping, managed by the game's collision pass.
  bool grazed = false;
  bool nearMissAwarded = false;

  double _age = 0;
  late final double _lifespan =
      (kind == ArcKind.splitter ? 5.5 : 7.0) + Random().nextDouble() * 3;
  static const _fadeOut = 0.6;

  bool _destroyed = false;

  static final _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  static final _glowPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

  Color get color => switch (kind) {
        ArcKind.drifter => GameConfig.obstacleColor,
        ArcKind.hunter => GameConfig.hunterColor,
        ArcKind.splitter => GameConfig.splitterColor,
      };

  /// Opacity ramps 0→1 during the warning window, 1→0 during fade-out.
  double get _opacity {
    if (_age < GameConfig.obstacleWarningSeconds) {
      return _age / GameConfig.obstacleWarningSeconds;
    }
    final remaining = _lifespan - _age;
    if (remaining < _fadeOut) return (remaining / _fadeOut).clamp(0.0, 1.0);
    return 1;
  }

  /// Only a fully materialized arc can kill the player.
  bool get deadly =>
      !_destroyed &&
      _age >= GameConfig.obstacleWarningSeconds &&
      _opacity > 0.35;

  @override
  void update(double dt) {
    _age += dt;

    if (kind == ArcKind.hunter && deadly && game.state == GameState.playing) {
      // Chase: accelerate toward the shortest direction to the ball.
      final diff = shortestAngleDelta(game.ball.orbitAngle, angle);
      final desired = diff.sign * GameConfig.hunterMaxSpeed;
      final accel = GameConfig.hunterAcceleration * dt;
      angularSpeed = (angularSpeed + (desired - angularSpeed).clamp(-accel, accel));
    }

    angle += angularSpeed * dt;

    if (_age >= _lifespan) {
      if (kind == ArcKind.splitter &&
          generation == 0 &&
          !_destroyed &&
          game.state == GameState.playing) {
        _split();
      }
      removeFromParent();
    }
  }

  void _split() {
    final rng = Random();
    for (final side in [-1, 1]) {
      game.add(ArcObstacle(
        angle: angle + side * arcLength * 0.8,
        arcLength: arcLength * 0.55,
        angularSpeed:
            side * (0.35 + rng.nextDouble() * 0.35) * (generation + 1),
        kind: ArcKind.drifter,
        generation: 1,
      ));
    }
  }

  /// Destroyed by a shield hit: bursts into particles, never splits.
  void destroy() {
    if (_destroyed) return;
    _destroyed = true;
    final rng = Random();
    final pos = game.center +
        Vector2(cos(angle), sin(angle)) * game.orbitRadius;
    game.add(ParticleSystemComponent(
      position: pos,
      priority: 20,
      particle: Particle.generate(
        count: 18,
        lifespan: 0.6,
        generator: (i) {
          final dir = rng.nextDouble() * 2 * pi;
          final speed = 50 + rng.nextDouble() * 180;
          return AcceleratedParticle(
            speed: Vector2(cos(dir), sin(dir)) * speed,
            child: ComputedParticle(
              renderer: (canvas, particle) {
                canvas.drawCircle(
                  Offset.zero,
                  1.5 + 3 * (1 - particle.progress),
                  Paint()
                    ..color =
                        color.withValues(alpha: 1 - particle.progress),
                );
              },
            ),
          );
        },
      ),
    ));
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromCircle(
        center: game.center.toOffset(), radius: game.orbitRadius);
    final thickness = game.shortestSide * GameConfig.obstacleThicknessFactor;
    final start = angle - arcLength / 2;
    final o = _opacity;

    _glowPaint
      ..strokeWidth = thickness * 1.4
      ..color = color.withValues(alpha: 0.5 * o);
    _paint
      ..strokeWidth = thickness
      ..color = color.withValues(alpha: o);

    canvas.drawArc(rect, start, arcLength, false, _glowPaint);
    canvas.drawArc(rect, start, arcLength, false, _paint);

    // Hunters get an angry inner highlight so they read as different.
    if (kind == ArcKind.hunter) {
      canvas.drawArc(
        rect,
        start + arcLength * 0.2,
        arcLength * 0.6,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = thickness * 0.35
          ..color = Colors.white.withValues(alpha: 0.75 * o),
      );
    }
  }
}
