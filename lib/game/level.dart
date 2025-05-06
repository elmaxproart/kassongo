import 'dart:async';

import 'package:flame/camera.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:kassongo/actors/lion.dart';
import 'package:kassongo/actors/phacochere.dart';
import 'package:kassongo/effect/dust.dart';
import 'package:kassongo/game/kassongo_game.dart';

import '../obstacles/obstacles.dart';
import 'package:flutter/material.dart';

class Level extends Component with HasGameReference {
  final void Function(String message)? onGameEnd;

  Level({required this.levelName, this.onGameEnd});
  final Map<String, Widget Function(BuildContext)> overlayBuilderMap = {
    'GameOver': (context) => const GameOverScreen(),
  };
  final String levelName;
  late final Vector2 levelSize;
  late Phacochere phacochere;
  late Lion lion;
  late Dust dust;
  late final double endPositionX;

  SpriteButtonComponent? pauseButton;
  SpriteButtonComponent? quitButton;

  bool gameEnded = false;

  @override
  FutureOr<void> onLoad() async {
    final map = await TiledComponent.load(levelName, Vector2.all(11));
    levelSize = map.size;
    endPositionX = levelSize.x;

    final screenSize = game.size;
    game.camera.viewport = FixedResolutionViewport(resolution: screenSize);
    game.camera.moveBy(game.camera.viewport.virtualSize * 0.5);
    game.camera.setBounds(Rectangle.fromLTWH(0, 0, levelSize.x, levelSize.y));

    add(map);

    await loadActors(map);
    await loadObtacles(map);
    await loadDecorations(map);
    return super.onLoad();
  }

  bool isPaused = false;
  void togglePause() {
    isPaused = !isPaused;

    if (isPaused) {
      FlameAudio.bgm.pause();
      (game as KassongoGame).pauseEngine();
    } else {
      FlameAudio.bgm.resume();
      (game as KassongoGame).resumeEngine();
    }
  }

  @override
  void onGameResize(Vector2 canvasSize) {
    super.onGameResize(canvasSize);

    pauseButton?.position = Vector2(
      game.size.x - 60,
      10,
    ); // Use game.size instead of size
    quitButton?.position = Vector2(10, 10);
  }

  Future<void> loadDecorations(TiledComponent map) async {
    final decorations =
        map.tileMap.getLayer<ObjectGroup>("Decorations")?.objects;

    if (decorations != null) {
      for (final decoration in decorations) {
        if (decoration.name case "Dust") {
          final dust = Dust(
            game.images.fromCache("dust.png"),
            position: Vector2(decoration.x, decoration.y),
            size: Vector2(100, 100),
          );
          add(dust);
        } else if (decoration.name case "Porte") {
          final spawnId = decoration.properties.getValue("spawPoint");
          final spawObj = decorations.firstWhere((e) => e.id == spawnId);

          map.add(
            RectangleHitbox(
                collisionType: CollisionType.passive,
                position: Vector2(decoration.x, decoration.y),
                size: Vector2(decoration.height, decoration.width),
              )
              ..onCollisionCallback =
                  (_, _) => spawCallBack(Vector2(spawObj.x, spawObj.y)),
          );
        } else if (decoration.name case "flag") {
          map.add(
            RectangleHitbox(
              collisionType: CollisionType.passive,
              position: Vector2(200, 200),
              size: Vector2(decoration.height, decoration.width),
            )..onCollisionCallback = (_, _) => lionStop(),
          );
        } else {
          return;
        }
      }
    }
  }

