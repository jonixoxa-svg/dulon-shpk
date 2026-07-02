import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../orbit_dash_game.dart';

/// The player: a glowing ball orbiting the center. Tapping the screen
/// reverses its direction (handled by the game, which calls [reverse]).
class PlayerBall extends PositionComponent
    with HasGameReference<OrbitDashGame> {
  PlayerBall() : super(priority: 10, anchor: Anchor.center);

  /// Current angular position on the ring, in radians.
  double orbitAngle = -pi / 2;

  /// +1 = clockwise, -1 = counter-clockwise.
  int direction = 1;

  bool visible = true;

  double _trailTimer = 0;
  double _blinkTimer = 0;

  double get radius => game.shortestSide * GameConfig.ballRadiusFactor;

  static final _glowPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  static final _corePaint = Paint();

  void reset() {
    orbitAngle = -pi / 2;
    direction = 1;
    visible = true;
  }

  void reverse() => direction = -direction;

  @override
  void update(double dt) {
    // In the "ready" state the ball keeps orbiting slowly as a preview.
    final speed = game.state == GameState.playing
        ? game.currentSpeed
        : GameConfig.startAngularSpeed * 0.5;
    if (game.state == GameState.playing || game.state == GameState.ready) {
      orbitAngle += direction * speed * dt;
    }

    position = game.center + Vector2(cos(orbitAngle), sin(orbitAngle)) * game.orbitRadius;
    _blinkTimer += dt;

    if (visible && game.state == GameState.playing) {
      _trailTimer += dt;
      if (_trailTimer >= 0.035) {
        _trailTimer = 0;
        _emitTrail();
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (!visible) return;
    // Blink while invincible after a rewarded continue.
    if (game.isInvincible && (_blinkTimer * 10).floor().isEven) return;

    _glowPaint.color = GameConfig.ballGlow.withValues(alpha: 0.8);
    _corePaint.color = GameConfig.ballColor;
    canvas.drawCircle(Offset.zero, radius * 1.7, _glowPaint);
    canvas.drawCircle(Offset.zero, radius, _corePaint);
    canvas.drawCircle(Offset(-radius * 0.25, -radius * 0.25), radius * 0.4,
        Paint()..color = Colors.white.withValues(alpha: 0.85));
  }

  void _emitTrail() {
    final r = radius;
    game.add(ParticleSystemComponent(
      position: position.clone(),
      priority: 9,
      particle: ComputedParticle(
        lifespan: 0.4,
        renderer: (canvas, particle) {
          final fade = 1 - particle.progress;
          final paint = Paint()
            ..color = GameConfig.ballColor.withValues(alpha: 0.35 * fade);
          canvas.drawCircle(Offset.zero, r * 0.8 * fade, paint);
        },
      ),
    ));
  }
}
