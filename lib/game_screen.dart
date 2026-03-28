import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morphmaze/pause_overlay.dart';
import 'package:morphmaze/shape_selector.dart';

import 'app_theme.dart';
import 'game_engine.dart';
import 'game_models.dart';
import 'game_over_overlay.dart';
import 'game_painter.dart';
import 'hud_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late GameEngine _engine;
  late AnimationController _morphCtrl;
  ShapeType _displayedShape = ShapeType.circle;

  @override
  void initState() {
    super.initState();
    _engine = GameEngine();
    _morphCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _engine.addListener(_onEngineUpdate);
    _engine.init().then((_) => _engine.startGame());
  }

  void _onEngineUpdate() {
    if (mounted) setState(() {});
    if (_engine.playerShape != _displayedShape) {
      _displayedShape = _engine.playerShape;
      _morphCtrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineUpdate);
    _engine.dispose();
    _morphCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          _buildGameCanvas(),
          SafeArea(child: HudWidget(engine: _engine, onPause: _engine.pause)),
          _buildShapeSelector(),
          if (_engine.state == GameState.paused)
            PauseOverlay(
              onResume: _engine.resume,
              onRestart: _engine.restart,
              onMenu: () => Navigator.of(context).pop(),
            ),
          if (_engine.state == GameState.gameOver)
            GameOverOverlay(
              score: _engine.score,
              highScore: _engine.highScore,
              level: _engine.level,
              onRetry: _engine.restart,
              onMenu: () => Navigator.of(context).pop(),
            ),
        ],
      ),
    );
  }

  Widget _buildGameCanvas() {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            painter: GamePainter(
              walls: _engine.walls,
              playerShape: _engine.playerShape,
              engine: _engine,
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          );
        },
      ),
    );
  }

  Widget _buildShapeSelector() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: ShapeSelector(
            current: _engine.playerShape,
            onSelect: _engine.changeShape,
            morphCtrl: _morphCtrl,
          ),
        ),
      ),
    );
  }
}