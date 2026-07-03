import 'package:flutter/material.dart';

import '../../config/game_config.dart';
import '../../config/strings.dart';
import '../../services/ads/ad_service.dart';
import '../../services/audio_service.dart';
import '../../services/iap/iap_service.dart';
import '../../services/storage_service.dart';

/// Redesigned settings: audio slider (not just mute), haptics, colorblind
/// palette, left-hand mode, language (English + Albanian), restore
/// purchases and privacy. Consistent card layout, 8px spacing grid.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  StorageService get s => StorageService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameConfig.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(Strings.t('settings'),
            style: const TextStyle(letterSpacing: 3, fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _section(Strings.t('audio')),
          _card(Column(children: [
            Row(children: [
              const Icon(Icons.volume_up, color: GameConfig.textSecondary),
              const SizedBox(width: 12),
              Expanded(child: Text(Strings.t('effects_volume'),
                  style: const TextStyle(color: GameConfig.textPrimary))),
            ]),
            Slider(
              value: s.soundOn ? s.volume : 0,
              activeColor: GameConfig.ballColor,
              onChanged: (v) => setState(() {
                s.volume = v;
                s.soundOn = v > 0;
                if (v > 0) AudioService.instance.playButton();
              }),
            ),
          ])),
          _section(Strings.t('accessibility')),
          _toggle(Icons.vibration, Strings.t('haptics'), s.hapticsOn,
              (v) => setState(() => s.hapticsOn = v)),
          _toggle(Icons.contrast, Strings.t('colorblind'), s.colorblind,
              (v) => setState(() => s.colorblind = v)),
          _toggle(Icons.swap_horiz, Strings.t('left_hand'), s.leftHand,
              (v) => setState(() => s.leftHand = v)),
          _section(Strings.t('language')),
          _card(Row(children: [
            _langChip('English', 'en'),
            const SizedBox(width: 8),
            _langChip('Shqip', 'sq'),
          ])),
          const SizedBox(height: 16),
          _card(Column(children: [
            _link(Icons.restore, Strings.t('restore_purchases'), () async {
              final messenger = ScaffoldMessenger.of(context);
              await IapService.instance.restore();
              messenger.showSnackBar(
                  const SnackBar(content: Text('Purchases restored')));
            }),
            if (AdService.instance.privacyOptionsRequired)
              _link(Icons.privacy_tip_outlined, Strings.t('privacy'),
                  AdService.instance.showPrivacyOptions),
          ])),
        ],
      ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: Text(t.toUpperCase(),
            style: const TextStyle(
                color: GameConfig.textSecondary,
                letterSpacing: 3,
                fontSize: 12,
                fontWeight: FontWeight.w800)),
      );

  Widget _card(Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      );

  Widget _toggle(IconData icon, String label, bool value, ValueChanged<bool> onChanged) =>
      _card(Row(children: [
        Icon(icon, color: GameConfig.textSecondary),
        const SizedBox(width: 12),
        Expanded(child: Text(label,
            style: const TextStyle(color: GameConfig.textPrimary))),
        Switch(
            value: value,
            activeThumbColor: GameConfig.ballColor,
            onChanged: (v) {
              onChanged(v);
              AudioService.instance.playButton();
            }),
      ]));

  Widget _link(IconData icon, String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Icon(icon, color: GameConfig.textSecondary, size: 20),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(color: GameConfig.textPrimary)),
          ]),
        ),
      );

  Widget _langChip(String label, String code) {
    final selected = s.language == code;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          s.language = code;
          AudioService.instance.playButton();
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? GameConfig.ballColor.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? GameConfig.ballColor : Colors.transparent),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: selected
                        ? GameConfig.ballColor
                        : GameConfig.textSecondary,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}
