import 'package:flutter/material.dart';
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

  // Track canvas width for drag-to-fraction conversion
  double _canvasWidth = 0;

  @override
  void initState() {
    super.initState();
    _engine = GameEngine();
    _morphCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          // Game canvas with horizontal drag for player movement
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                _engine.movePlayer(details.delta.dx, _canvasWidth);
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _canvasWidth = constraints.maxWidth;
                  return CustomPaint(
                    painter: GamePainter(
                      walls: _engine.walls,
                      playerShape: _engine.playerShape,
                      engine: _engine,
                    ),
                  );
                },
              ),
            ),
          ),

          // HUD — pinned to top
          Positioned(
            top: topInset,
            left: 0,
            right: 0,
            child: HudWidget(engine: _engine, onPause: _engine.pause),
          ),

          // Shape selector — pinned to bottom
          Positioned(
            bottom: bottomInset + 16,
            left: 0,
            right: 0,
            child: ShapeSelector(
              current: _engine.playerShape,
              onSelect: _engine.changeShape,
              morphCtrl: _morphCtrl,
            ),
          ),

          // Pause overlay
          if (_engine.state == GameState.paused)
            PauseOverlay(
              onResume: _engine.resume,
              onRestart: _engine.restart,
              onMenu: () => Navigator.of(context).pop(),
            ),

          // Game over overlay
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
}