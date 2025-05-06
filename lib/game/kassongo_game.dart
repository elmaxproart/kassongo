import 'package:audioplayers/audioplayers.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/input.dart';
import 'package:kassongo/game/level.dart';
import 'package:flame/components.dart';

import '../actors/Phacochere.dart';

class KassongoGame extends FlameGame
    with HasCollisionDetection, WidgetsBindingObserver {
  final void Function(String message)? onGameEnd;
  final String selectedCharacter;
  Level? level;

  SpriteButtonComponent? pauseButton;
  SpriteButtonComponent? quitButton;
  SpriteButtonComponent? jumpButton;

  bool isPaused = false;

  AudioPlayer? audioPlayer;
  late TextComponent victoryText;

  KassongoGame({this.onGameEnd, required this.selectedCharacter});

  String tempText = '';
  Color currentPhacoColor = Color(0xFF463206);
  @override
  Color backgroundColor() => currentPhacoColor;
  // void changePhacoColor(Color newColor) {
  //   currentPhacoColor = newColor;
  // }

  @override
  Future<void> onLoad() async {
    // Enregistrer le cycle de vie
    WidgetsBinding.instance.addObserver(this);

    await images.loadAll([
      "lion.png",
      "phacochere.png",
      "dust.png",
      "pause.png",
      "play.png",
      "quit.png",
      "dead.jpg",
    ]);

    loadLevel("chunk_2.tmx");

    audioPlayer = AudioPlayer();
    await audioPlayer!.setReleaseMode(ReleaseMode.loop);
    await audioPlayer!.setVolume(0.7);
    await audioPlayer!.play(AssetSource('audio/kas.mp3'), volume: 0.7);

    addButtons();

    return super.onLoad();
  }

  void _stopBackgroundSound() {
    audioPlayer?.stop();
  }

  @override
  void onRemove() {
    WidgetsBinding.instance.removeObserver(this);
    _stopBackgroundSound();
    audioPlayer?.dispose();
    level?.removeFromParent();
    super.onRemove();
  }

  // Gérer le cycle de vie de l'application
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // Redémarrer le jeu ou recharger le niveau
      reloadGame();
    }
  }

  void reloadGame() {
    // Supprimer le niveau actuel et le recharger
    level?.removeFromParent();
    loadLevel("chunk_2.tmx");
    addButtons();
    _stopBackgroundSound();
    audioPlayer = AudioPlayer();
    audioPlayer!.setReleaseMode(ReleaseMode.loop);
    audioPlayer!.setVolume(0.7);
    audioPlayer!.play(AssetSource('audio/kas.mp3'), volume: 0.7);
  }

  void loadLevel(String levelName) {
    level?.removeFromParent();
    level = Level(levelName: levelName, onGameEnd: onGameEnd);

    world.add(level!);
  }

  void addButtons() {
    if (pauseButton == null && quitButton == null) {
      pauseButton = SpriteButtonComponent(
        button: Sprite(images.fromCache('pause.png')),
        buttonDown: Sprite(images.fromCache('play.png')),
        size: Vector2(50, 50),
        position: Vector2(size.x - 60, 10),
        onPressed: togglePause,
        priority: 500,
      );

      quitButton = SpriteButtonComponent(
        button: Sprite(images.fromCache('quit.png')),
        buttonDown: Sprite(images.fromCache('quit.png')),
        size: Vector2(50, 50),
        position: Vector2(10, 10),

        onPressed: () {
          onGameEnd?.call("Game exited");
        },
        priority: 500,
      );

      add(pauseButton!);
      add(quitButton!);

      final textPaint = TextPaint(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );

      if ((selectedCharacter == "Lion")) {
        tempText = "vous :Lion (BUT:manger kassaongo)";
      } else if ((selectedCharacter == "Phacochere")) {
        tempText = "vous :kassongo (BUT:fuire)";
      } else {
        tempText = "kassaongo";
      }
      victoryText = TextComponent(
        text: tempText,
        textRenderer: textPaint,
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y - 35), // milieu en bas
        priority: 500,
      );

      add(victoryText);
    }

    pauseButton?.position = Vector2(size.x - 60, 10);
    quitButton?.position = Vector2(10, 10);
  }

  void togglePause() {
    isPaused = !isPaused;

    if (isPaused) {
      pauseEngine();
      audioPlayer?.pause();
    } else {
      resumeEngine();
      audioPlayer?.resume();
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);
    pauseButton?.position = Vector2(size.x - 60, size.y - 60);
    quitButton?.position = Vector2(10, size.y - 60);
  }
}

class GameOverMenu extends StatelessWidget {
  final FlameGame game;
  GameOverMenu({required this.game, super.key});

  @override
  final Map<String, Widget Function(BuildContext)> overlayBuilderMap = {
    'GameOver': (context) => const GameOverScreen(),
    // ajoute les autres overlays ici si besoin
  };
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Fin de partie',
              style: TextStyle(color: Colors.white, fontSize: 32),
            ),
            const SizedBox(height: 20),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Rejouer"),
              onPressed: () {
                game.overlays.remove('GameOverMenu');
                game.resumeEngine(); // si le jeu a été mis en pause
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellowAccent,
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.black54,
        child: const Text(
          'Game Over',
          style: TextStyle(color: Colors.white, fontSize: 32),
        ),
      ),
    );
  }
}
