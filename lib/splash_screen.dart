import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';
import 'menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);

    _scaleAnim = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut);
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.5)),
    );
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(_pulseCtrl);

    _logoCtrl.forward();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MenuScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _particleCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              painter: _SplashParticlePainter(_particleCtrl.value),
              size: MediaQuery.of(context).size,
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _logoCtrl,
              builder: (_, __) => FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedBuilder(
                        animation: _glowAnim,
                        builder: (_, __) => Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [
                              AppTheme.accent.withOpacity(0.3 * _glowAnim.value),
                              Colors.transparent,
                            ]),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withOpacity(0.5 * _glowAnim.value),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: _LogoWidget(glow: _glowAnim.value),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'MORPHMAZE',
                        style: GoogleFonts.orbitron(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: 6,
                          shadows: [
                            Shadow(color: AppTheme.accent.withOpacity(0.8), blurRadius: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'MORPH · MATCH · SURVIVE',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textMuted,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 48),
                      _LoadingDots(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  final double glow;
  const _LogoWidget({required this.glow});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(90, 90),
      painter: _LogoPainter(glow),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double glow;
  _LogoPainter(this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Circle (top-left)
    final cp = Paint()
      ..color = AppTheme.circleColor
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * glow);
    canvas.drawCircle(Offset(cx - 20, cy - 12), 16, cp);

    // Square (top-right)
    final sp = Paint()
      ..color = AppTheme.squareColor
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * glow);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + 18, cy - 12), width: 26, height: 26), sp);

    // Triangle (bottom-center)
    final tp = Paint()
      ..color = AppTheme.triangleColor
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6 * glow);
    final tri = Path()
      ..moveTo(cx, cy + 30)
      ..lineTo(cx + 18, cy + 4)
      ..lineTo(cx - 18, cy + 4)
      ..close();
    canvas.drawPath(tri, tp);
  }

  @override
  bool shouldRepaint(_LogoPainter old) => old.glow != glow;
}

class _SplashParticlePainter extends CustomPainter {
  final double t;
  final Random _rng = Random(42);
  _SplashParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [AppTheme.accent, AppTheme.neonPurple, AppTheme.neonPink];
    for (int i = 0; i < 30; i++) {
      final x = _rng.nextDouble() * size.width;
      final y = (((_rng.nextDouble() + t) % 1.0)) * size.height;
      final r = 1.0 + _rng.nextDouble() * 2;
      final opacity = (sin((t + _rng.nextDouble()) * pi * 2) * 0.5 + 0.5) * 0.4;
      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(_SplashParticlePainter old) => true;
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final v = (((_ctrl.value - delay) % 1.0 + 1.0) % 1.0);
            final scale = 0.6 + sin(v * pi) * 0.4;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accent,
                    boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.8), blurRadius: 8)],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}