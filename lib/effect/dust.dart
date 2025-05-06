import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:kassongo/actors/Phacochere.dart';
import 'package:kassongo/utils/extention.dart';

enum DustStates { appear, idle }

class Dust extends SpriteAnimationGroupComponent<DustStates>
    with CollisionCallbacks {
  final Image image;
  late final SpriteSheet spriteSheet;

  static Vector2 frameSize = Vector2(100, 100);
  static const int columns = 6;
  bool isAppearFinished = false;
  late Phacochere phacochere;
  // Variables pour gérer le mouvement et la gravité
  Vector2 velocity = Vector2.zero();
  static const double _gravity = 9.8;
  static const double _moveSpeed = 500;
  static const _maxSpeed = 50;

  Dust(this.image, {super.position, super.size}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    spriteSheet = SpriteSheet(image: image, srcSize: frameSize);

    animations = {
      DustStates.appear: SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 36,
          stepTime: 0.12,
          textureSize: frameSize,
        ),
      ),
      DustStates.idle: SpriteAnimation.fromFrameData(
        image,
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: 0.5,
          textureSize: frameSize,
        ),
      ),
    };

    current = DustStates.appear;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt < 0.03) {
      velocity.y += _gravity * dt;

      // Gérer le mouvement (par exemple, aller à droite si sur le sol)
      if (hasTouchedGround) {
        velocity.x = _moveSpeed;
      } else {
        velocity.x = 0; // Arrête le mouvement si le sprite est en l'air
      }

      // Mettre à jour la position en fonction de la vitesse
      position += velocity * dt;
    }
    // Appliquer la gravité

    super.update(dt);
  }

  // Cette méthode semble être un ajout pour gérer des animations supplémentaires
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

  // Calculer l'offset pour obtenir la bonne frame du sprite
  Vector2 getFrameOffset(int frameIndex) {
    final x = (frameIndex % columns) * frameSize.x;
    final y = (frameIndex ~/ columns) * frameSize.y;
    return Vector2(x, y);
  }

  // Vérifie si le sprite a touché le sol
  bool get hasTouchedGround {
    // Implémentation basique : tu peux ajouter plus de logique selon ton jeu
    return position.y >= 0; // Cela signifie que le sprite est au sol
  }
}
