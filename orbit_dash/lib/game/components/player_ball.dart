import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../services/progression_service.dart';
import '../orbit_dash_game.dart';

/// The player: a glowing ball orbiting the center. Tapping the screen
/// reverses its direction (handled by the game, which calls [reverse]).
/// Its colors come from the currently selected unlockable skin, and it
/// shows a rotating aura while a shield is held.
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
  double _auraSpin = 0;

  double get radius => game.shortestSide * GameConfig.ballRadiusFactor;

  BallSkin get skin => ProgressionService.instance.currentSkin;

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

    position =
        game.center + Vector2(cos(orbitAngle), sin(orbitAngle)) * game.orbitRadius;
    _blinkTimer += dt;
    _auraSpin += dt * 2.4;

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
    // Blink while invincible after a rewarded continue / shield save.
    if (game.isInvincible && (_blinkTimer * 10).floor().isEven) return;

    // Shield aura: rotating dashed ring.
    if (game.hasShield) {
      final auraR = radius * 1.9;
      final aura = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..color = GameConfig.shieldColor.withValues(alpha: 0.9);
      final rect = Rect.fromCircle(center: Offset.zero, radius: auraR);
      for (var i = 0; i < 4; i++) {
        canvas.drawArc(rect, _auraSpin + i * pi / 2, pi / 3.2, false, aura);
      }
      canvas.drawCircle(
        Offset.zero,
        auraR,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..color = GameConfig.shieldColor.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    _glowPaint.color = skin.glow.withValues(alpha: 0.8);
    _corePaint.color = skin.core;
    canvas.drawCircle(Offset.zero, radius * 1.7, _glowPaint);
    canvas.drawCircle(Offset.zero, radius, _corePaint);
    // Mascot face: football patch + big eyes that blink and look toward
    // the core. Characters create attachment; geometry doesn't.
    final blink = (_blinkTimer % 3.4) > 3.25;
    final toCore = (game.center - position)..normalize();
    final look = Offset(toCore.x, toCore.y) * radius * 0.14;
    for (final side in [-1.0, 1.0]) {
      final ec = Offset(side * radius * 0.38, -radius * 0.15);
      canvas.drawCircle(ec, radius * 0.34,
          Paint()..color = Colors.white.withValues(alpha: 0.95));
      if (blink) {
        canvas.drawLine(ec + Offset(-radius * 0.2, 0), ec + Offset(radius * 0.2, 0),
            Paint()..color = const Color(0xFF10131F)..strokeWidth = 2.4);
      } else {
        canvas.drawCircle(ec + look, radius * 0.16,
            Paint()..color = const Color(0xFF10131F));
      }
    }
    // little smile
    canvas.drawArc(
        Rect.fromCircle(center: Offset(0, radius * 0.28), radius: radius * 0.3),
        0.4, 2.3, false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = const Color(0xEE10131F));
  }

  void _emitTrail() {
    final r = radius;
    final color = skin.core;
    game.add(ParticleSystemComponent(
      position: position.clone(),
      priority: 9,
      particle: ComputedParticle(
        lifespan: 0.4,
        renderer: (canvas, particle) {
          final fade = 1 - particle.progress;
          canvas.drawCircle(
            Offset.zero,
            r * 0.8 * fade,
            Paint()..color = color.withValues(alpha: 0.35 * fade),
          );
        },
      ),
    ));
  }
}
