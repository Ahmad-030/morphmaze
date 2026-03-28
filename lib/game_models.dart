import 'dart:math';
import 'package:flutter/material.dart';
import 'app_theme.dart';

enum ShapeType { circle, square, triangle }

class ShapeConfig {
  final ShapeType type;
  final Color color;
  final String label;
  final IconData icon;

  const ShapeConfig({
    required this.type,
    required this.color,
    required this.label,
    required this.icon,
  });

  static const List<ShapeConfig> all = [
    ShapeConfig(
      type: ShapeType.circle,
      color: AppTheme.circleColor,
      label: 'CIRCLE',
      icon: Icons.circle,
    ),
    ShapeConfig(
      type: ShapeType.square,
      color: AppTheme.squareColor,
      label: 'SQUARE',
      icon: Icons.square,
    ),
    ShapeConfig(
      type: ShapeType.triangle,
      color: AppTheme.triangleColor,
      label: 'TRIANGLE',
      icon: Icons.change_history,
    ),
  ];

  static ShapeConfig forType(ShapeType t) => all.firstWhere((s) => s.type == t);
}

class WallHole {
  final ShapeType shape;
  final double position; // 0.0..1.0 horizontal position of hole center
  final double size;    // 0.0..1.0 relative to wall width

  const WallHole({
    required this.shape,
    required this.position,
    required this.size,
  });
}

class Wall {
  final List<WallHole> holes;
  double y; // 0.0 = top, 1.0 = bottom (canvas fraction)
  final double speed; // fraction per second

  Wall({
    required this.holes,
    required this.y,
    required this.speed,
  });

  static Wall generate(int level, double speed, Random rng) {
    final count = level < 3 ? 1 : (level < 6 ? 1 : (rng.nextBool() ? 1 : 2));
    final types = ShapeType.values.toList()..shuffle(rng);
    final holes = <WallHole>[];

    if (count == 1) {
      holes.add(WallHole(
        shape: types[0],
        position: 0.2 + rng.nextDouble() * 0.6,
        size: _holeSize(level),
      ));
    } else {
      holes.add(WallHole(shape: types[0], position: 0.25, size: _holeSize(level)));
      holes.add(WallHole(shape: types[1], position: 0.70, size: _holeSize(level)));
    }

    return Wall(holes: holes, y: -0.15, speed: speed);
  }

  static double _holeSize(int level) {
    if (level <= 2) return 0.28;
    if (level <= 5) return 0.24;
    if (level <= 8) return 0.20;
    return 0.17;
  }
}