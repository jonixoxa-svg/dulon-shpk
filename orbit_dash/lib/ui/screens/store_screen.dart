import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../services/audio_service.dart';
import '../../services/iap/iap_service.dart';

/// Honest store: fixed prices, you see exactly what you get. No countdown
/// timers, no fake discounts, no interrupting popups (Families-safe).
class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});
  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  Future<void> _buy(String id) async {
    AudioService.instance.playButton();
    final ok = await IapService.instance.buy(id);
    if (mounted) {
      setState(() {});
      if (ok && IapService.instance.ownsProduct(id)) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchase complete — enjoy!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final iap = IapService.instance;
    const skinNames = {
      'skin_galaxy': ('Galaxy Ball', 'Nebula burst on wins', Color(0xFF7C4DFF)),
      'skin_supernova': ('Supernova', 'Explosive gold celebrations', Color(0xFFFF9E40)),
      'skin_trophy': ('Gold Trophy', 'Champions only', Color(0xFFFFD700)),
      'skin_diamond': ('Diamond Ball', 'Prismatic sparkle trail', Color(0xFFB9F2FF)),
      'skin_watermelon': ('Watermelon', 'Juicy and fun', Color(0xFFFF5470)),
      'bundle_cosmic': ('Cosmic Bundle', 'Galaxy + Supernova + Ice Comet', Color(0xFF00E5FF)),
    };
    return Scaffold(
      backgroundColor: GameConfig.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('STORE',
            style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w800)),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        // Remove Ads hero card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [GameConfig.coreColor, GameConfig.ballGlow]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            const Icon(Icons.block, color: Colors.white, size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('REMOVE ADS',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: 2)),
                Text(
                  iap.removeAdsOwned
                      ? 'Owned — thank you!'
                      : 'No more interstitials, ever.\nContinue & capsule perks become free.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ]),
            ),
            FilledButton(
              onPressed: iap.removeAdsOwned ? null : () => _buy(IapCatalog.removeAds),
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: GameConfig.coreColor),
              child: Text(iap.removeAdsOwned ? '✓' : iap.priceOf(IapCatalog.removeAds),
                  style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        const Text('PREMIUM SKINS',
            style: TextStyle(
                color: GameConfig.textSecondary,
                letterSpacing: 3,
                fontWeight: FontWeight.w800,
                fontSize: 12)),
        const SizedBox(height: 10),
        for (final id in IapCatalog.skinProducts)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: skinNames[id]!.$3,
                  boxShadow: [
                    BoxShadow(color: skinNames[id]!.$3, blurRadius: 12)
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(skinNames[id]!.$1,
                      style: const TextStyle(
                          color: GameConfig.textPrimary,
                          fontWeight: FontWeight.w800)),
                  Text(skinNames[id]!.$2,
                      style: const TextStyle(
                          color: GameConfig.textSecondary, fontSize: 11)),
                ]),
              ),
              iap.ownsProduct(id)
                  ? const Icon(Icons.check_circle, color: GameConfig.pulseColor)
                  : OutlinedButton(
                      onPressed: () => _buy(id),
                      child: Text(iap.priceOf(id),
                          style: const TextStyle(
                              color: GameConfig.textPrimary,
                              fontWeight: FontWeight.w800)),
                    ),
            ]),
          ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.restore, size: 18,
                color: GameConfig.textSecondary),
            label: const Text('Restore purchases',
                style: TextStyle(color: GameConfig.textSecondary)),
            onPressed: () async {
              await IapService.instance.restore();
              if (mounted) setState(() {});
            },
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'All prices are fixed and shown before purchase.\nEarnable skins stay earnable — premium is extra, never an advantage.',
            textAlign: TextAlign.center,
            style: TextStyle(color: GameConfig.textSecondary, fontSize: 11),
          ),
        ),
      ]),
    );
  }
}
