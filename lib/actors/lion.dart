import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import '../effect/dust.dart';
import '../game/level.dart';
import '../obstacles/obstacles.dart';
import 'Phacochere.dart';

enum LionStates { idle, run, dead, attack }

bool hasTouchedGround = false;

class Lion extends SpriteAnimationGroupComponent<LionStates>
    with CollisionCallbacks, HasGameReference {
  Lion(this.image, {super.position, super.size}) : super(anchor: Anchor.center);

  final Image image;
  static const _gravity = 100.0;
  static const _maxSpeed = 100.0;

  late final double _moveSpeed = Random().nextBool() ? 200.0 : 110.0;
  final CircleHitbox circleHitbox = CircleHitbox();
  static Vector2 frameSize = Vector2(136.33, 86.8);

  late final SpriteSheet spriteSheet;
  final velocity = Vector2.zero();

  @override
  Future<void> onLoad() async {
    add(CircleHitbox(collisionType: CollisionType.active));

    spriteSheet = SpriteSheet(image: image, srcSize: frameSize);

    animations = {
      LionStates.idle: spriteSheet.createAnimation(
        row: 0,
        from: 0,
        to: 1,
        stepTime: 0.08,
      ),
      LionStates.run: spriteSheet.createAnimation(
        row: 1,
        from: 0,
        to: 3,
        stepTime: 0.15,
      ),
      LionStates.attack: spriteSheet.createAnimation(
        row: 4,
        from: 0,
        to: 2,
        stepTime: 0.1,
      ),
    };

    current = LionStates.idle;
    return super.onLoad();
  }

  Level? level;
  @override
  void update(double dt) {
    if (hasTouchedGround) {
      velocity.x = _moveSpeed;
    } else {
      velocity.x = 0;
    }
    level?.checkWinner();
    position += velocity * dt;

    super.update(dt);
  }

  SpriteAnimation loadSequence(
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
        texturePosition: getFrameOffset(startFrame),
      ),
    );
  }

  Vector2 getFrameOffset(int frameIndex) {
    const int columns = 3;
    final x = (frameIndex % columns) * frameSize.x;
    final y = (frameIndex ~/ columns) * frameSize.y;
    return Vector2(x, y);
  }

  static final _left = Vector2(1, 0);
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    if (other is Phacochere) {
      final vec = other.absoluteCenter - absoluteCenter;
      if (_left.dot(vec) > 0.85) {
        current = LionStates.attack;
      } else {
        current = LionStates.dead;
        game.pauseEngine();
        print("Phacochere est mort !");
        final dust = Dust(
          game.images.fromCache("dust.png"),
          position: position.clone(),
          size: Vector2(50, 50),
        );
        parent?.add(dust);
        print("Le Phacochère est mort !");
      }
    }

    super.onCollisionStart(intersectionPoints, other);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Obstacles) {
      velocity.y = 0;
      position.y = other.position.y - size.y / 2;

      hasTouchedGround = true;
      current = LionStates.run;
    }

    if (other is Phacochere) {
      other.current = PhacochereStates.dead;
      game.camera.stop();
      print("Lion touched Phacochere!");

      final dust = Dust(
        game.images.fromCache("dust.png"),
        position: position.clone(),
        size: Vector2(50, 50),
      );
      parent?.add(dust);
    }

    super.onCollision(intersectionPoints, other);
  }
}
