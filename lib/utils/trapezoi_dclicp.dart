import 'dart:ui';

import 'package:flutter/cupertino.dart';

class TrapezoidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.1, 0); // coin supérieur gauche
    path.lineTo(size.width, 0); // coin supérieur droit
    path.lineTo(size.width * 0.9, size.height); // coin inférieur droit
    path.lineTo(0, size.height); // coin inférieur gauche
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
