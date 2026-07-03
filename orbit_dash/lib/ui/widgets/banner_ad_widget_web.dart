import 'package:flutter/material.dart';

/// Web-demo stand-in for the AdMob banner: renders nothing and takes no
/// space. Must expose the same class name as banner_ad_widget_io.dart.
class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
