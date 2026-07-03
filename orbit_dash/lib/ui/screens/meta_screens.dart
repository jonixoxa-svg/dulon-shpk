import 'dart:math';

import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../config/meta_config.dart';
import '../../services/ads/ad_service.dart';
import '../../services/audio_service.dart';
import '../../services/meta_service.dart';

/// Missions, badge wall, capsule opening and the stadium — the whole
/// engagement layer UI in one module.

// ── daily missions ─────────────────────────────────────────────────────────
class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});
  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> {
  @override
  Widget build(BuildContext context) {
    final meta = MetaService.instance;
    final ms = meta.todaysMissions;
    return Scaffold(
      backgroundColor: GameConfig.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('DAILY MISSIONS',
            style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('New missions every day — claim to earn coins and a gift capsule.',
              style: TextStyle(color: GameConfig.textSecondary)),
          const SizedBox(height: 16),
          for (var i = 0; i < 3; i++) _missionTile(meta, ms[i], i),
        ],
      ),
    );
  }

  Widget _missionTile(MetaService meta, Mission m, int i) {
    final prog = meta.missionProgress[i], done = prog >= m.target;
    final claimed = meta.missionClaimed[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: done && !claimed
                ? GameConfig.orbColor
                : Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(children: [
        AnimatedScale(
          scale: claimed ? 1 : done ? 1.15 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          child: Icon(
            claimed ? Icons.check_circle : done ? Icons.redeem : Icons.flag_outlined,
            color: claimed
                ? GameConfig.pulseColor
                : done
                    ? GameConfig.orbColor
                    : GameConfig.textSecondary,
            size: 34,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.label,
                style: const TextStyle(
                    color: GameConfig.textPrimary, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: prog / m.target,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor: AlwaysStoppedAnimation(
                    claimed ? GameConfig.pulseColor : GameConfig.ballColor),
              ),
            ),
            Text('$prog / ${m.target}',
                style: const TextStyle(
                    color: GameConfig.textSecondary, fontSize: 11)),
          ]),
        ),
        const SizedBox(width: 10),
        claimed
            ? const Text('DONE',
                style: TextStyle(color: GameConfig.pulseColor, fontWeight: FontWeight.w800))
            : FilledButton(
                onPressed: done
                    ? () {
                        AudioService.instance.playLevelUp();
                        setState(() => meta.claimMission(i));
                      }
                    : null,
                style: FilledButton.styleFrom(backgroundColor: GameConfig.orbColor),
                child: Text('+${m.reward}¢',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
      ]),
    );
  }
}

// ── badge wall (30 achievements) ───────────────────────────────────────────
class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final meta = MetaService.instance;
    const tierColors = [Color(0xFFCD7F32), Color(0xFFC0C0C0), Color(0xFFFFD700)];
    return Scaffold(
      backgroundColor: GameConfig.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('BADGES  ${meta.unlockedBadges.length}/30',
            style: const TextStyle(letterSpacing: 3, fontWeight: FontWeight.w800)),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        padding: const EdgeInsets.all(16),
        children: [
          for (final tr in MetaConfig.achievementTracks)
            for (var t = 0; t < 3; t++)
              Builder(builder: (_) {
                final unlocked = meta.unlockedBadges.contains('${tr.key}$t');
                return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.workspace_premium,
                      size: 52,
                      color: unlocked
                          ? tierColors[t]
                          : Colors.white.withValues(alpha: 0.12)),
                  Text(tr.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: unlocked
                              ? GameConfig.textPrimary
                              : GameConfig.textSecondary)),
                  Text(unlocked ? ['BRONZE', 'SILVER', 'GOLD'][t] : '${tr.tiers[t]}',
                      style: TextStyle(
                          fontSize: 10,
                          color: unlocked ? tierColors[t] : GameConfig.textSecondary)),
                ]);
              }),
        ],
      ),
    );
  }
}

// ── capsule opening (shake → crack → burst) ────────────────────────────────
Future<void> showCapsuleDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _CapsuleDialog(),
  );
}

class _CapsuleDialog extends StatefulWidget {
  const _CapsuleDialog();
  @override
  State<_CapsuleDialog> createState() => _CapsuleDialogState();
}

