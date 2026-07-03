import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../services/ads/ad_service.dart';
import '../../services/audio_service.dart';
import '../../services/progression_service.dart';
import '../../services/iap/iap_service.dart';
import '../../services/meta_service.dart';
import '../../services/storage_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/neon_button.dart';
import 'game_screen.dart';
import 'meta_screens.dart';
import 'settings_screen.dart';
import 'store_screen.dart';
import '../widgets/motion.dart';

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
    )..repeat(reverse: true);

    // Kick off consent + ads AFTER the first frame so the menu appears
    // instantly; the game never waits for the network.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await IapService.instance.init();
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
    // Refresh high score / XP / unlocks when coming back from a run.
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
                        const SizedBox(height: 20),
                        _coinsAndSeason(),
                        const SizedBox(height: 6),
                        _title(),
                        const SizedBox(height: 10),
                        const Text(
                          'TAP TO REVERSE • DODGE • COLLECT',
                          style: TextStyle(
                            color: GameConfig.textSecondary,
                            fontSize: 12,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 26),
                        _highScoreAndLevel(),
                        const SizedBox(height: 22),
                        _skinPicker(),
                        const SizedBox(height: 26),
                        ScaleTransition(
                          scale: _pulse
                              .drive(Tween(begin: 1.0, end: 1.06)
                                  .chain(CurveTween(curve: Curves.easeInOut))),
                          child: NeonButton(
                            label: 'PLAY',
                            icon: Icons.play_arrow_rounded,
                            onPressed: _play,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!IapService.instance.removeAdsOwned)
                        NeonButton(
                          label: 'REMOVE ADS',
                          icon: Icons.block,
                          compact: true,
                          colors: const [
                            GameConfig.backgroundAccent,
                            GameConfig.backgroundAccent,
                          ],
                          onPressed: () => _push(const StoreScreen()),
                        ),
                        const SizedBox(height: 14),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          _smallButton('MISSIONS', Icons.flag,
                              () => _push(const MissionsScreen())),
                          const SizedBox(width: 12),
                          _smallButton('BADGES', Icons.workspace_premium,
                              () => _push(const BadgesScreen())),
                          const SizedBox(width: 12),
                          _smallButton('STORE', Icons.storefront,
                              () => _push(const StoreScreen())),
                        ]),
                        const SizedBox(height: 18),
                        ListenableBuilder(
                            listenable: MetaService.instance,
                            builder: (context, child) => const StadiumView()),
                        const SizedBox(height: 18),
                        _statsRow(),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _iconButton(
                              soundOn ? Icons.volume_up : Icons.volume_off,
                              () => setState(() =>
                                  AudioService.instance.soundOn = !soundOn),
                            ),
                            const SizedBox(width: 16),
                            _iconButton(Icons.settings,
                                () => _push(const SettingsScreen())),
                            if (AdService
                                .instance.privacyOptionsRequired) ...[
                              const SizedBox(width: 16),
                              _iconButton(
                                Icons.privacy_tip_outlined,
                                AdService.instance.showPrivacyOptions,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_adsReady) const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Future<void> _push(Widget screen) async {
    AudioService.instance.playButton();
    await Navigator.of(context).push(slideFadeRoute(screen));
    if (mounted) setState(() {});
  }

  Widget _smallButton(String label, IconData icon, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: GameConfig.textSecondary),
      label: Text(label,
          style: const TextStyle(
              color: GameConfig.textSecondary,
              fontSize: 12,
              letterSpacing: 2,
              fontWeight: FontWeight.w700)),
      style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
    );
  }

  Widget _coinsAndSeason() {
    final meta = MetaService.instance;
    return ListenableBuilder(
      listenable: meta,
      builder: (context, child) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.monetization_on, color: GameConfig.orbColor, size: 20),
        const SizedBox(width: 6),
        Text('${meta.coins}',
            style: const TextStyle(
                color: GameConfig.textPrimary, fontWeight: FontWeight.w800)),
        if (meta.capsulesPending > 0) ...[
          const SizedBox(width: 16),
          const Icon(Icons.card_giftcard, color: GameConfig.coreColor, size: 20),
          Text(' ${meta.capsulesPending}',
              style: const TextStyle(
                  color: GameConfig.textPrimary, fontWeight: FontWeight.w800)),
        ],
        if (meta.seasonName != null) ...[
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GameConfig.orbColor)),
            child: Text(meta.seasonName!,
                style: const TextStyle(
                    color: GameConfig.orbColor,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ]),
    );
  }

  Widget _title() {
    return ShaderMask(
      shaderCallback: (bounds) => GameConfig.titleGradient.createShader(bounds),
      child: const Text(
        'ORBIT\nDASH',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 58,
          height: 1.0,
          fontWeight: FontWeight.w900,
          letterSpacing: 8,
        ),
      ),
    );
  }

  Widget _highScoreAndLevel() {
    final prog = ProgressionService.instance;
    final fraction = (prog.xpIntoLevel / prog.xpForNextLevel).clamp(0.0, 1.0);
    return Column(
      children: [
        const Text(
          'BEST',
          style: TextStyle(
            color: GameConfig.textSecondary,
            fontSize: 13,
            letterSpacing: 4,
          ),
        ),
        Text(
          '${StorageService.instance.highScore}',
          style: const TextStyle(
            color: GameConfig.textPrimary,
            fontSize: 42,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'LEVEL ${prog.level}',
          style: const TextStyle(
            color: GameConfig.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          width: 190,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation(GameConfig.coreColor),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '${prog.xpIntoLevel} / ${prog.xpForNextLevel} XP',
          style: const TextStyle(
            color: GameConfig.textSecondary,
            fontSize: 10,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _skinPicker() {
    final prog = ProgressionService.instance;
    return Column(
      children: [
        const Text(
          'BALL',
          style: TextStyle(
            color: GameConfig.textSecondary,
            fontSize: 11,
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < GameConfig.skins.length; i++)
              _skinDot(i, prog),
          ],
        ),
      ],
    );
  }

  Widget _skinDot(int index, ProgressionService prog) {
    final skin = GameConfig.skins[index];
    final unlocked = prog.isSkinUnlocked(index);
    final selected = prog.selectedSkin == index;
    return GestureDetector(
      onTap: () {
        if (!unlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(skin.product != null
                  ? '${skin.name} is in the Store'
                  : 'Reach level ${skin.unlockLevel} to unlock '
                      '${skin.name}'),
              duration: const Duration(seconds: 1),
            ),
          );
          return;
        }
        AudioService.instance.playButton();
        setState(() => prog.selectedSkin = index);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 7),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.12),
            width: selected ? 2.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: skin.glow, blurRadius: 14)]
              : null,
        ),
        child: Center(
          child: unlocked
              ? Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: skin.core,
                    boxShadow: [
                      BoxShadow(
                        color: skin.glow.withValues(alpha: 0.8),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.35)),
                    Text(
                      skin.product != null ? 'SHOP' : 'LV${skin.unlockLevel}',
                      style: TextStyle(
                        fontSize: 7,
                        color: Colors.white.withValues(alpha: 0.35),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _statsRow() {
    final prog = ProgressionService.instance;
    Widget stat(String label, String value) => Column(
          children: [
            Text(value,
                style: const TextStyle(
                  color: GameConfig.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                )),
            Text(label,
                style: const TextStyle(
                  color: GameConfig.textSecondary,
                  fontSize: 9,
                  letterSpacing: 2,
                )),
          ],
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        stat('RUNS', '${prog.runs}'),
        const SizedBox(width: 26),
        stat('ORBS', '${prog.totalOrbs}'),
        const SizedBox(width: 26),
        stat('BEST COMBO', '×${prog.bestCombo}'),
        const SizedBox(width: 26),
        stat('BEST SECTOR', '${prog.bestSector}'),
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
