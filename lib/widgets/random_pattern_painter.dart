/*
 * Copyright (c) 2019 by Yann39.
 *
 * This file is part of CCTeam application.
 *
 * CCTeam is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * CCTeam is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CCTeam. If not, see <http://www.gnu.org/licenses/>.
 */

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Two reference blue tones shared by every detail header that uses the
/// random pattern background.
const Color kPatternHeaderColorLight = Color(0xFF56CCF2); // light blue
const Color kPatternHeaderColorDark = Color(0xFF2F80ED); // medium blue

/// Custom painter that draws a procedurally generated geometric pattern
/// (translucent circles + triangles) over a two-color gradient. The same
/// [seed] always produces the same pattern, so each item (news, event…)
/// keeps a stable visual identity tied to its id; the gradient direction
/// and the shape layout still vary from one seed to another.
class RandomPatternPainter extends CustomPainter {
  final int seed;
  final Color color1;
  final Color color2;

  RandomPatternPainter({
    required this.seed,
    this.color1 = kPatternHeaderColorLight,
    this.color2 = kPatternHeaderColorDark,
  });

  /// Available gradient directions; one is picked per seed so two different
  /// items can have a different orientation.
  static const List<List<Alignment>> _gradientDirections = <List<Alignment>>[
    [Alignment.topLeft, Alignment.bottomRight],
    [Alignment.topCenter, Alignment.bottomCenter],
    [Alignment.topRight, Alignment.bottomLeft],
    [Alignment.centerLeft, Alignment.centerRight],
    [Alignment.bottomLeft, Alignment.topRight],
    [Alignment.bottomCenter, Alignment.topCenter],
    [Alignment.bottomRight, Alignment.topLeft],
    [Alignment.centerRight, Alignment.centerLeft],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random random = math.Random(seed);
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // pick a gradient direction and color order based on the seed, so the
    // gradient looks different from one item to another
    final List<Alignment> direction =
        _gradientDirections[random.nextInt(_gradientDirections.length)];
    final bool swapColors = random.nextBool();
    final Color c1 = swapColors ? color2 : color1;
    final Color c2 = swapColors ? color1 : color2;

    // background gradient
    final Paint bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [c1, c2],
        begin: direction[0],
        end: direction[1],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final Paint shapePaint = Paint()..style = PaintingStyle.fill;

    // translucent circles for organic feel
    final int circleCount = 4 + random.nextInt(4);
    for (int i = 0; i < circleCount; i++) {
      shapePaint.color = Colors.white.withValues(
        alpha: 0.05 + random.nextDouble() * 0.10,
      );
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        20.0 + random.nextDouble() * 60.0,
        shapePaint,
      );
    }

    // rotated triangles for a geometric accent
    final int triangleCount = 3 + random.nextInt(4);
    for (int i = 0; i < triangleCount; i++) {
      shapePaint.color = Colors.white.withValues(
        alpha: 0.04 + random.nextDouble() * 0.08,
      );
      final double cx = random.nextDouble() * size.width;
      final double cy = random.nextDouble() * size.height;
      final double r = 30.0 + random.nextDouble() * 70.0;
      final double rotation = random.nextDouble() * math.pi * 2;

      final Path path = Path();
      for (int j = 0; j < 3; j++) {
        final double angle = rotation + j * (math.pi * 2 / 3);
        final double x = cx + r * math.cos(angle);
        final double y = cy + r * math.sin(angle);
        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, shapePaint);
    }
  }

  @override
  bool shouldRepaint(covariant RandomPatternPainter oldDelegate) {
    return oldDelegate.seed != seed ||
        oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2;
  }
}
