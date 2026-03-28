import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morphmaze/prefs_service.dart';

import 'app_theme.dart';
import 'game_screen.dart';
import 'highscore_screen.dart';
import 'about_screen.dart';
import 'privacy_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _bgCtrl;
  late AnimationController _entryCtrl;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _loadScore();
  }

  Future<void> _loadScore() async {
    final hs = await PrefsService.getHighScore();
    if (mounted) setState(() => _highScore = hs);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              painter: _MenuBgPainter(_bgCtrl.value),
              size: MediaQuery.of(context).size,
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _entryCtrl,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildHighScore(),
                  const Spacer(),
                  _buildButtons(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _miniShape(AppTheme.circleColor, ShapeType.circle),
            const SizedBox(width: 12),
            Text('MORPHMAZE',
                style: GoogleFonts.orbitron(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: 4,
                  shadows: [Shadow(color: AppTheme.accent.withOpacity(0.8), blurRadius: 16)],
                )),
            const SizedBox(width: 12),
            _miniShape(AppTheme.triangleColor, ShapeType.triangle),
          ],
        ),
        const SizedBox(height: 6),
        Text('MORPH · MATCH · SURVIVE',
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              letterSpacing: 4,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }

  Widget _miniShape(Color color, ShapeType shape) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _MiniShapePainter(color, shape)),
    );
  }

  Widget _buildHighScore() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonYellow.withOpacity(0.4)),
        color: AppTheme.neonYellow.withOpacity(0.06),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_rounded, color: AppTheme.neonYellow, size: 20),
          const SizedBox(width: 10),
          Text('BEST  ',
              style: GoogleFonts.rajdhani(
                  color: AppTheme.neonYellow, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 2)),
          Text('$_highScore',
              style: GoogleFonts.orbitron(
                  color: AppTheme.neonYellow, fontWeight: FontWeight.w900, fontSize: 20,
                  shadows: [Shadow(color: AppTheme.neonYellow.withOpacity(0.7), blurRadius: 12)])),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          _MenuButton(
            label: 'PLAY NOW',
            icon: Icons.play_arrow_rounded,
            color: AppTheme.accent,
            isPrimary: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen())).then((_) => _loadScore()),
          ),
          const SizedBox(height: 14),
          _MenuButton(
            label: 'HIGH SCORE',
            icon: Icons.leaderboard_rounded,
            color: AppTheme.neonYellow,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HighScoreScreen())),
          ),
          const SizedBox(height: 14),
          _MenuButton(
            label: 'ABOUT',
            icon: Icons.info_outline_rounded,
            color: AppTheme.neonPurple,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())),
          ),
          const SizedBox(height: 14),
          _MenuButton(
            label: 'PRIVACY POLICY',
            icon: Icons.shield_outlined,
            color: AppTheme.textMuted,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen())),
          ),
        ],
      ),
    );
  }
}

enum ShapeType { circle, square, triangle }

class _MiniShapePainter extends CustomPainter {
  final Color color;
  final ShapeType shape;
  _MiniShapePainter(this.color, this.shape);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    final cx = size.width / 2;
    final cy = size.height / 2;
    switch (shape) {
      case ShapeType.circle:
        canvas.drawCircle(Offset(cx, cy), cx, p);
        break;
      case ShapeType.square:
        canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy), width: size.width, height: size.height), p);
        break;
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(cx, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(path, p);
        break;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _MenuBgPainter extends CustomPainter {
  final double t;
  final Random _rng = Random(99);
  _MenuBgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [AppTheme.accent, AppTheme.neonPurple, AppTheme.neonPink, AppTheme.neonYellow];
    for (int i = 0; i < 20; i++) {
      final x = _rng.nextDouble() * size.width;
      final baseY = _rng.nextDouble() * size.height;
      final speed = 0.04 + _rng.nextDouble() * 0.06;
      final y = (baseY - t * speed * size.height) % size.height;
      final r = 1.0 + _rng.nextDouble() * 3;
      final opacity = (sin((t * 3 + i) * pi) * 0.5 + 0.5) * 0.25;
      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
    // Ambient gradient blobs
    final blob1 = Paint()
      ..shader = RadialGradient(colors: [AppTheme.accent.withOpacity(0.06), Colors.transparent])
          .createShader(Rect.fromCircle(center: Offset(size.width * 0.2, size.height * 0.3), radius: 200));
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 200, blob1);
    final blob2 = Paint()
      ..shader = RadialGradient(colors: [AppTheme.neonPurple.withOpacity(0.06), Colors.transparent])
          .createShader(Rect.fromCircle(center: Offset(size.width * 0.8, size.height * 0.7), radius: 180));
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 180, blob2);
  }

  @override
  bool shouldRepaint(_MenuBgPainter old) => true;
}

class _MenuButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1, end: 0.95).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: double.infinity,
          height: widget.isPrimary ? 62 : 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: widget.isPrimary
                ? LinearGradient(
              colors: [widget.color, widget.color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            border: Border.all(color: widget.color.withOpacity(widget.isPrimary ? 0 : 0.5), width: 1.5),
            color: widget.isPrimary ? null : widget.color.withOpacity(0.08),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(widget.isPrimary ? 0.4 : 0.15),
                blurRadius: widget.isPrimary ? 20 : 12,
                spreadRadius: widget.isPrimary ? 2 : 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: widget.isPrimary ? AppTheme.bgDeep : widget.color, size: 20),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: GoogleFonts.orbitron(
                  fontSize: widget.isPrimary ? 15 : 13,
                  fontWeight: FontWeight.w800,
                  color: widget.isPrimary ? AppTheme.bgDeep : widget.color,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}