import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:kassongo/actors/Phacochere.dart';
import 'package:kassongo/actors/lion.dart';

class Obstacles extends PositionComponent with CollisionCallbacks {
  final String? name;
  Obstacles({super.position, super.size, this.name}) {
    add(RectangleHitbox(collisionType: CollisionType.passive));
  }
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if ((other is Phacochere) && intersectionPoints.length == 2) {
      final mid =
          (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) *
          0.5;
      final vec = other.absoluteCenter - mid;
      final depth = other.circleHitbox.radius - vec.normalize();
      other.position += vec * depth;
    }
    if ((other is Lion) && intersectionPoints.length == 2) {
      final mid =
          (intersectionPoints.elementAt(0) + intersectionPoints.elementAt(1)) *
          0.5;
      final vec = other.absoluteCenter - mid;
      final depth = other.circleHitbox.radius - vec.normalize();
      other.position += vec * depth;
    }

    super.onCollision(intersectionPoints, other);
  }
}
