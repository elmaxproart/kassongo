import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:audioplayers/audioplayers.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:kassongo/game/level.dart';

import '../effect/dust.dart';
import '../game/kassongo_game.dart';
import '../obstacles/obstacles.dart';
import 'lion.dart';

enum PhacochereStates { idle, run, dead, win }

bool hasTouchedGround = false;

class Phacochere extends SpriteAnimationGroupComponent<PhacochereStates>
    with CollisionCallbacks, HasGameReference {
  final void Function(String message)? onGameEnd;

  Phacochere(this.image, {this.onGameEnd, super.position, super.size})
    : super(anchor: Anchor.center);

  final ui.Image image;

  static const _gravity = 100.0;
  static const _maxSpeed = 100.0;
  late final double _moveSpeed = Random().nextBool() ? 200.0 : 100.0;
  double get moveSpeed => _moveSpeed;

  static Vector2 frameSize = Vector2(256, 182);
  static const int columns = 4;
  bool isFlipped = false;

  late final SpriteSheet spriteSheet;
  final velocity = Vector2.zero();
  final CircleHitbox circleHitbox = CircleHitbox();

  Level? level;

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(collisionType: CollisionType.active));

    spriteSheet = SpriteSheet(image: image, srcSize: frameSize);

    animations = {
      PhacochereStates.idle: _loadSequence(0, 0, stepTime: 0.12),
      PhacochereStates.run: _loadSequence(12, 15, stepTime: 0.1),
      PhacochereStates.dead: _loadSequence(0, 3, stepTime: 0.12),
      PhacochereStates.win: _loadSequence(4, 7, stepTime: 0.12),
    };

    current = PhacochereStates.idle;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    velocity.y += _gravity * dt;
    if (hasTouchedGround) {
      velocity.x = _moveSpeed;
      position += velocity * dt;
    } else {
      velocity.x = 0;
    }
    if (current == PhacochereStates.dead) {
      velocity.x = 0;
    }
    if (position.x >= (level?.endPositionX ?? double.infinity)) {
      win();
    }

    super.update(dt);
  }

  SpriteAnimation _loadSequence(
    int startFrame,
    int endFrame, {
    required double stepTime,
  }) {
    final frameCount = endFrame - startFrame + 1;
    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: frameCount,
        stepTime: stepTime,
        textureSize: frameSize,
        texturePosition: _getFrameOffset(startFrame),
      ),
    );
  }

  Vector2 _getFrameOffset(int frameIndex) {
    final x = (frameIndex % columns) * frameSize.x;
    final y = (frameIndex ~/ columns) * frameSize.y;
    return Vector2(x, y);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Obstacles) {
      if (other.name == 'Fin') {
        win();
        return; // Ne continue pas, sinon il s'arrête au sol
      }

      velocity.y = 0;
      position.y = other.position.y - size.y / 2;
      hasTouchedGround = true;
      current = PhacochereStates.run;
    }

    if (other is Lion) {
      dead();
      _showGameOverDialog();
    }

    super.onCollision(intersectionPoints, other);
  }

  void _showGameOverDialog() {
    if (onGameEnd != null) {
      onGameEnd!("Phacochere est mort !");
    }
  }

  void win() {
    current = PhacochereStates.win;
    game.pauseEngine();
    print("Phacochere a gagné !");
    final dust = Dust(
      game.images.fromCache("dust.png"),
      position: position.clone(),
      size: Vector2(50, 50),
    );
    parent?.add(dust);
  }

  void dead() {
    game.pauseEngine();
    onGameEnd?.call("Game Over");
    current = PhacochereStates.dead;

    // Joue le son de défaite

    String phacoText;
    Color phaColor;
    String phacoAudioPath;

    if ((game as KassongoGame).selectedCharacter == "Lion") {
      phacoText = "BRAVO VOUS L'AVEZ EU!";
      phaColor = Colors.green;
      phacoAudioPath = "audio/win.mp3";
    } else if ((game as KassongoGame).selectedCharacter == "Phacochere") {
      phacoText = "OOH NON VOUS ÊTES MORT !";
      phaColor = Colors.red;
      phacoAudioPath = "audio/fail.mp3";
    } else {
      phacoText = "PHACOCHERE MANGÉ !!";
      phaColor = Colors.red;
      phacoAudioPath = "audio/fail.mp3";
    }
    final AudioPlayer audioPlayer = AudioPlayer();
    audioPlayer.play(AssetSource(phacoAudioPath));
    audioPlayer.setVolume(0.9);
    (game as KassongoGame).victoryText
      ..text = phacoText
      ..textRenderer = TextPaint(
        style: TextStyle(
          fontSize: 30,
          color: phaColor,
          fontWeight: FontWeight.bold,
        ),
      );
    // (game as KassongoGame).changePhacoColor(ui.Color.fromARGB(100, 83, 6, 0));

    final dust = Dust(
      game.images.fromCache("dust.png"),
      position: position.clone(),
      size: Vector2(50, 50),
    );
    parent?.add(dust);
  }

  void flipDirection() {
    isFlipped = !isFlipped;
    flipHorizontally();
  }
}
