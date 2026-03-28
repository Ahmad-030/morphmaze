import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:morphmaze/prefs_service.dart';

import 'game_models.dart';

enum GameState { idle, playing, paused, gameOver }

class GameEngine extends ChangeNotifier {
  GameState state = GameState.idle;
  ShapeType playerShape = ShapeType.circle;
  List<Wall> walls = [];
  int score = 0;
  int highScore = 0;
  int level = 1;

  double _wallSpeed = 0.28;     // fraction/second
  double _spawnInterval = 2.2;  // seconds

  final Random _rng = Random();
  Timer? _ticker;
  Timer? _spawnTimer;
  DateTime? _lastTick;
  bool _isDisposed = false;

  static const int _pointsPerLevel = 5;

  Future<void> init() async {
    highScore = await PrefsService.getHighScore();
    notifyListeners();
  }

  void startGame() {
    score = 0;
    level = 1;
    walls.clear();
    playerShape = ShapeType.circle;
    _wallSpeed = 0.28;
    _spawnInterval = 2.2;
    state = GameState.playing;
    _startTimers();
    notifyListeners();
  }

  void pause() {
    if (state != GameState.playing) return;
    state = GameState.paused;
    _stopTimers();
    notifyListeners();
  }

  void resume() {
    if (state != GameState.paused) return;
    state = GameState.playing;
    _startTimers();
    notifyListeners();
  }

  void restart() {
    _stopTimers();
    startGame();
  }

  void changeShape(ShapeType shape) {
    if (state != GameState.playing) return;
    playerShape = shape;
    notifyListeners();
  }

  void _startTimers() {
    _lastTick = DateTime.now();
    _ticker = Timer.periodic(const Duration(milliseconds: 16), _tick);
    _scheduleSpawn();
  }

  void _stopTimers() {
    _ticker?.cancel();
    _spawnTimer?.cancel();
    _ticker = null;
    _spawnTimer = null;
  }

  void _scheduleSpawn() {
    _spawnTimer = Timer(Duration(milliseconds: (_spawnInterval * 1000).toInt()), () {
      if (state == GameState.playing) {
        _spawnWall();
        _scheduleSpawn();
      }
    });
  }

  void _spawnWall() {
    walls.add(Wall.generate(level, _wallSpeed, _rng));
    notifyListeners();
  }

  void _tick(Timer t) {
    if (state != GameState.playing) return;
    final now = DateTime.now();
    final dt = now.difference(_lastTick!).inMilliseconds / 1000.0;
    _lastTick = now;

    final toRemove = <Wall>[];
    for (final wall in walls) {
      wall.y += wall.speed * dt;
      if (wall.y > 1.15) {
        // Wall passed without collision
        toRemove.add(wall);
        _onWallPassed();
      }
    }
    walls.removeWhere((w) => toRemove.contains(w));

    if (!_isDisposed) notifyListeners();
  }

  void _onWallPassed() {
    score++;
    if (score > highScore) {
      highScore = score;
      PrefsService.saveHighScore(highScore);
    }
    _checkLevelUp();
  }

  void _checkLevelUp() {
    final newLevel = (score ~/ _pointsPerLevel) + 1;
    if (newLevel > level) {
      level = newLevel;
      _wallSpeed = 0.28 + (level - 1) * 0.04;
      _spawnInterval = max(0.9, 2.2 - (level - 1) * 0.12);
    }
  }

  void onCollision() {
    if (state != GameState.playing) return;
    state = GameState.gameOver;
    _stopTimers();
    PrefsService.saveHighScore(score);
    PrefsService.addScoreHistory(score);
    PrefsService.saveLastLevel(level);
    notifyListeners();
  }

  bool checkCollision(Wall wall, Size canvasSize) {
    // Player is at bottom-center, ~15% from bottom
    const playerFraction = 0.82; // y position of player center
    const playerSize = 0.09;     // relative to canvas width

    if (wall.y < playerFraction - 0.06 || wall.y > playerFraction + 0.12) return false;

    const playerX = 0.5; // center horizontally
    for (final hole in wall.holes) {
      if (_playerFitsHole(playerX, hole)) return false;
    }
    return true; // player hits wall
  }

  bool _playerFitsHole(double playerX, WallHole hole) {
    if (hole.shape != playerShape) return false;
    final holeLeft = hole.position - hole.size / 2;
    final holeRight = hole.position + hole.size / 2;
    const playerHalfW = 0.07;
    return (playerX - playerHalfW) >= holeLeft && (playerX + playerHalfW) <= holeRight;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopTimers();
    super.dispose();
  }
}