  Future<void> loadActors(TiledComponent map) async {
    final actors = map.tileMap.getLayer<ObjectGroup>("Actors")?.objects;

    if (actors == null) return;

    for (final actor in actors) {
      final position = Vector2(actor.x, actor.y);

      switch (actor.name) {
        case "Lion":
          print("Lion position: $position");

          lion = Lion(
            game.images.fromCache("lion.png"),
            position: position,
            size: Vector2(197, 197),
          );
          add(lion);
          break;

        case "Phacochere":
          print("Phacochere position: $position");

          phacochere = Phacochere(
            game.images.fromCache("phacochere.png"),
            position: position,
            size: Vector2(180, 126),
          );
          game.camera.setBounds(
            Rectangle.fromPoints(
              game.camera.viewport.virtualSize * 0.5,
              Vector2(
                (levelSize.x + (game.camera.viewport.virtualSize.x - 450)) -
                    game.camera.viewport.virtualSize.x,
                game.camera.viewport.virtualSize.y * 0.5,
              ),
            ),
          );
          //si le phacochere est a la fin de la map, il gagne
          checkWinner();
          if (phacochere.position.x >= levelSize.x) {
            phacochere.dead();
            print("Le Phacochère a gagné !");
            phacochere.position.y = 310;
            game.pauseEngine();
            game.camera.stop();
            game.camera.follow(lion);
          }

          game.camera.follow(phacochere);
          add(phacochere);
          break;

        default:
          print("Acteur inconnu : ${actor.name}");
      }
    }
  }

  Future<void> loadObtacles(TiledComponent map) async {
    final obstacles = map.tileMap.getLayer<ObjectGroup>("Obstacles")?.objects;
    if (obstacles != null) {
      for (final obstacles in obstacles) {
        add(
          Obstacles(
            position: Vector2(obstacles.x, 310),
            size: Vector2(obstacles.width, obstacles.height),
          ),
        );
      }
    }
  }

  void showPopup(String message) {
    print(message);
  }

  void checkWinner() {
    if (phacochere.position.x >= levelSize.x) {
      if (!gameEnded) {
        showPopup("Le Phacochère a gagné !");
        gameEnded = true;
      }
    }
    if (lion.position.x >= phacochere.position.x) {
      if (!gameEnded) {
        showPopup("Le Lion a gagné !");
        gameEnded = true;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Vérifie si le phacochère sort du terrain (à droite)
    if (phacochere.position.x > levelSize.x && !gameEnded) {
      phacochere.dead(); // Animation ou état de victoire
      showPopup("Le Phacochère a gagné !");
      game.pauseEngine();

      game.camera.stop();

      final String phacoText;
      final Color phacoColor;
      final String phacoAudioPath;

      if ((game as KassongoGame).selectedCharacter == "Lion") {
        phacoText = "OOH NON PHACOCHERE ENFUI !";
        phacoColor = Colors.red;
        phacoAudioPath = 'audio/fail.mp3';
      } else if ((game as KassongoGame).selectedCharacter == "Phacochere") {
        phacoText = "VICTOIRE PHACOCHERE ENFUI !";
        phacoColor = Colors.green;
        phacoAudioPath = 'audio/win.mp3';
      } else {
        phacoText = "PHACOCHERE ENFUI !";
        phacoColor = Colors.blue;
        phacoAudioPath = 'audio/win.mp3';
      }
      final AudioPlayer audioPlayer = AudioPlayer();
      audioPlayer.play(AssetSource(phacoAudioPath));
      audioPlayer.setVolume(0.9);
      (game as KassongoGame).victoryText
        ..text = phacoText
        ..textRenderer = TextPaint(
          style: TextStyle(
            fontSize: 30,
            color: phacoColor,
            fontWeight: FontWeight.bold,
          ),
        );
      final dust = Dust(
        game.images.fromCache("dust.png"),
        position: phacochere.position,
        size: Vector2(50, 50),
      );
      phacochere.flipDirection();
      Future.delayed(const Duration(seconds: 2), () {
        phacochere.flipDirection();
      });
      parent?.add(dust);
      game.camera.follow(lion);
      gameEnded = true;
    }
  }

  Future<void> spawCallBack(Vector2 vector2) async {
    phacochere.position = vector2;
  }

  void lionStop() {
    game.pauseEngine();
  }
}
