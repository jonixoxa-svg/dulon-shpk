import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../game/orbit_dash_game.dart';
import '../../services/ad_service.dart';
import '../../services/storage_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neon_button.dart';

/// Game-over screen: score, best score, rewarded-ad offers (continue once
/// per run + double score), retry and home. Banner ad at the bottom.
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

  bool get _canContinue =>
      !game.continueUsed &&
      _secondsLeft > 0 &&
      AdService.instance.isRewardedReady;

  @override
  void initState() {
    super.initState();
    if (!game.continueUsed && AdService.instance.isRewardedReady) {
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
    AdService.instance.maybeShowInterstitial(onDismissed: () {
      _busy = false;
      game.resetToReady();
    });
  }

  void _home() {
    if (_busy) return;
    _busy = true;
    _countdown?.cancel();
    AdService.instance.maybeShowInterstitial(onDismissed: () {
      _busy = false;
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: GameConfig.background.withValues(alpha: 0.82),
      child: Column(
        children: [
          Expanded(
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  const Text(
                    'GAME OVER',
                    style: TextStyle(
                      color: GameConfig.obstacleColor,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(
                            color: GameConfig.obstacleColor, blurRadius: 24),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _scoreBlock(),
                  const Spacer(flex: 2),
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
                    const Text(
                      'watch an ad to keep this run',
                      style: TextStyle(
                        color: GameConfig.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  if (!_scoreDoubled && AdService.instance.isRewardedReady)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
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
                  const Spacer(flex: 2),
                ],
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
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '★ NEW BEST ★',
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
            fontSize: 72,
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
        const SizedBox(height: 8),
        Text(
          'BEST  ${StorageService.instance.highScore}',
          style: const TextStyle(
            color: GameConfig.textSecondary,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
