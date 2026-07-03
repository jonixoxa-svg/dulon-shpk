import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../game/orbit_dash_game.dart';
import '../../services/ads/ad_service.dart';
import '../../services/iap/iap_service.dart';
import '../../services/progression_service.dart';
import '../../services/meta_service.dart';
import '../../services/storage_service.dart';
import '../screens/meta_screens.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neon_button.dart';

/// Game-over screen: score, run stats, XP progress, rewarded-ad offers
/// (continue once per run + double score), retry and home.
/// Banner ad at the bottom.
class GameOverOverlay extends StatefulWidget {
  const GameOverOverlay({super.key, required this.game});

  final OrbitDashGame game;

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  static const _continueWindow = 5;

  Timer? _countdown;
  int _secondsLeft = _continueWindow;
  bool _scoreDoubled = false;
  bool _rewardEarned = false;
  bool _busy = false; // guards against double taps while an ad opens

  OrbitDashGame get game => widget.game;

  bool get _adFree => IapService.instance.removeAdsOwned;

  bool get _canContinue =>
      !game.continueUsed &&
      _secondsLeft > 0 &&
      (_adFree || AdService.instance.isRewardedReady);

  @override
  void initState() {
    super.initState();
    if (!game.continueUsed &&
        (IapService.instance.removeAdsOwned ||
            AdService.instance.isRewardedReady)) {
      _countdown = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() => _secondsLeft--);
        if (_secondsLeft <= 0) t.cancel();
      });
    } else {
      _secondsLeft = 0;
    }
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  void _watchAdToContinue() {
    if (_busy) return;
    if (_adFree) {
      // Remove Ads owners get the perk free — no ad, instant continue.
      _countdown?.cancel();
      game.continueRun();
      return;
    }
    _busy = true;
    _countdown?.cancel();
    _rewardEarned = false;
    AdService.instance.showRewarded(
      onReward: () => _rewardEarned = true,
      onDismissed: () {
        _busy = false;
        if (_rewardEarned) {
          game.continueRun();
        } else if (mounted) {
          setState(() => _secondsLeft = 0);
        }
      },
      onUnavailable: () {
        _busy = false;
        if (mounted) setState(() => _secondsLeft = 0);
      },
    );
  }

  void _watchAdToDouble() {
    if (_busy) return;
    _busy = true;
    AdService.instance.showRewarded(
      onReward: () {
        game.doubleFinalScore();
        if (mounted) setState(() => _scoreDoubled = true);
      },
      onDismissed: () => _busy = false,
      onUnavailable: () {
        _busy = false;
        if (mounted) setState(() {});
      },
    );
  }

  void _retry() {
    if (_busy) return;
    _busy = true;
    _countdown?.cancel();
    AdService.instance.maybeShowInterstitial(
        suppress: game.isNewBest,
        onDismissed: () {
      _busy = false;
      game.resetToReady();
    });
  }

  void _home() {
    if (_busy) return;
    _busy = true;
    _countdown?.cancel();
    AdService.instance.maybeShowInterstitial(
        suppress: game.isNewBest,
        onDismissed: () {
      _busy = false;
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: GameConfig.background.withValues(alpha: 0.86),
      child: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        60,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 28),
                      const Text(
                        'GAME OVER',
                        style: TextStyle(
                          color: GameConfig.obstacleColor,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          shadows: [
                            Shadow(
                                color: GameConfig.obstacleColor,
                                blurRadius: 24),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _scoreBlock(),
                      const SizedBox(height: 14),
                      _statsRow(),
                      const SizedBox(height: 10),
                      _soCloseBar(),
                      const SizedBox(height: 10),
                      _xpBlock(),
                      const SizedBox(height: 22),
                      if (MetaService.instance.capsulesPending > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: NeonButton(
                            label:
                                'OPEN CAPSULE (${MetaService.instance.capsulesPending})',
                            icon: Icons.card_giftcard,
                            compact: true,
                            colors: const [
                              GameConfig.coreColor,
                              GameConfig.orbColor
                            ],
                            onPressed: () async {
                              await showCapsuleDialog(context);
                              if (mounted) setState(() {});
                            },
                          ),
                        ),
                      if (_canContinue) ...[
                        NeonButton(
                          label: 'CONTINUE ($_secondsLeft)',
                          icon: Icons.play_circle_outline,
                          colors: const [
                            GameConfig.orbColor,
                            GameConfig.obstacleColor,
                          ],
                          onPressed: _watchAdToContinue,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _adFree ? 'free for you — ad-free player' : 'watch an ad to keep this run',
                          style: TextStyle(
                            color: GameConfig.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (!_scoreDoubled &&
                          AdService.instance.isRewardedReady)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: NeonButton(
                            label: '2× SCORE',
                            icon: Icons.ondemand_video,
                            compact: true,
                            colors: const [
                              GameConfig.coreColor,
                              GameConfig.ballColor,
                            ],
                            onPressed: _watchAdToDouble,
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NeonButton(
                            label: 'RETRY',
                            icon: Icons.refresh,
                            onPressed: _retry,
                          ),
                          const SizedBox(width: 16),
                          NeonButton(
                            label: 'HOME',
                            icon: Icons.home_rounded,
                            compact: true,
                            colors: const [
                              GameConfig.backgroundAccent,
                              GameConfig.backgroundAccent,
                            ],
                            onPressed: _home,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _scoreBlock() {
    return Column(
      children: [
        if (game.isNewBest)
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              '• NEW BEST •',
              style: TextStyle(
                color: GameConfig.orbColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
              ),
            ),
          ),
        Text(
          '${game.finalScore}',
          style: TextStyle(
            color: GameConfig.textPrimary,
            fontSize: 64,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: _scoreDoubled
                    ? GameConfig.orbColor
                    : GameConfig.ballGlow,
                blurRadius: 20,
              ),
            ],
          ),
        ),
        if (_scoreDoubled)
          const Text(
            'DOUBLED!',
            style: TextStyle(
              color: GameConfig.orbColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          'BEST  ${StorageService.instance.highScore}',
          style: const TextStyle(
            color: GameConfig.textSecondary,
            fontSize: 15,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  /// "So close!" calibration: frame the loss as near-success.
  Widget _soCloseBar() {
    final best = StorageService.instance.highScore;
    if (best <= 0 || game.isNewBest) return const SizedBox.shrink();
    final f = (game.finalScore / best).clamp(0.0, 1.0);
    return Column(children: [
      Text('${(f * 100).round()}% of your best — so close!',
          style: const TextStyle(
              color: GameConfig.orbColor,
              fontSize: 13,
              fontWeight: FontWeight.w800)),
      const SizedBox(height: 5),
      SizedBox(
        width: 220,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: f),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, v, child) => LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor:
                    const AlwaysStoppedAnimation(GameConfig.orbColor)),
          ),
        ),
      ),
    ]);
  }

  Widget _statsRow() {
    Widget stat(String label, String value) => Column(
          children: [
            Text(value,
                style: const TextStyle(
                  color: GameConfig.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                )),
            Text(label,
                style: const TextStyle(
                  color: GameConfig.textSecondary,
                  fontSize: 10,
                  letterSpacing: 2,
                )),
          ],
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        stat('SECTOR', '${game.sectorReached}'),
        const SizedBox(width: 28),
        stat('ORBS', '${game.orbsThisRun}'),
        const SizedBox(width: 28),
        stat('MAX COMBO', '×${game.maxComboThisRun}'),
      ],
    );
  }

  Widget _xpBlock() {
    final prog = ProgressionService.instance;
    final fraction =
        (prog.xpIntoLevel / prog.xpForNextLevel).clamp(0.0, 1.0);
    return Column(
      children: [
        if (game.leveledUp)
          const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text(
              'LEVEL UP!',
              style: TextStyle(
                color: GameConfig.pulseColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                shadows: [Shadow(color: GameConfig.pulseColor, blurRadius: 16)],
              ),
            ),
          ),
        Text(
          '+${game.xpGained} XP   •   LEVEL ${prog.level}',
          style: const TextStyle(
            color: GameConfig.textSecondary,
            fontSize: 12,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 220,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: fraction),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                valueColor:
                    const AlwaysStoppedAnimation(GameConfig.coreColor),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
