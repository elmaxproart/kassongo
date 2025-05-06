import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:kassongo/game/home_page.dart';
import 'game/level.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Plein écran sans title bar ni status bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Forcer l’orientation paysage
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kassongo Game',
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