class _CapsuleDialogState extends State<_CapsuleDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  CapsuleReward? _reward;
  bool _doubled = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..addStatusListener((st) {
        if (st == AnimationStatus.completed && _reward == null) {
          setState(() => _reward = MetaService.instance.rollCapsule());
          AudioService.instance.playLevelUp();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = _reward;
    return Dialog(
      backgroundColor: GameConfig.backgroundAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('GIFT CAPSULE',
              style: TextStyle(
                  color: GameConfig.textSecondary,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _c,
            builder: (context, child) {
              final t = _c.value;
              // shake grows, then crack flash, then the reward bursts in
              final shake = r == null ? sin(t * 40) * 8 * t : 0.0;
              return Transform.translate(
                offset: Offset(shake, 0),
                child: r == null
                    ? Icon(Icons.card_giftcard,
                        size: 110,
                        color: Color.lerp(GameConfig.textSecondary,
                            GameConfig.orbColor, t))
                    : TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.4, end: 1),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.elasticOut,
                        builder: (context, s, child) => Transform.scale(
                          scale: s,
                          child: Column(children: [
                            Icon(Icons.stars, size: 96, color: r.tier.color),
                            Text(r.tier.name,
                                style: TextStyle(
                                    color: r.tier.color,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 20,
                                    letterSpacing: 3)),
                            Text('+${_doubled ? r.coins * 2 : r.coins} coins',
                                style: const TextStyle(
                                    color: GameConfig.textPrimary,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800)),
                          ]),
                        ),
                      ),
              );
            },
          ),
          const SizedBox(height: 22),
          if (r != null) ...[
            // Rewarded ad: OPTIONAL, player-initiated, clearly labeled.
            if (!_doubled && AdService.instance.isRewardedReady)
              TextButton.icon(
                icon: const Icon(Icons.redeem, color: GameConfig.orbColor),
                label: const Text('Watch ad to DOUBLE this reward',
                    style: TextStyle(color: GameConfig.orbColor)),
                onPressed: () => AdService.instance.showRewarded(
                  onReward: () {
                    MetaService.instance.addCoins(r.coins);
                    if (mounted) setState(() => _doubled = true);
                  },
                ),
              ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('COLLECT'),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── home stadium (meta-progression scene + upgrades) ───────────────────────
class StadiumView extends StatefulWidget {
  const StadiumView({super.key});
  @override
  State<StadiumView> createState() => _StadiumViewState();
}

class _StadiumViewState extends State<StadiumView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))
        ..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = MetaService.instance;
    final lvl = meta.stadiumLevel;
    final next = lvl < MetaConfig.stadiumStages.length
        ? MetaConfig.stadiumStages[lvl]
        : null;
    return Column(children: [
      SizedBox(
        height: 130,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, child) => CustomPaint(
              painter: _StadiumPainter(lvl, _anim.value)),
        ),
      ),
      const SizedBox(height: 6),
      Text('HOME STADIUM  ·  stage $lvl/${MetaConfig.stadiumStages.length}',
          style: const TextStyle(
              color: GameConfig.textSecondary, fontSize: 11, letterSpacing: 2)),
      if (next != null)
        TextButton(
          onPressed: () {
            if (MetaService.instance.buyStadiumUpgrade()) {
              AudioService.instance.playLevelUp();
              setState(() {});
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Need ${next.cost} coins — keep playing!'),
                  duration: const Duration(seconds: 1)));
            }
          },
          child: Text('Build "${next.name}" — ${next.cost}¢',
              style: const TextStyle(
                  color: GameConfig.orbColor, fontWeight: FontWeight.w800)),
        )
      else
        const Text('STADIUM COMPLETE! 🎆',
            style: TextStyle(color: GameConfig.orbColor)),
    ]);
  }
}

/// Draws the stadium scene; every stage adds a permanent visible element.
class _StadiumPainter extends CustomPainter {
  _StadiumPainter(this.level, this.t);
  final int level;
  final double t;

