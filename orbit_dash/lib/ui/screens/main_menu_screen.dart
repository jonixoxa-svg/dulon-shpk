import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../services/ad_service.dart';
import '../../services/audio_service.dart';
import '../../services/consent_service.dart';
import '../../services/storage_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neon_button.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _adsReady = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.75,
      upperBound: 1.0,
    )..repeat(reverse: true);

    // Kick off consent + ads AFTER the first frame so the menu appears
    // instantly; the game never waits for the network.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AdService.instance.init();
      if (mounted) setState(() => _adsReady = AdService.instance.isReady);
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GameScreen()),
    );
    // Refresh high score when coming back from a run.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final soundOn = AudioService.instance.soundOn;
    return Scaffold(
      backgroundColor: GameConfig.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.2,
            colors: [GameConfig.backgroundAccent, GameConfig.background],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    _title(),
                    const SizedBox(height: 12),
                    const Text(
                      'TAP TO REVERSE • DODGE • COLLECT',
                      style: TextStyle(
                        color: GameConfig.textSecondary,
                        fontSize: 12,
                        letterSpacing: 3,
                      ),
                    ),
                    const Spacer(flex: 2),
                    _highScore(),
                    const Spacer(flex: 2),
                    ScaleTransition(
                      scale: _pulse.drive(Tween(begin: 1.0, end: 1.06)),
                      child: NeonButton(
                        label: 'PLAY',
                        icon: Icons.play_arrow_rounded,
                        onPressed: _play,
                      ),
                    ),
                    const SizedBox(height: 20),
                    NeonButton(
                      label: 'REMOVE ADS',
                      icon: Icons.block,
                      compact: true,
                      colors: const [
                        GameConfig.backgroundAccent,
                        GameConfig.backgroundAccent,
                      ],
                      onPressed: () {
                        // TODO(you): hook up in-app purchase here later.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Coming soon!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    const Spacer(flex: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _iconButton(
                          soundOn ? Icons.volume_up : Icons.volume_off,
                          () => setState(() =>
                              AudioService.instance.soundOn = !soundOn),
                        ),
                        if (ConsentService
                            .instance.privacyOptionsRequired) ...[
                          const SizedBox(width: 16),
                          _iconButton(
                            Icons.privacy_tip_outlined,
                            ConsentService.instance.showPrivacyOptions,
                          ),
                        ],
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            if (_adsReady) const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _title() {
    return ShaderMask(
      shaderCallback: (bounds) =>
          GameConfig.titleGradient.createShader(bounds),
      child: const Text(
        'ORBIT\nDASH',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 64,
          height: 1.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 8,
        ),
      ),
    );
  }

  Widget _highScore() {
    return Column(
      children: [
        const Text(
          'BEST',
          style: TextStyle(
            color: GameConfig.textSecondary,
            fontSize: 14,
            letterSpacing: 4,
          ),
        ),
        Text(
          '${StorageService.instance.highScore}',
          style: const TextStyle(
            color: GameConfig.textPrimary,
            fontSize: 44,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: () {
        AudioService.instance.playButton();
        onTap();
      },
      icon: Icon(icon, color: GameConfig.textSecondary, size: 28),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
