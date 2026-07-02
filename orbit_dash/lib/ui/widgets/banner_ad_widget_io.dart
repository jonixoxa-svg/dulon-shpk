import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../services/ads/ad_service_io.dart';

/// A self-contained banner slot. Reserves a fixed banner-sized box so the
/// layout never jumps, shows the ad once loaded, and collapses gracefully
/// (empty transparent box) when ads are unavailable or fail to load.
///
/// Only ever placed on the main menu and the game-over screen — never
/// during gameplay.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _createBanner();
  }

  void _createBanner() {
    _banner = AdService.instance.createBanner(
      onLoaded: (_) {
        if (mounted) setState(() => _loaded = true);
      },
      onFailed: (ad, error) {
        debugPrint('Banner failed to load: ${error.message}');
        ad.dispose();
        if (mounted) {
          setState(() {
            _banner = null;
            _loaded = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: AdSize.banner.height.toDouble(),
        width: double.infinity,
        child: _loaded && banner != null
            ? Center(
                child: SizedBox(
                  width: banner.size.width.toDouble(),
                  height: banner.size.height.toDouble(),
                  child: AdWidget(ad: banner),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
