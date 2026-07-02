import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config/game_config.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';
import 'ui/screens/main_menu_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Portrait-only: the game is designed around a vertical play field.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Local storage + sounds are fast and offline; ads/consent are started
  // later from the main menu so nothing blocks startup.
  await StorageService.instance.init();
  AudioService.instance.init(); // fire and forget

  runApp(const OrbitDashApp());
}

class OrbitDashApp extends StatelessWidget {
  const OrbitDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orbit Dash',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: GameConfig.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: GameConfig.ballColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainMenuScreen(),
    );
  }
}