  @override
  void paint(Canvas c, Size s) {
    final w = s.width, h = s.height;
    final green = Paint()..color = const Color(0xFF14532D);
    // base pitch always visible
    final pitch = Rect.fromLTWH(w * 0.2, h * 0.55, w * 0.6, h * 0.4);
    c.drawRRect(RRect.fromRectAndRadius(pitch, const Radius.circular(8)), green);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    if (level >= 1) { // pitch lines
      c.drawRRect(RRect.fromRectAndRadius(pitch.deflate(6), const Radius.circular(6)), line);
      c.drawCircle(pitch.center, h * 0.08, line);
      c.drawLine(Offset(pitch.center.dx, pitch.top + 6),
          Offset(pitch.center.dx, pitch.bottom - 6), line);
    }
    if (level >= 2) { // goal posts
      for (final x in [pitch.left + 4, pitch.right - 10]) {
        c.drawRect(Rect.fromLTWH(x, pitch.center.dy - 10, 6, 20),
            Paint()..color = Colors.white);
      }
    }
    void flood(double x) {
      c.drawLine(Offset(x, h * 0.55), Offset(x, h * 0.18),
          Paint()..color = const Color(0xFF8FA3C8)..strokeWidth = 3);
      c.drawCircle(Offset(x, h * 0.16), 6,
          Paint()
            ..color = const Color(0xFFFFF6C0)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, level >= 14 ? 10 : 4));
    }
    if (level >= 3) flood(w * 0.14);
    if (level >= 4) flood(w * 0.86);
    final standPaint = Paint()..color = const Color(0xFF2A3550);
    if (level >= 5) c.drawRect(Rect.fromLTWH(w * 0.2, h * 0.95, w * 0.6, h * 0.05), standPaint);
    if (level >= 6) c.drawRect(Rect.fromLTWH(w * 0.2, h * 0.42, w * 0.6, h * 0.12), standPaint);
    if (level >= 7) { // scoreboard
      c.drawRect(Rect.fromLTWH(w * 0.44, h * 0.06, w * 0.12, h * 0.1),
          Paint()..color = const Color(0xFF10131F));
      c.drawRect(Rect.fromLTWH(w * 0.44, h * 0.06, w * 0.12, h * 0.1),
          line..strokeWidth = 1);
    }
    if (level >= 8) c.drawRect(Rect.fromLTWH(w * 0.08, h * 0.42, w * 0.1, h * 0.55), standPaint);
    if (level >= 9) c.drawRect(Rect.fromLTWH(w * 0.82, h * 0.42, w * 0.1, h * 0.55), standPaint);
    if (level >= 10) { // fans: waving dots
      final fan = Paint()..color = GameConfig.orbColor;
      for (var i = 0; i < 14; i++) {
        final fx = w * 0.22 + i * w * 0.04;
        final fy = h * 0.47 + sin(t * 2 * pi * 2 + i) * 2.5;
        c.drawCircle(Offset(fx, fy), 2.4, fan);
      }
    }
    if (level >= 11) { // roof
      c.drawArc(Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.9, h * 0.85), pi, pi,
          false, Paint()
            ..color = const Color(0xFF8FA3C8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4);
    }
    if (level >= 12) { // flags
      for (final x in [w * 0.08, w * 0.92]) {
        c.drawLine(Offset(x, h * 0.4), Offset(x, h * 0.22),
            Paint()..color = Colors.white..strokeWidth = 2);
        final path = Path()
          ..moveTo(x, h * 0.22)
          ..lineTo(x + 14 * sin(t * 2 * pi).abs() + 6, h * 0.25)
          ..lineTo(x, h * 0.29)
          ..close();
        c.drawPath(path, Paint()..color = GameConfig.obstacleColor);
      }
    }
    if (level >= 13) { // big screen glows
      c.drawRect(Rect.fromLTWH(w * 0.445, h * 0.065, w * 0.11, h * 0.09),
          Paint()..color = GameConfig.ballColor.withValues(alpha: 0.4 + 0.3 * sin(t * 2 * pi * 3).abs()));
    }
    if (level >= 15) { // fireworks!
      final rng = Random((t * 3).floor());
      for (var i = 0; i < 3; i++) {
        final fx = w * (0.2 + rng.nextDouble() * 0.6), fy = h * (0.05 + rng.nextDouble() * 0.2);
        final phase = (t * 3) % 1;
        for (var k = 0; k < 8; k++) {
          final a = k * pi / 4;
          c.drawCircle(
              Offset(fx + cos(a) * 14 * phase, fy + sin(a) * 14 * phase),
              2 * (1 - phase),
              Paint()..color = [GameConfig.orbColor, GameConfig.ballColor, GameConfig.obstacleColor][i]);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_StadiumPainter old) =>
      old.level != level || old.t != t;
}
