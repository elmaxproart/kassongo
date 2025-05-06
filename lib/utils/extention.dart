import 'package:flame/sprite.dart';

extension SpriteAnimationCurrentFrame on SpriteAnimation {
  // Retourne l'index de la frame actuelle dans l'animation
  int get currentFrame {
    // Accède à la frame actuelle via currentFrame (Flame expose cette méthode)
    return currentFrameIndex;
  }

  // Retourne le nombre total de frames dans l'animation
  int get amount {
    // Nombre total de frames dans l'animation
    return frames.length;
  }

  int get currentFrameIndex => currentFrame;
}
