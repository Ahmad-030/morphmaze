import 'dart:math';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'game_engine.dart';
import 'game_models.dart';

class GamePainter extends CustomPainter {
  final List<Wall> walls;
  final ShapeType playerShape;
  final GameEngine engine;

  GamePainter({
    required this.walls,
    required this.playerShape,
    required this.engine,
  });

  static const double _wallHeight = 38;
  static const double _playerSize = 46;

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawGridLines(canvas, size);

    for (final wall in walls) {
      _drawWall(canvas, size, wall);
      if (engine.state == GameState.playing) {
        if (engine.checkCollision(wall, size)) {
          engine.onCollision();
        }
      }
    }

    _drawPlayer(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppTheme.bgDeep, const Color(0xFF0A0E20)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.wallBorder.withOpacity(0.12)
      ..strokeWidth = 0.5;
    const cols = 8;
    final colW = size.width / cols;
    for (int i = 1; i < cols; i++) {
      canvas.drawLine(Offset(i * colW, 0), Offset(i * colW, size.height), paint);
    }
    const rows = 16;
    final rowH = size.height / rows;
    for (int i = 1; i < rows; i++) {
      canvas.drawLine(Offset(0, i * rowH), Offset(size.width, i * rowH), paint);
    }
  }

  void _drawWall(Canvas canvas, Size size, Wall wall) {
    final y = wall.y * size.height;

    // Main wall fill
    final wallPaint = Paint()..color = AppTheme.wallColor;
    final wallRect = Rect.fromLTWH(0, y - _wallHeight / 2, size.width, _wallHeight);

    // Create path with holes punched out
    final path = Path()..addRect(wallRect);

    for (final hole in wall.holes) {
      final holeX = hole.position * size.width;
      final holeW = hole.size * size.width;
      final holePath = _holeClipPath(hole.shape, holeX, y, holeW);
      path.addPath(holePath, Offset.zero);
    }
    path.fillType = PathFillType.evenOdd;
    canvas.drawPath(path, wallPaint);

    // Wall border glow
    final borderPaint = Paint()
      ..color = AppTheme.wallBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(wallRect, borderPaint);

    // Draw hole outlines with neon glow
    for (final hole in wall.holes) {
      _drawHoleOutline(canvas, hole, wall, size, y);
    }
  }

  Path _holeClipPath(ShapeType shape, double cx, double cy, double w) {
    final h = _wallHeight * 1.0;
    final hh = h / 2;
    switch (shape) {
      case ShapeType.circle:
        final r = w / 2;
        return Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));
      case ShapeType.square:
        final half = w / 2;
        return Path()..addRect(Rect.fromLTWH(cx - half, cy - hh, w, h));
      case ShapeType.triangle:
        return Path()
          ..moveTo(cx, cy - hh)
          ..lineTo(cx + w / 2, cy + hh)
          ..lineTo(cx - w / 2, cy + hh)
          ..close();
    }
  }

  void _drawHoleOutline(Canvas canvas, WallHole hole, Wall wall, Size size, double y) {
    final color = ShapeConfig.forType(hole.shape).color;
    final holeX = hole.position * size.width;
    final holeW = hole.size * size.width;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final solidPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final hh = _wallHeight / 2;
    Path outlinePath;
    switch (hole.shape) {
      case ShapeType.circle:
        outlinePath = Path()..addOval(Rect.fromCircle(center: Offset(holeX, y), radius: holeW / 2));
        break;
      case ShapeType.square:
        outlinePath = Path()..addRect(Rect.fromLTWH(holeX - holeW / 2, y - hh, holeW, _wallHeight));
        break;
      case ShapeType.triangle:
        outlinePath = Path()
          ..moveTo(holeX, y - hh)
          ..lineTo(holeX + holeW / 2, y + hh)
          ..lineTo(holeX - holeW / 2, y + hh)
          ..close();
        break;
    }

    canvas.drawPath(outlinePath, glowPaint);
    canvas.drawPath(outlinePath, solidPaint);
  }

  void _drawPlayer(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.82;
    final config = ShapeConfig.forType(playerShape);
    final color = config.color;
    final half = _playerSize / 2;

    // Outer glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(Offset(cx, cy), _playerSize * 0.8, glowPaint);

    // Fill paint
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(0.9), color.withOpacity(0.4)],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: half));

    // Border paint
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    switch (playerShape) {
      case ShapeType.circle:
        canvas.drawCircle(Offset(cx, cy), half, fillPaint);
        canvas.drawCircle(Offset(cx, cy), half, borderPaint);
        break;
      case ShapeType.square:
        final rect = Rect.fromCenter(center: Offset(cx, cy), width: _playerSize, height: _playerSize);
        final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(6));
        canvas.drawRRect(rRect, fillPaint);
        canvas.drawRRect(rRect, borderPaint);
        break;
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(cx, cy - half)
          ..lineTo(cx + half, cy + half)
          ..lineTo(cx - half, cy + half)
          ..close();
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
        break;
    }

    // Inner shimmer
    final shimmer = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset(cx - half * 0.2, cy - half * 0.2), half * 0.25, shimmer);
  }

  @override
  bool shouldRepaint(GamePainter old) => true;
}