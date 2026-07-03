import 'package:flame/components.dart';
import 'package:flutter/material.dart';

/// Floating feedback text ("+15", "NEAR MISS", "SECTOR 3"...) that rises
/// and fades out.
class ScorePopup extends PositionComponent {
  ScorePopup(
    this.text,
    Vector2 position,
    this.color, {
    this.fontSize = 18,
    this.lifespan = 0.9,
  }) : super(position: position, priority: 30, anchor: Anchor.center);

  final String text;
  final Color color;
  final double fontSize;
  final double lifespan;

  double _age = 0;

  @override
  void update(double dt) {
    _age += dt;
    position.y -= 42 * dt;
    if (_age >= lifespan) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_age / lifespan).clamp(0.0, 1.0);
    final alpha = t < 0.15 ? t / 0.15 : 1 - Curves.easeIn.transform(t);
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withValues(alpha: alpha.clamp(0.0, 1.0)),
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          shadows: [
            Shadow(
              color: color.withValues(alpha: 0.7 * alpha.clamp(0.0, 1.0)),
              blurRadius: 14,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
        canvas, Offset(-painter.width / 2, -painter.height / 2));
  }
}
